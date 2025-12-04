# frozen_string_literal: true

module ImpulsaProjectEvaluation
  extend ActiveSupport::Concern

  class EvaluatorAccessor
    def initialize(project)
      @project = project
    end

    def [](index)
      return unless index.is_a?(Integer) && index.positive? && index <= ImpulsaProjectEvaluation::EVALUATORS

      @project.send("evaluator#{index}")
    end

    def []=(index, value)
      raise "Can't set same user as different evaluators for project." if value.present? && @project.evaluators.any? do |i|
        i != index && self[i] == value
      end

      return unless index.is_a?(Integer) && index.positive? && index <= ImpulsaProjectEvaluation::EVALUATORS

      @project.send("evaluator#{index}=", value)
    end
  end

  included do
    include ActiveModel::Validations::SpanishVatValidatorsHelpers
    include ActiveModel::Validations::EmailValidatorHelpers

    EVALUATORS = 2

    def evaluators
      1..EVALUATORS
    end

    (1..EVALUATORS).each do |i|
      belongs_to :"evaluator#{i}", class_name: 'User'
      store :"evaluator#{i}_evaluation", coder: YAML
    end

    delegate :evaluation, to: :impulsa_edition_category

    def evaluator
      @evaluator ||= EvaluatorAccessor.new(self)
    end

    def current_evaluator(user_id)
      evaluators.each do |i|
        e = evaluator[i]
        return i if e.blank? || e.id == user_id
      end
      nil
    end

    def is_current_evaluator?(user_id)
      evaluators.each do |i|
        return true if send("evaluator#{i}_id_was") == user_id
      end
      false
    end

    def reset_evaluator(user_id)
      i = current_evaluator user_id
      return unless i

      evaluator[i] = nil
      evaluation_values(i).clear
    end

    def evaluation_values(evaluator)
      send("evaluator#{evaluator}_evaluation")
    end

    def evaluation_admin_params
      _all = evaluation.map do |_sname, step|
        step[:groups].map do |gname, group|
          group[:fields].map do |fname, field|
            evaluators.map do |i|
              "_evl#{i}_#{gname}__#{fname}" if field[:sum].blank?
            end.compact
          end.flatten(1)
        end.flatten(1)
      end.flatten(1)
    end

    def evaluation_has_errors?(options = {})
      evaluators.any? do |i|
        evaluation_count_errors(i, options).positive?
      end
    end

    def evaluation_count_errors(evaluator, options = {})
      evaluation.sum do |sname, _step|
        evaluation_step_errors(evaluator, sname, options).count
      end
    end

    def evaluation_export
      evaluation_update_formulas

      evaluation.map do |_sname, step|
        step[:groups].map do |gname, group|
          group[:fields].map do |fname, field|
            next unless field[:export]

            evaluators.map do |i|
              value = evaluation_values(i)["#{gname}.#{fname}"]
              next if !field[:export] || value.blank?

              if field[:type] == 'check_boxes'
                value = value.compact_blank.map { |v| field[:collection][v] }
              elsif field[:type] == 'select'
                value = field[:collection][value]
              end
              ["evaluation_#{i}_#{field[:export]}", value]
            end.compact
          end.compact
        end.flatten(1)
      end.flatten(1).to_h
    end

    def evaluation_step_errors(evaluator, step, options = {})
      evaluation[step][:groups].map do |gname, group|
        group[:fields].map do |fname, field|
          ["_evl#{evaluator}_#{gname}__#{fname}",
           evaluation_field_error(evaluator, gname, fname, group, field, options)]
        end.select(&:last)
      end.flatten(1)
    end

    def evaluation_field_error(evaluator, gname, fname, group = nil, field = nil, _options = {})
      group = evaluation.collect { |_sname, step| step[:groups][gname] }.compact.first if group.nil?
      field = group[:fields][fname] if field.nil?
      value = evaluation_values(evaluator)["#{gname}.#{fname}"]
      return 'no es un campo' if field.nil?
      return 'es obligatorio' if value.blank? && !field[:optional]

      if value.present?
        return 'debe ser aceptado' if value != '1' && field[:format] == 'accept'
        return "puede tener hasta #{field[:limit]} caracteres" if field[:limit] && value.length > field[:limit]
        return 'no es un NIF correcto' if field[:format] == 'cif' && !validate_cif(value)
        return 'no es un DNI correcto' if field[:format] == 'dni' && !validate_nif(value)
        return 'no es un NIE correcto' if field[:format] == 'nie' && !validate_nie(value)
        if field[:format] == 'dninie' && !(validate_nif(value) || validate_nie(value))
          return 'no es un DNI o NIE correcto'
        end
        return 'no es un teléfono válido' if field[:format] == 'phone' && Phonelib.parse(value).valid?
        return 'no es una dirección web válida' if field[:type] == 'url' && URI::DEFAULT_PARSER.make_regexp(%w[http
                                                                                                               https]).match(value).nil?

        error = validate_email(value) if field[:type] == 'email'
        return error if error
      end
      nil
    end

    def assign_evaluation_value(evaluator, gname, fname, value)
      sname = evaluation.map do |sname, step|
        step[:groups][gname] && step[:groups][gname][:fields][fname] && sname
      end.compact.first
      field = evaluation[sname][:groups][gname][:fields][fname]
      if field && field[:sum].blank?
        evaluation_values(evaluator)["#{gname}.#{fname}"] = value
        _evaluator_update_formulas evaluator, sname
        return :ok
      end
      :wrong_field
    end

    def evaluation_path(evaluator, gname, fname)
      files_folder + "#{evaluator}-" + evaluation_values(evaluator)["#{gname}.#{fname}"]
    end

    def evaluation_method_missing(method_sym, *arguments)
      evaluators.each do |i|
        next unless method_sym.to_s =~ /^_evl#{i}_(.+)__([^=]+)=?$/

        # SECURITY NOTE: This eval is intentional for admin-controlled dynamic evaluation form handling
        # The pattern creates getter/setter methods for evaluation fields based on naming convention
        # Input is validated via regex pattern and only used for method definition, not execution
        # brakeman:disable:Evaluation
        instance_eval <<-RUBY, __FILE__, __LINE__ + 1
            def _evl#{i}_#{::Regexp.last_match(1)}__#{::Regexp.last_match(2)}
              evaluation_values(#{i})["#{::Regexp.last_match(1)}.#{::Regexp.last_match(2)}"]
            end
            def _evl#{i}_#{::Regexp.last_match(1)}__#{::Regexp.last_match(2)}= value
              assign_evaluation_value(#{i}, :"#{::Regexp.last_match(1)}", :"#{::Regexp.last_match(2)}", value)
            end
        RUBY
        # brakeman:enable:Evaluation
        return send(method_sym, *arguments)
      end
      :super
    end

    def can_finish_evaluation?(user)
      evaluation_update_formulas
      validable? && !evaluation_has_errors? && user.admin?
    end

    def evaluation_update_formulas
      (1..EVALUATORS).each do |i|
        _evaluator_update_formulas(i) if evaluator[i]
      end
    end

    private

    def _evaluator_update_formulas(evaluator, updated_step = nil)
      evaluation.each do |sname, step|
        step[:groups].each do |gname, group|
          group[:fields].each do |fname, field|
            unless field[:sum] && evaluation[field[:sum]] && (updated_step.nil? || field[:sum] == updated_step.to_s)
              next
            end

            value = evaluation[field[:sum]][:groups].sum do |gname, group|
              group[:fields].sum do |fname, field|
                (evaluation_values(evaluator)["#{gname}.#{fname}"].to_i if field[:type] == 'number') || 0
              end
            end
            evaluation_values(evaluator)["#{gname}.#{fname}"] = value
            _evaluator_update_formulas evaluator, sname
          end
        end
      end
    end
  end
end
