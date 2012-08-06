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

task :default => :spec
