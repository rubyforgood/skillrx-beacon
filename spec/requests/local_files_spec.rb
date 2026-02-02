require "rails_helper"

RSpec.describe "LocalFiles", type: :request do
  let!(:user) { create(:user) }
  let!(:admin) { create(:admin) }

  describe "GET /local_files" do
    context "when not authenticated" do
      it "redirects to login" do
        get local_files_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { post login_path, params: { login_id: user.login_id } }

      it "returns http success" do
        get local_files_path
        expect(response).to have_http_status(:success)
      end

      it "displays empty state when no files" do
        get local_files_path
        expect(response.body).to include("No local files available")
      end

      it "lists uploaded files" do
        local_file = create(:local_file, admin: admin)
        local_file.file.attach(
          io: StringIO.new("test content"),
          filename: "test.txt",
          content_type: "text/plain"
        )

        get local_files_path
        expect(response.body).to include("test.txt")
      end

      it "groups files by folder" do
        file1 = create(:local_file, admin: admin, folder_path: "/folder1")
        file1.file.attach(io: StringIO.new("content"), filename: "file1.txt", content_type: "text/plain")

        file2 = create(:local_file, admin: admin, folder_path: "/folder2")
        file2.file.attach(io: StringIO.new("content"), filename: "file2.txt", content_type: "text/plain")

        get local_files_path
        expect(response.body).to include("/folder1")
        expect(response.body).to include("/folder2")
      end
    end
  end

  describe "GET /local_files/:id" do
    let!(:local_file) do
      file = create(:local_file, admin: admin)
      file.file.attach(
        io: StringIO.new("test content"),
        filename: "test.txt",
        content_type: "text/plain"
      )
      file
    end

    context "when not authenticated" do
      it "redirects to login" do
        get local_file_path(local_file)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { post login_path, params: { login_id: user.login_id } }

      it "redirects to the file" do
        get local_file_path(local_file)
        expect(response).to have_http_status(:redirect)
      end

      it "logs user activity" do
        expect {
          get local_file_path(local_file)
        }.to change(UserActivityLog, :count).by(1)
        expect(UserActivityLog.last.action_type).to eq("view_local_file")
      end
    end
  end
end
