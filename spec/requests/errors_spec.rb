require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "GET /errors/not_found" do
    it "returns 404 status" do
      get not_found_path
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /errors/audio_not_found" do
    it "returns 404 status" do
      get audio_not_found_path
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /errors/pdf_not_found" do
    it "returns 404 status" do
      get pdf_not_found_path
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /errors/unsupported_browser" do
    it "returns http success" do
      get unsupported_browser_path
      expect(response).to have_http_status(:success)
    end
  end
end
