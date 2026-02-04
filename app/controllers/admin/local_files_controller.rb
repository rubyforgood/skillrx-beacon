class Admin::LocalFilesController < Admin::BaseController
  before_action :set_local_file, only: [ :show, :destroy ]

  def index
    @local_files = LocalFile.includes(:admin, file_attachment: :blob)
                            .order(created_at: :desc)
    @folder_tree = build_folder_tree(@local_files)
  end

  def new
    @local_file = LocalFile.new
  end

  def create
    uploaded_files = Array(params[:files])

    if uploaded_files.empty?
      redirect_to new_admin_local_file_path, alert: "Please select at least one file to upload."
      return
    end

    success_count = 0
    error_count = 0

    uploaded_files.each do |file|
      local_file = LocalFile.new(
        admin: current_admin,
        folder_path: determine_folder_path(file, params[:folder_path])
      )
      local_file.file.attach(file)

      if local_file.save
        success_count += 1
      else
        error_count += 1
      end
    end

    log_admin_activity("upload", details: "Uploaded #{success_count} files")

    if error_count.zero?
      redirect_to admin_local_files_path, notice: "Successfully uploaded #{success_count} file(s)."
    else
      redirect_to admin_local_files_path,
                  alert: "Uploaded #{success_count} file(s), but #{error_count} failed."
    end
  end

  def show
    unless @local_file.file.attached?
      redirect_to admin_local_files_path, alert: "File not found."
      return
    end

    redirect_to rails_blob_path(@local_file.file, disposition: "inline"), allow_other_host: true
  end

  def destroy
    filename = @local_file.file.filename.to_s if @local_file.file.attached?
    @local_file.destroy

    log_admin_activity("delete", details: "Deleted file: #{filename || 'unknown'}")

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("local_file_#{params[:id]}") }
      format.html { redirect_to admin_local_files_path, notice: "File deleted successfully." }
    end
  end

  def destroy_folder
    folder_path = params[:folder_path]
    files = LocalFile.where("folder_path LIKE ?", "#{folder_path}%")
    count = files.count
    files.destroy_all

    log_admin_activity("delete", details: "Deleted folder: #{folder_path} (#{count} files)")

    redirect_to admin_local_files_path, notice: "Deleted folder and #{count} file(s)."
  end

  private

  def set_local_file
    @local_file = LocalFile.find(params[:id])
  end

  def determine_folder_path(file, base_folder)
    base = base_folder.presence || "/"
    base = "/#{base}" unless base.start_with?("/")

    # Handle webkitRelativePath for directory uploads
    if file.respond_to?(:original_filename) && file.original_filename.include?("/")
      # Extract directory from the relative path
      relative_dir = File.dirname(file.original_filename)
      File.join(base, relative_dir)
    else
      base
    end
  end

  def build_folder_tree(local_files)
    tree = {}

    local_files.each do |file|
      path_parts = file.folder_path.split("/").reject(&:blank?)
      current = tree

      path_parts.each do |part|
        current[part] ||= { files: [], subfolders: {} }
        current = current[part][:subfolders]
      end
    end

    tree
  end
end
