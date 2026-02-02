require "rails_helper"

RSpec.describe "Admin::Sessions", type: :request do
  describe "GET /admin/login" do
    it "returns http success" do
      get admin_login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/login" do
    let!(:admin) { create(:admin, login_id: "sysadmin", password: "password123") }

    context "with valid credentials" do
      it "signs in the admin and redirects to dashboard" do
        post admin_login_path, params: { login_id: "sysadmin", password: "password123" }
        expect(response).to redirect_to(admin_root_path)
        expect(session[:admin_id]).to eq(admin.id)
      end
    end

    context "with invalid credentials" do
      it "renders login form with error" do
        post admin_login_path, params: { login_id: "sysadmin", password: "wrong" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(session[:admin_id]).to be_nil
      end
    end
  end

  describe "DELETE /admin/logout" do
    let!(:admin) { create(:admin, login_id: "sysadmin", password: "password123") }

    it "signs out the admin" do
      post admin_login_path, params: { login_id: "sysadmin", password: "password123" }
      delete admin_logout_path
      expect(response).to redirect_to(admin_login_path)
      expect(session[:admin_id]).to be_nil
    end
  end
end
