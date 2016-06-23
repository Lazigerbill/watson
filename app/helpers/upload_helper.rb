require 'rubygems'
require 'zip'

module UploadHelper
  def process_upload(input)
    current_user.update_attribute(:failed_entries, current_user.failed_entries = "")
    #check if upload file is txt or zip
    if File.extname(input.original_filename) == ".txt"
      # split of text files into array of sections
      data = input.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
      # extract speaker and contents
      data.each { |x| x.force_encoding("UTF-8") }
      UploadWorker.perform_async(data, current_user.id, input.original_filename)
      UserMailer.delay.completed_queue(current_user)
      redirect_to entries_path, :notice => "Transcript currently uploading. An email will be sent when upload completes."
    elsif File.extname(input.original_filename) == ".zip"
      @errors = []
      Zip::File.open(input.tempfile) do |zip_file| 
        zip_file.each do |entry|
          next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/ or !entry.file?
          begin
            data = entry.get_input_stream.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
            data.each { |x| x.force_encoding("UTF-8") }
            # extract speaker and contents
            UploadWorker.perform_async(data, current_user.id, entry.name)
            
          # !!!Need a better way to show a collection of errors!!! Future improvement needed!!
          rescue => e
            @errors << e
            flash[:error] = "Error occurred when trying to save #{entry.name}. #{e}" 
          end
        end  
      end
      UserMailer.delay.completed_queue(current_user)
      redirect_to entries_path, :notice => "Transcripts currently uploading. An email will be sent when uploads complete."
    else
      redirect_to new_entry_path, :alert => "File type is not supported!  Please try again."
    end
  end
end
