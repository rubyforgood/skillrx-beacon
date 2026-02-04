class AudioPlayerController < ApplicationController
  include BrowserDetection

  before_action :set_topic_file
  before_action :verify_file_type

  def show
    unless @topic_file.file.attached?
      redirect_to audio_not_found_path and return
    end

    @topic = @topic_file.topic
    @is_favorite = user_signed_in? && current_user.favorites.exists?(topic: @topic)

    log_user_activity("view", topic: @topic, file_type: "mp3") if user_signed_in?
  end

  def stream
    unless @topic_file.file.attached?
      head :not_found and return
    end

    send_data @topic_file.file.download,
              type: @topic_file.file.content_type,
              disposition: "inline"
  end

  private

  def set_topic_file
    @topic_file = TopicFile.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to audio_not_found_path
  end

  def verify_file_type
    unless @topic_file.file_type == "mp3"
      redirect_to not_found_path
    end
  end
end
