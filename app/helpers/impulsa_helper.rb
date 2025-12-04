# frozen_string_literal: true

module ImpulsaHelper
  def filetypes_to_file_filter(filetype)
    return unless filetype

    (ImpulsaProject::FILETYPES[filetype.to_sym].map { |ext| ".#{ext}" } +
      ImpulsaProject::FILETYPES[filetype.to_sym].map { |ext| ImpulsaProject::EXTENSIONS[ext] }
    ).join(',')
  end
end
