require 'rubygems'
require 'zip'

class UploadWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(data, id, filename)
    begin
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
      @result.each do |pres|
        if pres[1] != nil && pres[1].split.count > 250 #enter the minimum number of words here
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
          @entry.user = User.find(id)
          @entry.save
        end
      end
    rescue Exception => e
      user = User.find(id)
      user.update_attribute(:failed_entries, user.failed_entries << " " << filename)
      UserMailer.error(user).deliver_now   
    end
  end
end
