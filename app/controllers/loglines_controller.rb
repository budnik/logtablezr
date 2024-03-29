class LoglinesController < ApplicationController

  def create
    raise unless !params.has_key? :logline && params[:logline][:logfile].blank?
    f=params[:logline][:logfile]
    @file_name=f.original_filename  

    @loglines = parse_logfile(f)
  end

  private

    def parse_logfile(file)
      vb_regexp = /\A=+.*Version (?<ver>\w+) Build (?<build>\w+)/
      loglines=[]

      file.read.each_line("\r\n\r\n") do |block|
        @ver=@build=nil
        block.each_line do |line|
          if line.match(/\A\s*\z/)
            next
          elsif @ver 
            if line.match(/(?<datetime>\d.*\.\d{3})\s+(?<n>\d+) (?<type>\d+-\w+)\s+\(null\) \[(?<location>[^\]]*)\] \(null\) (?<message>.*)$/)
            loglines << { :logged_at => DateTime.strptime($~["datetime"], "%d-%b-%Y %H:%M:%S.%L"),
                           :n => $~["n"],
                           :type => $~["type"],
                           :location => $~["location"],
                           :message => $~["message"],
                           :ver => @ver,
                           :build => @build,
                           :logfile => @logfile}
            elsif !line.match /\A=+/
              loglines.last[:message] << line
              next
            end
          else
            if found_version_and_build = line.match(vb_regexp)
              @ver = found_version_and_build["ver"]
              @build = found_version_and_build["build"]
            else
              raise "Unable to parse line: #{line}"
            end
          end
        end
      end
      loglines
    end

end
