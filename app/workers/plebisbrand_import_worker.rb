require 'plebisbrand_import'

class PlebisBrandImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :plebisbrand_import_queue

  def perform(row)
    PlebisBrandImport.process_row(row)
  end
end
