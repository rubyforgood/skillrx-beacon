require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /signup" do
    it "returns http success" do
      get signup_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /signup" do
    context "with valid params" do
      let(:valid_params) { { user: { first_name: "John", last_name: "Doe" } } }

      it "creates a new user" do
        expect { post signup_path, params: valid_params }
          .to change(User, :count).by(1)
      end

      it "generates login_id from name" do
        post signup_path, params: valid_params
        expect(User.last.login_id).to eq("john.doe")
      end

      it "signs in the user and redirects" do
        post signup_path, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(session[:user_id]).to eq(User.last.id)
      end
    end

    context "with invalid params" do
      it "does not create user without first_name" do
        expect { post signup_path, params: { user: { last_name: "Doe" } } }
          .not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
