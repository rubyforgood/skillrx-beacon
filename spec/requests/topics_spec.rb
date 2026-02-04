require "rails_helper"

RSpec.describe "Topics", type: :request do
  let!(:content_provider) { create(:content_provider) }
  let!(:topic) { create(:topic, content_provider: content_provider) }

  describe "GET /topics" do
    it "returns http success" do
      get topics_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /topics/:id" do
    it "returns http success" do
      get topic_path(topic)
      expect(response).to have_http_status(:success)
    end

    it "increments view count" do
      expect { get topic_path(topic) }.to change { topic.reload.view_count }.by(1)
    end
  end

  describe "GET /topics/by_year" do
    it "returns http success" do
      get by_year_topics_path(year: topic.year)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /topics/new_uploads" do
    it "returns http success" do
      get new_uploads_topics_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /topics/top_topics" do
    it "returns http success" do
      get top_topics_topics_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /topics/favorites" do
    context "when not authenticated" do
      it "redirects to login" do
        get favorites_topics_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      let!(:user) { create(:user) }

      before { post login_path, params: { login_id: user.login_id } }

      it "returns http success" do
        get favorites_topics_path
        expect(response).to have_http_status(:success)
      end

      it "displays user's favorited topics" do
        user.favorites.create(topic: topic)
        get favorites_topics_path
        expect(response.body).to include(topic.title)
      end

      it "shows empty state when no favorites" do
        get favorites_topics_path
        expect(response.body).to include("You haven't added any favorites yet")
      end

      it "does not show other users' favorites" do
        other_user = create(:user)
        other_user.favorites.create(topic: topic)
        get favorites_topics_path
        expect(response.body).not_to include(topic.title)
      end
    end
  end

  describe "POST /topics/:id/toggle_favorite" do
    let!(:user) { create(:user) }

    context "when not authenticated" do
      it "redirects to login" do
        post toggle_favorite_topic_path(topic)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { post login_path, params: { login_id: user.login_id } }

      it "creates a favorite" do
        expect { post toggle_favorite_topic_path(topic) }
          .to change { user.favorites.count }.by(1)
      end

      it "removes a favorite when already favorited" do
        user.favorites.create(topic: topic)
        expect { post toggle_favorite_topic_path(topic) }
          .to change { user.favorites.count }.by(-1)
      end

      it "logs activity when adding favorite" do
        expect { post toggle_favorite_topic_path(topic) }
          .to change(UserActivityLog, :count).by(1)
        expect(UserActivityLog.last.action_type).to eq("favorite")
      end

      it "logs activity when removing favorite" do
        user.favorites.create(topic: topic)
        expect { post toggle_favorite_topic_path(topic) }
          .to change(UserActivityLog, :count).by(1)
        expect(UserActivityLog.last.action_type).to eq("unfavorite")
      end

      it "responds with turbo_stream when requested" do
        post toggle_favorite_topic_path(topic), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
        expect(response.body).to include("turbo-stream")
      end

      it "redirects to topic for html requests" do
        post toggle_favorite_topic_path(topic)
        expect(response).to redirect_to(topic)
      end
    end
  end
end
