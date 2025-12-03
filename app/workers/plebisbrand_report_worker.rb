class PlebisBrandReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :plebisbrand_report_queue

  def perform(report_id)
    report = Report.find(report_id)
    report.run!
  end
end
