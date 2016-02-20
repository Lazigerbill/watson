require 'rubygems'
require 'zip'

module UploadHelper
  def process_upload(input)
    #check if upload file is txt or zip
    if File.extname(input.original_filename) == ".txt"
      # split of text files into array of sections
      data = input.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
      # extract speaker and contents
      parse_content(data)
      save_into_db
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
            # extract speaker and contents
            parse_content(data)
            save_into_db
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

  def parse_content(data)
    if data[2] =~ /-(.+?)$/
      @company_name = data[2].match(/-(.+?)$/)[1].strip
      @ticker = data[2].match(/^(.+?)-/)[1].strip
    else 
      @company_name = data[2]
      @ticker = "NOTICKER"
    end

    #the following is to remove company name from Event title
    data[3].gsub!(/[\.\,]/, '')
    @company_name.split.each do |w|
      data[3].slice! (w+ ' ')
    end  
    @event_name = data[3]
    @date = DateTime.parse(data[4])

    @result = []

    # <<<The following codes will carve out the presentation section only>>>
    # if data.index("Presentation")
    #   data.shift(data.index("Presentation")+1)
    # elsif data.index("Transcript")
    #   data.shift(data.index("Transcript")+1)
    # else
    #   return
    # end
    # if data.include? "Questions and Answers" 
    #   content = data.take(data.index("Questions and Answers"))
    # else
    #   content = data.take(data.index("Definitions"))
    # end

    # <<<The following codes will carve out the Q&A section only>>>
    if data.index("Questions and Answers")
      data.shift(data.index("Questions and Answers")+1)
    # elsif data.index("Transcript")
    #   data.shift(data.index("Transcript")+1)
    else
      return
    end
    if data.include? "Definitions" 
      content = data.take(data.index("Definitions"))
    end

    #create speaker index, starts at [0](usually operator)
    speakers = content.select{|i| i.match(/\[[0-9]+\]$/)}
    speaker_index = []
    speakers.each do |speaker|
      # content.each_index.select{|x| content[x] == speaker} !!This is in case where the Q&A is mixed into the presentation and the index number is repeated.
      speaker_index << content.each_index.select{|x| content[x] == speaker}
    end

    # The index could be duplicated and nested, so need below adjustment.
    speaker_index.flatten!.sort!.uniq!
    # Clean out the speaker index when the speaker has not spoke, i.e. consecutive speaker_index
    speaker_index.delete_if{|x| x+1 == speaker_index[x+1]}


    #producing arrays of conversations, each element = [speaker, sentence], combining sentences to unique speakers
    i = 0
    speaker_index.each do |sentence|
      if i < speaker_index.count-1
        if @result.assoc(content[sentence][/([^\[]+)/].strip!) 
          @result[@result.index(@result.assoc(content[sentence][/([^\[]+)/].strip!))][1] << content[sentence+1..speaker_index[i+1]-1].join.strip! if !!content[sentence+1] #This if statement check for blanks
        else
          @result << [content[sentence][/([^\[]+)/].strip!, content[sentence+1..speaker_index[i+1]-1].join.strip!] if !!content[sentence+1]
        end
      else 
        if @result.assoc(content[sentence][/([^\[]+)/].strip!)
          @result[@result.index(@result.assoc(content[sentence][/([^\[]+)/].strip!))][1] << content[sentence+1..content.count-1].join.strip! if !!content[sentence+1] #This if statement check for blanks
        else
          @result << [content[sentence][/([^\[]+)/].strip!, content[sentence+1..content.count-1].join.strip!] if !!content[sentence+1]
        end
      end
      i+=1
    end
  end

  def save_into_db
    @result.each do |pres|
      if pres[1] != nil && pres[1].split.count > 200 #enter the minimum number of words here
        @entry = Entry.new
        @entry.company_name = @company_name
        @entry.ticker = @ticker
        @entry.event_name = @event_name
        @entry.date = @date
        if pres[0] =~ /,/
          @entry.speaker_name = pres[0].match(/^(.+?),/)[1]
          if pres[0] =~ /,(.+?)$/
            @entry.speaker_title = pres[0].match(/,(.+?)$/)[1].strip
          else
            @entry.speaker_title = "Unknown"
          end
        else 
          @entry.speaker_name = pres[0].strip
        end
        @entry.transcript = pres[1]
        @entry.wcount = pres[1].split.count
        @entry.user = current_user
        @entry.save
      end
    end
  end
end
