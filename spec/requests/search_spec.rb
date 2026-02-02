require "rails_helper"

RSpec.describe "Search", type: :request do
  let!(:content_provider) { create(:content_provider) }
  let!(:topic) { create(:topic, title: "Diabetes Management", content_provider: content_provider) }
  let!(:tag) { create(:tag, name: "diabetes") }
  let!(:author) { create(:author, name: "Dr. Smith") }

  before do
    topic.tags << tag
    topic.authors << author
  end

  describe "GET /search" do
    it "returns http success" do
      get search_path
      expect(response).to have_http_status(:success)
    end

    it "displays search form" do
      get search_path
      expect(response.body).to include("Search")
    end

    context "with query parameter" do
      it "returns matching topics by title" do
        get search_path, params: { q: "Diabetes" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Diabetes Management")
      end

      it "returns matching topics by tag" do
        get search_path, params: { q: "diabetes" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Diabetes Management")
      end

      it "returns matching topics by author" do
        get search_path, params: { q: "Smith" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Diabetes Management")
      end

      it "shows no results message when no matches" do
        get search_path, params: { q: "nonexistent" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("No results found")
      end
    end

    context "without query parameter" do
      it "shows popular tags" do
        get search_path
        expect(response.body).to include("Popular Tags")
      end
    end
  end

  describe "GET /search/autocomplete" do
    it "returns json response" do
      get search_autocomplete_path, params: { q: "dia" }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")
    end

    it "returns tag suggestions" do
      get search_autocomplete_path, params: { q: "dia" }
      json = JSON.parse(response.body)
      expect(json).to include(hash_including("type" => "tag", "value" => "diabetes"))
    end

    it "returns topic suggestions" do
      get search_autocomplete_path, params: { q: "Diabetes" }
      json = JSON.parse(response.body)
      expect(json).to include(hash_including("type" => "topic", "value" => "Diabetes Management"))
    end

    it "returns author suggestions" do
      get search_autocomplete_path, params: { q: "Smith" }
      json = JSON.parse(response.body)
      expect(json).to include(hash_including("type" => "author", "value" => "Dr. Smith"))
    end

    it "returns empty array for short queries" do
      get search_autocomplete_path, params: { q: "d" }
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end

    it "returns empty array for blank query" do
      get search_autocomplete_path, params: { q: "" }
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end

  describe "GET /search/results" do
    it "returns http success" do
      get search_results_path, params: { q: "Diabetes" }
      expect(response).to have_http_status(:success)
    end

    it "shows search results" do
      get search_results_path, params: { q: "Diabetes" }
      expect(response.body).to include("Diabetes Management")
    end

    it "shows results count" do
      get search_results_path, params: { q: "Diabetes" }
      expect(response.body).to include("1 results")
    end
  end

  describe "search logging" do
    let(:user) { create(:user) }

    it "logs search when user is signed in" do
      post login_path, params: { login_id: user.login_id }
      expect {
        get search_path, params: { q: "Diabetes" }
      }.to change(UserActivityLog, :count).by(1)
    end

    it "does not log search when user is not signed in" do
      expect {
        get search_path, params: { q: "Diabetes" }
      }.not_to change(UserActivityLog, :count)
    end
  end
end
