require 'rubygems'
require 'zip'


module UploadHelper

  def process_upload(input)
    #check if upload file is txt or zip
    if File.extname(input.original_filename) == ".txt"
      # split of text files into array of sections
      data = input.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
      # extract speaker and presentations
      parse_presentation(data)
      save_into_db
      if @entry.errors.any?
        redirect_to new_entry_path, :alert => "Error occurred when trying to save #{@company_name}. #{@entry.errors.full_messages}" 
      else 
        redirect_to entries_path, :notice => "#{@rcount} #{'record'.pluralize(@rcount)} successfully saved!!"
      end
    elsif File.extname(input.original_filename) == ".zip"
      Zip::File.open(input.tempfile) do |zip_file| 
        zip_file.each do |entry|
          next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/ or !entry.file?
            data = entry.get_input_stream.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?} 
            # extract speaker and presentations
            parse_presentation(data)
            save_into_db
        end
      end  
      if @entry.errors.any?
        redirect_to new_entry_path, :alert => "Error occurred when trying to save #{@company_name}. #{@entry.errors.full_messages}" 
      else 
        redirect_to entries_path, :notice => "#{@rcount} #{'record'.pluralize(@rcount)} successfully saved!!"
      end
    else
      redirect_to new_entry_path, :alert => "File type is not supoorted!  Please try again."
    end
  end

  def parse_presentation(data)
    @company_name = data[2].match(/-(.+?)$/)[1].strip
    @ticker = data[2].match(/^(.+?)-/)[1].strip

    #the following is to remove company name from Event title
    data[3].gsub!(/[\.\,]/, '')
    @company_name.split.each do |w|
      data[3].slice! (w+ ' ')
    end  
    @event_name = data[3]
    @date = DateTime.parse(data[4])

    @result = []
    # presentation will only contain the presentation section
    data.shift(data.index("Presentation")+1)
    if data.include? "Questions and Answers" 
      presentation = data.take(data.index("Questions and Answers"))
    else
      presentation = data.take(data.index("Definitions"))
    end
    #create speaker index, starts at [0](usually operator)
    speakers = presentation.select{|i| i.match(/\[[0-9]\]/)}
    speaker_index = []
    speakers.each do |speaker|
      speaker_index << presentation.index(speaker)
    end
    #producing arrays of conversations, each element = [speaker, content], combining contents to unique speakers
    i = 0
    speaker_index.each do |sentence|
      if i < speaker_index.count-1
        if @result.assoc(presentation[sentence][/([^\[]+)/].strip!) 
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
    end
  end

  def save_into_db
    @rcount = 0
    @result.each do |pres|
      if pres[1] != nil && pres[1].split.count > 500 #enter the minimum number of words here
        @entry = Entry.new
        @entry.company_name = @company_name
        @entry.ticker = @ticker
        @entry.event_name = @event_name
        @entry.date = @date
        @entry.speaker_name = pres[0].match(/^(.+?),/)[1]
        @entry.speaker_title = pres[0].match(/,(.+?)$/)[1].strip
        @entry.transcript = pres[1]
        @entry.wcount = pres[1].split.count
        if @entry.save
          @rcount += 1
        else 
          return
        end
      end
    end
  end

end
