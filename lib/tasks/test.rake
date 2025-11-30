# Only load test tasks when Rake::TestTask is available (not in production)
if defined?(Rake::TestTask)
  namespace :test do
    Rake::TestTask.new("features" => "test:prepare") do |t|
      t.pattern = "test/features/**/*_test.rb"
    end
  end

  Rake::Task["test:run"].enhance ["test:features"]
end

