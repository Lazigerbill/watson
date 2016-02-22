module ReportsHelper
  def post_to_Watson(transcript)
    profile_api_url = "#{Figaro.env.bluemix_url}/v2/profile"
    client = RestClient::Resource.new(profile_api_url, Figaro.env.bluemix_username, Figaro.env.bluemix_password)
    insights = client.post transcript, :content_type => "text/plain;charset=utf-8"
    JSON.load(insights.body)
  end

  def convert_JSON_to_csv(report)
    unless report.watson.nil?
      @big5 = report.watson["tree"]["children"][0]
      @needs = report.watson["tree"]["children"][1]
      @values = report.watson["tree"]["children"][2]
    end
    @output = CSV.generate do |csv|
      csv << ["","PERSONALITY"]
      for i in 0..4
        csv << [""]
        csv << [@big5["children"][0]["children"][i]["name"],"Percentage","Sampling Error"]
        @big5["children"][0]["children"][i]["children"].each do |each5|
          csv << [each5["name"],each5["percentage"].round(4),each5["sampling_error"].round(4)]
        end
      end

      csv << [""]
      csv << ["","VALUES"]
      csv << [""]
      csv << [@values["children"][0]["name"],"Percentage","Sampling Error"]
      @values["children"][0]["children"].each do |eachvalue|
        csv << [eachvalue["name"],eachvalue["percentage"].round(4),eachvalue["sampling_error"].round(4)]
      end
      
      csv << [""]
      csv << ["","NEEDS"]
      csv << [""]
      csv << [@needs["children"][0]["name"],"Percentage","Sampling Error"]
      @needs["children"][0]["children"].each do |eachneed|
        csv << [eachneed["name"],eachneed["percentage"].round(4),eachneed["sampling_error"].round(4)]
      end

    end

    send_data @output, :type => "text/plain", 
               :filename=> report.speaker_title + "-" + report.speaker_name + "-" + report.created_at.to_s + ".csv",
               :disposition => 'attachment'
  end
end
