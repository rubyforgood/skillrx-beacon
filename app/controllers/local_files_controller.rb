class LocalFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_local_file, only: [ :show ]

  def index
    @local_files = LocalFile.includes(:admin, file_attachment: :blob)
                            .order(:folder_path, :created_at)
    @folders = @local_files.group_by(&:folder_path).sort
  end

  def show
    unless @local_file.file.attached?
      redirect_to local_files_path, alert: "File not found."
      return
    end

    log_user_activity("view_local_file", file_type: @local_file.file.content_type)

    redirect_to rails_blob_path(@local_file.file, disposition: "inline"), allow_other_host: true
  end

  private

  def set_local_file
    @local_file = LocalFile.find(params[:id])
  end
end
