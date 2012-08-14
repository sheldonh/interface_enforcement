require 'cane/rake_task'
require 'rspec/core/rake_task'

def prettify(task)
  task.rspec_opts = '--color --format=doc'
end

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  RSpec::Core::RakeTask.new(:doc) do |rspec|
    prettify(rspec)
  end
end

RSpec::Core::RakeTask.new(:demo) do |rspec|
  rspec.pattern = './demo{,/*/**}/*_spec.rb'
  prettify(rspec)
end

desc "Run cane to check quality metrics"
Cane::RakeTask.new(:quality) do |cane|
  cane.abc_max = 5
  cane.no_doc = true
  cane.style_measure = 120
end

desc "Check code coverage level"
task :coverage => :spec do
  required = 100.0
  percent = File.read('coverage/coverage_percent').to_f
  if percent < 100.0
    raise "Coverage below minimum level (#{required.round(2)}%): #{percent.round(2)}%"
  else
    puts "Coverage meets minimum requirement: #{required.round(2)}%"
  end
end

task :shippable => [:quality, :spec, :coverage]
task :default => :shippable
