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

  def delete
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
      params.require(:entry).permit(:first_name, :last_name, :input)
    end
