require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  let!(:admin) { create(:admin, login_id: "sysadmin", password: "password123") }

  def sign_in_admin
    post admin_login_path, params: { login_id: "sysadmin", password: "password123" }
  end

  describe "GET /admin" do
    context "when not authenticated" do
      it "redirects to login" do
        get admin_root_path
        expect(response).to redirect_to(admin_login_path)
      end
    end

    context "when authenticated" do
      before { sign_in_admin }

      it "returns http success" do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end

      it "displays the dashboard" do
        get admin_root_path
        expect(response.body).to include("Dashboard")
      end

      it "shows overview statistics" do
        create_list(:user, 3)
        get admin_root_path
        expect(response.body).to include("Total Users")
        expect(response.body).to include("3")
      end

      it "accepts period parameter" do
        get admin_root_path(period: 7)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("7 days")
      end

      it "shows activity summary" do
        get admin_root_path
        expect(response.body).to include("Activity Summary")
      end

      it "shows top users section" do
        get admin_root_path
        expect(response.body).to include("Top Active Users")
      end

      it "shows hot topics section" do
        get admin_root_path
        expect(response.body).to include("Most Viewed Topics")
      end

      it "shows popular searches section" do
        get admin_root_path
        expect(response.body).to include("Popular Searches")
      end
    end
  end

  describe "GET /admin/activity_log" do
    context "when not authenticated" do
      it "redirects to login" do
        get admin_activity_log_path
        expect(response).to redirect_to(admin_login_path)
      end
    end

    context "when authenticated" do
      before { sign_in_admin }

      it "returns http success" do
        get admin_activity_log_path
        expect(response).to have_http_status(:success)
      end

      it "displays activity log" do
        get admin_activity_log_path
        expect(response.body).to include("User Activity Log")
      end

      it "shows activity entries" do
        user = create(:user)
        UserActivityLog.create!(user: user, action_type: "login", ip_address: "127.0.0.1")

        get admin_activity_log_path
        expect(response.body).to include(user.first_name)
        expect(response.body).to include("Login")
      end
    end
  end

  describe "GET /admin/admin_log" do
    context "when not authenticated" do
      it "redirects to login" do
        get admin_admin_log_path
        expect(response).to redirect_to(admin_login_path)
      end
    end

    context "when authenticated" do
      before { sign_in_admin }

      it "returns http success" do
        get admin_admin_log_path
        expect(response).to have_http_status(:success)
      end

      it "displays admin activity log" do
        get admin_admin_log_path
        expect(response.body).to include("Admin Activity Log")
      end

      it "shows admin activity entries" do
        AdminActivityLog.create!(admin: admin, action_type: "upload", details: "Uploaded test file", ip_address: "127.0.0.1")

        get admin_admin_log_path
        expect(response.body).to include(admin.first_name)
        expect(response.body).to include("Uploaded test file")
      end
    end
  end
end
