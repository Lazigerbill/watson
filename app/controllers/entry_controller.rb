class EntryController < ApplicationController
  def index
  end

  def show
  end

  def new
    @input = params[:input]
    analyse(@input)
  end

  def edit
  end

  def delete
  end

end

private
  def analyse(input)
    url="https://gateway.watsonplatform.net/personality-insights/api"
    profile_api_url = "#{url}/v2/profile"

    client = RestClient::Resource.new(profile_api_url, username, password)
    insights = client.post input, :content_type => "text/plain"

    pipeline = JSON.load(insights.body)[0]

  end

