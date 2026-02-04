require "rails_helper"

RSpec.describe "Admin::LocalFiles", type: :request do
  let!(:admin) { create(:admin) }

  def sign_in_admin
    post admin_login_path, params: { login_id: admin.login_id, password: "password123" }
  end

  describe "GET /admin/local_files" do
    context "when not authenticated" do
      it "redirects to admin login" do
        get admin_local_files_path
        expect(response).to redirect_to(admin_login_path)
      end
    end

    context "when authenticated" do
      before { sign_in_admin }

      it "returns http success" do
        get admin_local_files_path
        expect(response).to have_http_status(:success)
      end

      it "displays empty state when no files" do
        get admin_local_files_path
        expect(response.body).to include("No files uploaded yet")
      end

      it "lists uploaded files" do
        local_file = create(:local_file, admin: admin)
        local_file.file.attach(
          io: StringIO.new("test content"),
          filename: "test.txt",
          content_type: "text/plain"
        )

        get admin_local_files_path
        expect(response.body).to include("test.txt")
      end
    end
  end

  describe "GET /admin/local_files/new" do
    context "when not authenticated" do
      it "redirects to admin login" do
        get new_admin_local_file_path
        expect(response).to redirect_to(admin_login_path)
      end
    end

    context "when authenticated" do
      before { sign_in_admin }

      it "returns http success" do
        get new_admin_local_file_path
        expect(response).to have_http_status(:success)
      end

      it "displays upload form" do
        get new_admin_local_file_path
        expect(response.body).to include("Upload Files")
      end
    end
  end

  describe "POST /admin/local_files" do
    before { sign_in_admin }

    context "with valid file" do
      let(:file) do
        Rack::Test::UploadedFile.new(
          StringIO.new("test content"),
          "text/plain",
          original_filename: "test.txt"
        )
      end

      it "creates a new local file" do
        expect {
          post admin_local_files_path, params: { files: [ file ], folder_path: "/uploads" }
        }.to change(LocalFile, :count).by(1)
      end

      it "redirects to index with success message" do
        post admin_local_files_path, params: { files: [ file ], folder_path: "/uploads" }
        expect(response).to redirect_to(admin_local_files_path)
        follow_redirect!
        expect(response.body).to include("Successfully uploaded")
      end

      it "logs admin activity" do
        expect {
          post admin_local_files_path, params: { files: [ file ], folder_path: "/uploads" }
        }.to change(AdminActivityLog, :count).by(1)
      end
    end

    context "without files" do
      it "redirects with error message" do
        post admin_local_files_path, params: { folder_path: "/uploads" }
        expect(response).to redirect_to(new_admin_local_file_path)
      end
    end
  end

  describe "DELETE /admin/local_files/:id" do
    before { sign_in_admin }

    let!(:local_file) do
      file = create(:local_file, admin: admin)
      file.file.attach(
        io: StringIO.new("test content"),
        filename: "test.txt",
        content_type: "text/plain"
      )
      file
    end

    it "deletes the local file" do
      expect {
        delete admin_local_file_path(local_file)
      }.to change(LocalFile, :count).by(-1)
    end

    it "redirects to index with success message" do
      delete admin_local_file_path(local_file)
      expect(response).to redirect_to(admin_local_files_path)
    end

    it "logs admin activity" do
      expect {
        delete admin_local_file_path(local_file)
      }.to change(AdminActivityLog, :count).by(1)
    end

    it "responds to turbo_stream" do
      delete admin_local_file_path(local_file), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end
  end

  describe "DELETE /admin/local_files/destroy_folder" do
    before { sign_in_admin }

    let!(:local_file1) do
      file = create(:local_file, admin: admin, folder_path: "/test/folder")
      file.file.attach(io: StringIO.new("content1"), filename: "file1.txt", content_type: "text/plain")
      file
    end

    let!(:local_file2) do
      file = create(:local_file, admin: admin, folder_path: "/test/folder")
      file.file.attach(io: StringIO.new("content2"), filename: "file2.txt", content_type: "text/plain")
      file
    end

    it "deletes all files in the folder" do
      expect {
        delete destroy_folder_admin_local_files_path(folder_path: "/test/folder")
      }.to change(LocalFile, :count).by(-2)
    end

    it "redirects with success message" do
      delete destroy_folder_admin_local_files_path(folder_path: "/test/folder")
      expect(response).to redirect_to(admin_local_files_path)
      follow_redirect!
      expect(response.body).to include("Deleted folder")
    end
  end
end
