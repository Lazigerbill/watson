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
    analyse(@input)

    @entry = Entry.new(entry_params)  
    @entry.insights = @watson_says

    if @entry.save
      redirect_to entry_path(@entry.id), :notice => "Transcript successfully analysed and saved!!"
    else
      render :new, :alert => "booboo!"
    end
  end

  def edit
  end

  def destroy 
    @entry = Entry.find(params[:id])
    @entry.delete
    redirect_to entries_path
  end

  def upload
    @entry = Entry.new
    uploaded_file = params[:file]
    # split of text files into array of sections
    data = uploaded_file.read.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
 
    # extract event details
    @entry.company_name = data[2]
    @entry.event_name = data[3]
    @entry.date = data[4]
  
    # extract speaker and presentations
    parse_presentation(data)

    render :new
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
      params.require(:entry).permit(:company_name, :event_name, :date, :speaker, :transcript, :wcount)
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