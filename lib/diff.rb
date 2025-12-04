# frozen_string_literal: true

module ActiveRecord
  module Diff
    module ClassMethod
      def diff(*attrs)
        self.diff_attrs = attrs
      end
    end

    def self.included(base)
      base.class_attribute :diff_attrs
      base.extend ClassMethod
    end

    def diff?(record = nil)
      !diff(record).empty?
    end

    def diff(other_record = nil)
      if other_record.nil?
        old_record = self.class.find(id)
        new_record = self
      else
        old_record = self
        new_record = other_record
      end

      if new_record.is_a?(Hash)
        diff_each(new_record) do |(attr_name, hash_value)|
          [attr_name, old_record.send(attr_name), hash_value]
        end
      else
        attrs = self.class.diff_attrs

        if attrs.nil?
          attrs = self.class.content_columns.map { |column| column.name.to_sym }
        elsif attrs.length == 1 && attrs.first.is_a?(Hash)
          columns = self.class.content_columns.map { |column| column.name.to_sym }

          attrs = columns + (attrs.first[:include] || []) - (attrs.first[:exclude] || [])
        end

        diff_each(attrs) do |attr_name|
          [attr_name, old_record.send(attr_name), new_record.send(attr_name)]
        end
      end
    end

    def diff_each(enum)
      enum.each_with_object({}) do |attr_name, diff_hash|
        attr_name, old_value, new_value = *yield(attr_name)

        diff_hash[attr_name.to_sym] = [old_value, new_value] unless old_value === new_value
      end
    end
  end
end

# Zeitwerk expects a Diff constant
Diff = ActiveRecord::Diff
