class ReportsController < ApplicationController
  include ReportsHelper

  def new
    @user = current_user
    @report = Report.new
    if !!params[:entries_ids]
      @multi_select = Entry.find(params[:entries_ids])
      @combined = []
      @multi_select.each do |s|
        @combined << s.transcript
      end
      @combined.flatten!
    else
      flash.now[:error] = "You didn't select any transcripts."
      render :index
    end
  end

  def create
    @user = current_user
    if @user.report_creations < 100
      @report = @user.reports.build(report_params)
      @report.watson = post_to_Watson(@report.combined_transcripts)
      if @report.save
        redirect_to user_report_path(current_user, @report.id), :notice => "Transcripts successfully analysed and saved!!"
        @user.update_attribute(:report_creations, @user.report_creations + 1)
      else
        render :new, :alert => "Error(s) preventing transcripts to be saved!"
      end
    else
      flash.now[:error] = "You have exceeded maximum allowed analysis."
      render :index
    end
  end

  def show
    @user = current_user
    @report = Report.find(params[:id])
    unless @report.watson.nil?
      @big5 = @report.watson["tree"]["children"][0]
      @needs = @report.watson["tree"]["children"][1]
      @values = @report.watson["tree"]["children"][2]
    end
  end

  def index
    @reports = current_user.reports
  end

  def export_csv
    #code in helper method ReportsHelper
    @report = Report.find(params[:id])
    convert_JSON_to_csv(@report)
  end

end

private
def report_params
  params.require(:report).permit(:company_name, :ticker, :speaker_name, :speaker_title, :wcount, :combined_transcripts, :watson_analytics)
  
end


# def create #this method is only used for manual upload, doesn't apply to batch upload.
#   @input = params[:entry]["transcript"]
#   #post request to Watson API
#   #analyse(@input)
#   @entry = Entry.new(entry_params)  
#   @entry.insights = @watson_says
#   if @entry.save
#     redirect_to entry_path(@entry.id), :notice => "Transcript successfully analysed and saved!!"
#   else
#     render :new, :alert => "booboo!"
#   end
# end

# def analyse
#   @entry = Entry.find(params[:id])
#   profile_api_url = "#{Figaro.env.bluemix_url}/v2/profile"
#   client = RestClient::Resource.new(profile_api_url, Figaro.env.bluemix_username, Figaro.env.bluemix_password)
#   insights = client.post @entry.transcript, :content_type => "text/plain;charset=utf-8"
#   if @entry.update_attribute(:insights, JSON.load(insights.body))
#     redirect_to entry_path(@entry.id), :flash => { :success => "Watson analytics updated sucessfully." }
#   end
# end
