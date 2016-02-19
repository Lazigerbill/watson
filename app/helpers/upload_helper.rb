require 'rubygems'
require 'zip'


module UploadHelper

  def process_upload(input)
    #check if upload file is txt or zip
    if File.extname(input.original_filename) == ".txt"
      # split of text files into array of sections
      # begin
        data = input.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
        # extract speaker and presentations
        parse_presentation(data)
        save_into_db
      # rescue => e
        # flash[:error] = "Error occurred when trying to save #{@company_name}. #{e}"
        # redirect_to entries_path
      # end
      redirect_to entries_path, :notice => "#{@rcount} #{'record'.pluralize(@rcount)} successfully saved!!"
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
            # extract speaker and presentations
            parse_presentation(data)
            save_into_db
          rescue => e
            @errors << e
            flash[:error] = "Error occurred when trying to save #{entry.name}. #{e}" 
            @error_count += 1
            # redirect_to entries_path  
          end
        end  
      end
      redirect_to entries_path, :notice => "#{@transcript_count - @error_count} out of #{@transcript_count} #{'record'.pluralize(@rcount)} successfully saved!!"
    else
      redirect_to new_entry_path, :alert => "File type is not supoorted!  Please try again."
    end
  end

  def parse_presentation(data)
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
    # presentation will only contain the presentation section
    if data.index("Presentation")
      data.shift(data.index("Presentation")+1)
    elsif data.index("Transcript")
      data.shift(data.index("Transcript")+1)
    end
    if data.include? "Questions and Answers" 
      presentation = data.take(data.index("Questions and Answers"))
    else
      presentation = data.take(data.index("Definitions"))
    end
    #create speaker index, starts at [0](usually operator)
    speakers = presentation.select{|i| i.match(/\[[0-9]+\]$/)}
    speaker_index = []
    speakers.each do |speaker|
      # presentation.each_index.select{|x| presentation[x] == speaker} !!This is in case where the Q&A is mixed into the presentation and the index number is repeated.
      speaker_index << presentation.each_index.select{|x| presentation[x] == speaker}
    end

    # The index could be duplicated and nested, so need below adjustment.
    speaker_index.flatten!.sort!.uniq!

    #producing arrays of conversations, each element = [speaker, content], combining contents to unique speakers
    i = 0
    speaker_index.each do |sentence|
      # begin
        if i < speaker_index.count-1
          if @result.assoc(presentation[sentence][/([^\[]+)/].strip!) 

            #check here!!!!!!seems to be a bug here when parsing!!!!!Error when speaker[1]...repeats because Q&A section is not identified
            @result[@result.index(@result.assoc(presentation[sentence][/([^\[]+)/].strip!))][1] << presentation[sentence+1..speaker_index[i+1]-1].join.strip!
          else
            @result << [presentation[sentence][/([^\[]+)/].strip!, presentation[sentence+1..speaker_index[i+1]-1].join.strip!]
          end
        else 
          if @result.assoc(presentation[sentence][/([^\[]+)/].strip!)
            @result[@result.index(@result.assoc(presentation[sentence][/([^\[]+)/].strip!))][1] << presentation[sentence+1..presentation.count-1].join.strip!
          else
            @result << [presentation[sentence][/([^\[]+)/].strip!, presentation[sentence+1..presentation.count-1].join.strip!]
          end
        end
        i+=1
      # rescue NoMethodError => e
      #   puts e
      # end
    end
  end

  def save_into_db
    @result.each do |pres|
      if pres[1] != nil && pres[1].split.count > 300 #enter the minimum number of words here
        @entry = Entry.new
        @entry.company_name = @company_name
        @entry.ticker = @ticker
        @entry.event_name = @event_name
        @entry.date = @date
        # binding.pry
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
        @entry.save
      end
    end
  end

end
