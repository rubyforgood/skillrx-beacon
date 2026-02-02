require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    let!(:user) { create(:user, first_name: "John", last_name: "Doe") }

    context "with valid login_id" do
      it "signs in the user and redirects" do
        post login_path, params: { login_id: user.login_id }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(session[:user_id]).to eq(user.id)
      end

      it "increments login count" do
        expect { post login_path, params: { login_id: user.login_id } }
          .to change { user.reload.login_count }.by(1)
      end
    end

    context "with invalid login_id" do
      it "renders login form with error" do
        post login_path, params: { login_id: "invalid.user" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /logout" do
    let!(:user) { create(:user) }

    it "signs out the user" do
      post login_path, params: { login_id: user.login_id }
      delete logout_path
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to be_nil
    end
  end
end
