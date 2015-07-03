class EntryController < ApplicationController
  def index
  end

  def show
  end

  def new
    @input = params[:input]
  end

  def edit
  end

  def delete
  end

end

private
  def analysssss
    url="https://gateway.watsonplatform.net/personality-insights/api"
    profile_api_url = "#{url}/v2/profile"

    client = RestClient::Resource.new(profile_api_url, @username, @password)
    insights = client.post test_input, :content_type => "text/plain"

    pipeline = JSON.load(insights.body)[0]

  end

