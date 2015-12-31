module Musicality
module Tasks

class FileCleaner < Rake::TaskLib
  def initialize outfiles
    task :clean do
      if outfiles.any?
        puts "Deleting output files:"
        outfiles.each do |fname|
          puts " " + fname
          File.delete fname
        end
      end
    end
  end
end

end
end