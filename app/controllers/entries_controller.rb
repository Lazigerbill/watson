class EntriesController < ApplicationController
  def landing

  end
  def index
    @entries = Entry.all
  end

  def show
    @entry = Entry.find(params[:id])
    @big5 = @entry.insights["tree"]["children"][0]
    @needs = @entry.insights["tree"]["children"][1]
    @values = @entry.insights["tree"]["children"][2]
  end

  def new
    @entry = Entry.new
  end

  def create
    @input = params[:entry]["transcript"]
    
    #post request to Watson API
    #analyse(@input)

    @entry = Entry.new(entry_params)  
    @entry.insights = @watson_says

    if @entry.save
      redirect_to entry_path(@entry.id), :notice => "Transcript successfully analysed and saved!!"
    else
      render :new, :alert => "booboo!"
    end
  end

  def edit
    @entry = Entry.find(params[:id])
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(entry_params)
      redirect_to entries_path, :flash => { :success => "Record for #{@entry.company_name} updated Sucessfully." }
    else
      @entry.errors.full_messages.each do |msg|
        flash.now[:error] = msg
      end
      render :edit 
    end
  end

  def destroy 
    @entry = Entry.find(params[:id])
    @entry.delete
    redirect_to entries_path
  end

  def upload
    uploaded_file = params[:file]

    #check if upload file is txt or zip
    if File.extname(uploaded_file.original_filename) == ".txt"
      # split of text files into array of sections
      data = uploaded_file.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
      event = data.first(5)
      # extract speaker and presentations
      parse_presentation(data)
      bypass_input(event)
    elsif File.extname(uploaded_file.original_filename) == ".zip"
      #write code 
    else
      redirect_to new_entry_path, :alert => "File type is not supoorted!  Please try again."
    end
  end
end

private
def analyse(input)
  profile_api_url = "#{Figaro.env.bluemix_url}/v2/profile"

  client = RestClient::Resource.new(profile_api_url, Figaro.env.bluemix_username, Figaro.env.bluemix_password)
  insights = client.post input, :content_type => "text/plain;charset=utf-8"

  @watson_says = JSON.load(insights.body)
end

def entry_params
  params.require(:entry).permit(:company_name, :ticker, :event_name, :date, :speaker_name, :speaker_title, :wcount, :transcript)
end

def parse_presentation(data)
  @result = []
  # presentation will only contain the presentation section
  data.shift(data.index("Presentation")+1)
  presentation = data.take(data.index("Questions and Answers"))
  
  #create speaker index, starts at [0](usually operator)
  speakers = presentation.select{|i| i.match(/\[[0-9]+\]/)}
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

  def bypass_input(data)
    @rcount = 0
    @result.each do |pres|
      if pres[1].split.count > 500
        @entry = Entry.new
        @entry.company_name = data[2].match(/-(.+?)$/)[1].strip
        @entry.ticker = data[2].match(/^(.+?)-/)[1].strip

        #the following is to remove company name from Event title
        data[3].gsub!(/[\.\,]/, '')
        @entry.company_name.split.each do |w|
          data[3].slice! (w+ ' ')
        end  
        @entry.event_name = data[3]

        @entry.date = DateTime.parse(data[4])
        @entry.speaker_name = pres[0].match(/^(.+?),/)[1]
        @entry.speaker_title = pres[0].match(/,(.+?)$/)[1].strip
        @entry.transcript = pres[1]
        @entry.wcount = pres[1].split.count
        if @entry.save!
          @rcount += 1
        else render :new, :alert => "Something went wrong..."
        end
      end
    end
    redirect_to entries_path, :notice => "#{@rcount} #{'script'.pluralize(@rcount)} successfully saved!!"
  end

