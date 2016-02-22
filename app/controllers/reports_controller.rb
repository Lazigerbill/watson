class ReportsController < ApplicationController
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
    @report = @user.reports.build(report_params)
    if @report.save
      redirect_to user_report_path(current_user, @report.id), :notice => "Transcripts successfully analysed and saved!!"
    else
      render :new, :alert => "Error(s) preventing transcripts to be saved!"
    end
  end

  def show
    @user = current_user
    @report = Report.find(params[:id])
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