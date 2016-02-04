require 'fileutils'

module Musicality
module Tasks

class FileCleaner < Rake::TaskLib
  def initialize files, dirs
    task :clean do
      if files.any?
        puts "Deleting files:"
        files.each do |fname|
          puts " " + fname
          File.delete fname
        end
      end

      existing_dirs = dirs.select {|dir| Dir.exist?(dir) }

      if existing_dirs.any?
        puts "Deleting dirs:"
        existing_dirs.each do |dirname|
          puts " " + dirname
          begin
            FileUtils::rm Dir.glob(File.join(dirname, "*"))
            FileUtils::rmdir dirname
          rescue => e
            puts "Error while trying to delete #{dirname}: #{e}"
          end
        end
      end
    end
  end
end

end
end
