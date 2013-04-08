#!/usr/bin/env rake

require 'tailor/rake_task'
Tailor::RakeTask.new
# configuration is in .tailor

require 'foodcritic'
FoodCritic::Rake::LintTask.new

desc "Runs knife cookbook test"
task :knife do
  sh "knife cookbook test scout_agent -o .."
end

task :default => [:tailor, :foodcritic, :knife]
