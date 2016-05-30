require 'rubygems'
require 'zip'

module UploadHelper
  def process_upload(input)
    #check if upload file is txt or zip
    if File.extname(input.original_filename) == ".txt"
      # split of text files into array of sections
      data = input.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
      # extract speaker and contents
      data.each { |x| x.force_encoding("UTF-8") }
      UploadWorker.perform_async(data, current_user.id)
      redirect_to entries_path, :notice => "Transcript for #{@company_name} - #{@event_name} successfully uploaded!!"
    elsif File.extname(input.original_filename) == ".zip"
      @error_count = 0
      @transcript_count = 0
      @errors = []
      Zip::File.open(input.tempfile) do |zip_file| 
        zip_file.each do |entry|
          next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/ or !entry.file?
            @transcript_count += 1
          begin
            data = entry.get_input_stream.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
            data.each { |x| x.force_encoding("UTF-8") }
            # extract speaker and contents
            UploadWorker.perform_async(data, current_user.id)
            
          # !!!Need a better way to show a collection of errors!!! Future improvement needed!!
          rescue => e
            @errors << e
            flash[:error] = "Error occurred when trying to save #{entry.name}. #{e}" 
            @error_count += 1 
          end
        end  
      end
      redirect_to entries_path, :notice => "#{@transcript_count - @error_count} out of #{@transcript_count} #{'record'.pluralize(@rcount)} successfully saved!!"
    else
      redirect_to new_entry_path, :alert => "File type is not supoorted!  Please try again."
    end
  end
end
