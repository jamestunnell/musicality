# encoding: utf-8

require "bundler/gem_tasks"
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :test    => :spec
task :default => :spec

def rb_fname fname
  basename = File.basename(fname, File.extname(fname))
  dirname = File.dirname(fname)
  "#{dirname}/#{basename}.rb"
end

task :build_parsers do
  wd = Dir.pwd
  Dir.chdir "lib/musicality/notation/parsing"
  parser_files = Dir.glob(["**/*.treetop","**/*.tt"])
  
  if parser_files.empty?
    puts "No parsers found"
    return
  end

  build_list = parser_files.select do |fname|
    rb_name = rb_fname(fname)
    !File.exists?(rb_name) || (File.mtime(fname) > File.mtime(rb_name))
  end
  
  if build_list.any?
    puts "building parsers:"
    build_list.each do |fname|
      puts "  #{fname} -> #{rb_fname(fname)}"
      `tt -f #{fname}`
    end
  else
    puts "Parsers are up-to-date"
  end
  Dir.chdir wd
end
task :spec => :build_parsers