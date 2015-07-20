class EntriesController < ApplicationController
  def index
    @entries = Entry.all
  end

  def show
  end

  def new
    @entry = Entry.new
    @result = []
  end

  def create
    # @input = params[:input]
    # analyse(@input)

    @entry = Entry.new(entry_params)  

    if @entry.save
      redirect_to entries_path
    else
      render :new
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
    uploaded_file = params[:file]
    data = uploaded_file.read
    raw = data.split(/[\r\n]+|\={2}|\-{2}/).reject{|s| s.empty?}
    # binding.pry
    @entry = Entry.new
    splitup(raw)

    @entry.company_name = @transcript_info[2]
    @entry.event_name = @transcript_info[3]
    @entry.date = @transcript_info[4]


    corp_participants(raw)
    mark_conversations(raw)
    render :new
  end

end

private
  def analyse(input)
    profile_api_url = "#{Figaro.env.bluemix_url}/v2/profile"

    client = RestClient::Resource.new(profile_api_url, Figaro.env.bluemix_username, Figaro.env.bluemix_password)
    insights = client.post input, :content_type => "text/plain"

    @pipeline = JSON.load(insights.body)
  end

  def entry_params
      params.require(:entry).permit(:company_name, :event_name, :date, :speaker, :transcript)
    end

  def splitup(data)
    @transcript_info = data.take(5)
  end

  def corp_participants(data)
    data.shift(6)
    list = data.take(data.index("Conference Call Participants"))
    list.each do |item|
      item.sub!('*', '')
      item.strip!
    end
    @participants = []
    (0..list.size-1).step(2).each do |i|
        @participants.push(list[i..i+1].join(" - "))
    end
  end

  def mark_conversations(data)
    data.shift(data.index("Presentation")+1)
    @presentation = data.take(data.index("Questions and Answers"))
    markers = @presentation.select{|i| i.match(/\[[0-9]+\]/)}
    
    #create marker index, starts at [0], ends at the last+1 index
    marker_index = []
    markers.each do |marker|
      marker_index << @presentation.index(marker)
    end

    #producing result of arrays of conversations, each element = [speaker, content], combining contents to unique speakers
    @result = []
    index_counter = 0
    marker_index.each do |para|
      if index_counter < marker_index.count-1
        if @result.assoc(@presentation[para][/([^\[]+)/].strip) 
          @result[@result.index(@result.assoc(@presentation[para][/([^\[]+)/].strip))][1] << @presentation[para+1..marker_index[index_counter+1]-1].join
        else
          @result << [@presentation[para][/([^\[]+)/].strip, @presentation[para+1..marker_index[index_counter+1]-1].join]
        end
      else 
        if @result.assoc(@presentation[para][/([^\[]+)/].strip)
          @result[@result.index(@result.assoc(@presentation[para][/([^\[]+)/].strip))][1] << @presentation[para+1..@presentation.count-1].join
        else
          @result << [@presentation[para][/([^\[]+)/].strip, @presentation[para+1..@presentation.count-1].join]
        end
      end
      index_counter+=1
    end

    # Turning that @result array into JSON
    # binding.pry
    # @json = @result.to_h.to_json
  end