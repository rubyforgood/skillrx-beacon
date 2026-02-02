require "rails_helper"

RSpec.describe "AudioPlayer", type: :request do
  let!(:content_provider) { create(:content_provider) }
  let!(:topic) { create(:topic, content_provider: content_provider) }
  let!(:mp3_file) { create(:topic_file, topic: topic, file_type: "mp3") }
  let!(:pdf_file) { create(:topic_file, topic: topic, file_type: "pdf") }

  describe "GET /topic_files/:id/audio" do
    context "with mp3 file" do
      it "redirects to audio_not_found when file not attached" do
        get audio_topic_file_path(mp3_file)
        expect(response).to redirect_to(audio_not_found_path)
      end
    end

    context "with non-mp3 file" do
      it "redirects to not_found" do
        get audio_topic_file_path(pdf_file)
        expect(response).to redirect_to(not_found_path)
      end
    end
  end
end
