class EntriesController < ApplicationController
  def index
    @entries = Entry.all
  end

  def show
  end

  def new
    @entry = Entry.new
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
    @result = raw.first(10)
    @entry.company_name = @result[2]
    @entry.event_name = @result[3]
    @entry.date = @result[4]
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
      params.require(:entry).permit(:company_name, :event_name, :date)
    end

  def process(data)
    raw = data.split(/[\r\n]+|\={2}|\-{2}/)
    @result = raw.first(10)
    
  end
