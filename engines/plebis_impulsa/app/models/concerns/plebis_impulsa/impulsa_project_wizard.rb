# frozen_string_literal: true

module PlebisImpulsa
  module ImpulsaProjectWizard
    extend ActiveSupport::Concern
    include SafeConditionEvaluator

    included do
      include ActiveModel::Validations::SpanishVatValidatorsHelpers
      include ActiveModel::Validations::EmailValidatorHelpers

      store :wizard_values, coder: YAML
      store :wizard_review, coder: YAML

      before_create do
        self.wizard_step = wizard_steps.keys.first
      end

      EXTENSIONS = {
        doc: 'application/msword',
        docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        jpg: 'image/jpeg',
        ods: 'application/vnd.oasis.opendocument.spreadsheet',
        odt: 'application/vnd.oasis.opendocument.text',
        pdf: 'application/pdf',
        xls: 'application/vnd.ms-excel',
        xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      }.freeze
      FILETYPES = {
        sheet: %i[xls xlsx ods],
        scan: %i[jpg pdf],
        document: %i[doc docx odt]
      }.freeze
      MAX_FILE_SIZE = 1024 * 1024 * 10

      delegate :wizard, to: :impulsa_edition_category

      def wizard_steps
        wizard.transform_values { |step| step[:title] }
      end

      def wizard_next_step
        wizard.keys[wizard.keys.find_index(wizard_step) + 1]
      end

      def wizard_step_info
        wizard[wizard_step]
      end

      def wizard_status
        @wizard_status ||= begin
          filled = true
          ret = wizard.map do |sname, step|
            filled = false if sname == wizard_step_was
            fields = values = errors = 0
            step[:groups].each do |gname, group|
              group[:fields].each do |fname, field|
                fields += 1
                values += 1 if wizard_values["#{gname}.#{fname}"].present?
                errors += 1 if wizard_field_error(gname, fname, group, field)
              end
            end
            { step: sname, title: step[:title], fields: fields, values: values, errors: errors, filled: filled }
          end
          last_filled = ret.rindex { |step| step[:values].positive? }
          unless last_filled.nil?
            (0..last_filled).each do |i|
              ret[i][:filled] = true
            end
          end
          ret.index_by do |step|
            step[:step]
          end
        end
      end

      def wizard_step_admin_params
        _all = wizard.map do |_sname, step|
          step[:groups].map do |gname, group|
            group[:fields].map do |fname, field|
              ["_wiz_#{gname}__#{fname}", field[:type] == 'check_boxes']
            end
          end.flatten(1)
        end.flatten(1)
        _all.collect do |field, multiple|
          field unless multiple
        end.compact + [_all.select(&:last).to_h do |field, _multiple|
                        [field, []]
                      end]
      end

      def wizard_step_params
        _all = wizard[wizard_step][:groups].map do |gname, group|
          group[:fields].map do |fname, field|
            ["_wiz_#{gname}__#{fname}", field[:type] == 'check_boxes'] if wizard_editable_field?(gname, fname)
          end.compact
        end.flatten(1)
        _all.collect do |field, multiple|
          field unless multiple
        end.compact + [_all.select(&:last).to_h do |field, _multiple|
                        [field, []]
                      end]
      end

      def wizard_editable_field?(gname, fname)
        editable? || (fixable? && (wizard_review["#{gname}.#{fname}"].present? || wizard_field_error(
          gname, fname
        )))
      end

      def wizard_all_errors(options = {})
        wizard.map do |sname, _step|
          wizard_step_errors sname, options
        end.compact.flatten(1)
      end

      def wizard_step_valid?(step = nil, options = {})
        wizard_step_errors(step, options).each do |gname, fname, error|
          errors.add("_wiz_#{gname}__#{fname}", error)
        end.none?
      end

      def wizard_has_errors?(options = {})
        wizard_count_errors(options).positive?
      end

      def wizard_count_errors(options = {})
        wizard.sum do |sname, _step|
          wizard_step_errors(sname, options).count
        end
      end

      def wizard_export
        wizard.map do |_sname, step|
          step[:groups].map do |gname, group|
            group[:fields].map do |fname, field|
              value = wizard_values["#{gname}.#{fname}"]
              next if !field[:export] || value.blank?

              if field[:type] == 'check_boxes'
                value = value.compact_blank.map { |v| field[:collection][v] }
              elsif field[:type] == 'select'
                value = field[:collection][value]
              end
              ["wizard_#{field[:export]}", value]
            end.compact
          end.compact.flatten(1)
        end.flatten(1).to_h
      end

      def wizard_step_errors(step = nil, options = {})
        wizard[step || wizard_step][:groups].map do |gname, group|
          group[:fields].map do |fname, field|
            [gname, fname, wizard_field_error(gname, fname, group, field, options)]
          end.select(&:last)
        end.flatten(1)
      end

      def wizard_eval_condition(group)
        return true if group[:condition].blank?

        # Use safe evaluator instead of eval()
        # SECURITY: This prevents arbitrary code execution from database-stored conditions
        SafeConditionEvaluator.evaluate(self, group[:condition])
      rescue StandardError => e
        Rails.logger.error("Wizard condition evaluation failed: #{e.message} for condition: #{group[:condition]}")
        # Fail-safe: if condition can't be evaluated safely, skip the group
        false
      end

      def wizard_field_error(gname, fname, group = nil, field = nil, options = {})
        group = wizard.collect { |_sname, step| step[:groups][gname] }.compact.first if group.nil?
        return nil unless wizard_eval_condition(group)

        field = group[:fields][fname] if field.nil?
        value = wizard_values["#{gname}.#{fname}"]
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
          if field[:type] == 'check_boxes' && field[:minimum] && value.count < field[:minimum]
            return "debes seleccionar al menos #{field[:minimum]} opciones"
          end
          if field[:type] == 'check_boxes' && field[:maximum] && value.count > field[:maximum]
            return "puedes seleccionar hasta #{field[:maximum]} opciones"
          end

          error = validate_email(value) if field[:type] == 'email'
          return error if error
        end
        if (options[:ignore_state] || fixable?) && wizard_review["#{gname}.#{fname}"].present? && wizard_review["#{gname}.#{fname}"][0] != '*'
          return wizard_review["#{gname}.#{fname}"]
        end

        nil
      end

      def assign_wizard_value(gname, fname, value)
        field = wizard.map { |_sname, step| step[:groups][gname] && step[:groups][gname][:fields][fname] }.compact.first
        if field
          old_value = wizard_values["#{gname}.#{fname}"]
          if field[:type] == 'file'
            file = "#{gname}.#{fname}"
            if value.present?
              ext = File.extname(value.path)
              if field[:filetype] && !(FILETYPES[field[:filetype].to_sym] || []).member?(ext[1..].to_sym)
                return :wrong_extension
              end
              return :wrong_size if value.size > (field[:maxsize] || MAX_FILE_SIZE)

              file += ext
              FileUtils.mkdir_p(files_folder)
              File.binwrite(File.join(files_folder, file), value.read)
              wizard_values["#{gname}.#{fname}"] = file
            else
              wizard_values["#{gname}.#{fname}"] = nil
            end
            File.delete(File.join(files_folder, old_value)) if old_value && old_value != file
          elsif field[:type] == 'check_boxes'
            wizard_values["#{gname}.#{fname}"] = value.compact_blank
          else
            wizard_values["#{gname}.#{fname}"] = value
          end

          if old_value != value && fixable? && wizard_review["#{gname}.#{fname}"].present? && wizard_review["#{gname}.#{fname}"][0] != '*'
            wizard_review["#{gname}.#{fname}"] = "*#{wizard_review["#{gname}.#{fname}"]}"
          end
          return :ok
        end
        :wrong_field
      end

      # SECURITY FIX: Validate file path to prevent path traversal
      def wizard_path(gname, fname)
        filename = wizard_values["#{gname}.#{fname}"]
        return nil if filename.blank?

        # Use File.basename to strip any directory components (path traversal protection)
        safe_filename = File.basename(filename)
        full_path = File.join(files_folder, safe_filename)

        # Verify the resolved path is still within files_folder (additional safety check)
        unless full_path.start_with?(files_folder)
          Rails.logger.warn({
            event: 'path_traversal_attempt_blocked',
            project_id: id,
            user_id: user_id,
            requested_file: filename,
            gname: gname,
            fname: fname,
            timestamp: Time.current.iso8601
          }.to_json)
          return nil
        end

        full_path
      end

      # SECURITY FIX: Replaced instance_eval with define_method to prevent code injection
      # Original code used string interpolation in instance_eval which could execute arbitrary code
      def wizard_method_missing(method_sym, *arguments)
        if method_sym.to_s =~ /^_wiz_(.+)__([^=]+)(=?)$/
          group_name = ::Regexp.last_match(1)
          field_name = ::Regexp.last_match(2)
          is_setter = ::Regexp.last_match(3) == '='
          field_key = "#{group_name}.#{field_name}"

          if is_setter
            # Define setter method
            self.class.send(:define_method, method_sym) do |value|
              assign_wizard_value(group_name.to_sym, field_name.to_sym, value)
            end
          else
            # Define getter method
            self.class.send(:define_method, method_sym) do
              wizard_values[field_key]
            end
          end

          return send(method_sym, *arguments)
        elsif method_sym.to_s =~ /^_rvw_(.+)__([^=]+)(=?)$/
          group_name = ::Regexp.last_match(1)
          field_name = ::Regexp.last_match(2)
          is_setter = ::Regexp.last_match(3) == '='
          field_key = "#{group_name}.#{field_name}"

          if is_setter
            # Define setter method
            self.class.send(:define_method, method_sym) do |value|
              wizard_review[field_key] = value
            end
          else
            # Define getter method
            self.class.send(:define_method, method_sym) do
              wizard_review[field_key]
            end
          end

          return send(method_sym, *arguments)
        end
        :super
      end
    end
  end
end
