require "rails_helper"

RSpec.describe "PdfViewer", type: :request do
  let!(:content_provider) { create(:content_provider) }
  let!(:topic) { create(:topic, content_provider: content_provider) }
  let!(:pdf_file) { create(:topic_file, topic: topic, file_type: "pdf") }
  let!(:mp3_file) { create(:topic_file, topic: topic, file_type: "mp3") }

  describe "GET /topic_files/:id/pdf" do
    context "with pdf file" do
      it "redirects to pdf_not_found when file not attached" do
        get pdf_topic_file_path(pdf_file)
        expect(response).to redirect_to(pdf_not_found_path)
      end
    end

    context "with non-pdf file" do
      it "redirects to not_found" do
        get pdf_topic_file_path(mp3_file)
        expect(response).to redirect_to(not_found_path)
      end
    end
  end
end
