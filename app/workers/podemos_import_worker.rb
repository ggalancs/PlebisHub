class PlebisBrandImportWorker

  require 'plebisbrand_import'

  @queue = :plebisbrand_import_queue

  def self.perform row
    PlebisBrandImport.process_row(row)
  end

end
