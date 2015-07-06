class EntriesController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
    @input = params[:input]
    analyse(@input)
    render new_entry_path
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

