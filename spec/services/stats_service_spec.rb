require "rails_helper"

RSpec.describe StatsService do
  let(:service) { described_class.new(days: 30) }
  let!(:admin) { create(:admin) }
  let!(:content_provider) { create(:content_provider) }
  let!(:users) { create_list(:user, 3) }
  let!(:topics) { create_list(:topic, 5, content_provider: content_provider) }

  describe "#overview" do
    it "returns total counts" do
      result = service.overview

      expect(result[:total_users]).to eq(3)
      expect(result[:total_topics]).to eq(5)
    end
  end

  describe "#activity_summary" do
    before do
      users.each do |user|
        UserActivityLog.create!(user: user, action_type: "login", ip_address: "127.0.0.1")
        UserActivityLog.create!(user: user, action_type: "view", topic: topics.first, ip_address: "127.0.0.1")
      end
      UserActivityLog.create!(user: users.first, action_type: "search", search_term: "test", ip_address: "127.0.0.1")
    end

    it "returns activity counts" do
      result = service.activity_summary

      expect(result[:total_activities]).to eq(7)
      expect(result[:logins]).to eq(3)
      expect(result[:views]).to eq(3)
      expect(result[:searches]).to eq(1)
      expect(result[:unique_users]).to eq(3)
    end
  end

  describe "#top_users" do
    before do
      UserActivityLog.create!(user: users.first, action_type: "login", ip_address: "127.0.0.1")
      UserActivityLog.create!(user: users.first, action_type: "view", topic: topics.first, ip_address: "127.0.0.1")
      UserActivityLog.create!(user: users.first, action_type: "view", topic: topics.second, ip_address: "127.0.0.1")
      UserActivityLog.create!(user: users.second, action_type: "login", ip_address: "127.0.0.1")
    end

    it "returns users ordered by activity count" do
      result = service.top_users(limit: 10)

      expect(result.first).to eq(users.first)
      expect(result.first.activity_count).to eq(3)
    end
  end

  describe "#hot_topics" do
    before do
      topics.first.update!(view_count: 100)
      topics.second.update!(view_count: 50)
    end

    it "returns topics ordered by view count" do
      result = service.hot_topics(limit: 2)

      expect(result.first).to eq(topics.first)
      expect(result.second).to eq(topics.second)
    end
  end

  describe "#popular_searches" do
    before do
      3.times { UserActivityLog.create!(user: users.first, action_type: "search", search_term: "diabetes", search_found: true, ip_address: "127.0.0.1") }
      2.times { UserActivityLog.create!(user: users.first, action_type: "search", search_term: "heart", search_found: true, ip_address: "127.0.0.1") }
      1.times { UserActivityLog.create!(user: users.first, action_type: "search", search_term: "cancer", search_found: false, ip_address: "127.0.0.1") }
    end

    it "returns search terms ordered by frequency" do
      result = service.popular_searches(limit: 10)

      expect(result.keys.first).to eq("diabetes")
      expect(result["diabetes"]).to eq(3)
    end
  end

  describe "#failed_searches" do
    before do
      2.times { UserActivityLog.create!(user: users.first, action_type: "search", search_term: "nonexistent", search_found: false, ip_address: "127.0.0.1") }
      1.times { UserActivityLog.create!(user: users.first, action_type: "search", search_term: "missing", search_found: false, ip_address: "127.0.0.1") }
      1.times { UserActivityLog.create!(user: users.first, action_type: "search", search_term: "found", search_found: true, ip_address: "127.0.0.1") }
    end

    it "returns only failed searches" do
      result = service.failed_searches(limit: 10)

      expect(result).to include("nonexistent" => 2)
      expect(result).to include("missing" => 1)
      expect(result).not_to include("found")
    end
  end

  describe "#logins_per_day" do
    before do
      UserActivityLog.create!(user: users.first, action_type: "login", ip_address: "127.0.0.1", created_at: 1.day.ago)
      UserActivityLog.create!(user: users.second, action_type: "login", ip_address: "127.0.0.1", created_at: 1.day.ago)
      UserActivityLog.create!(user: users.first, action_type: "login", ip_address: "127.0.0.1", created_at: Date.current)
    end

    it "groups logins by day" do
      result = service.logins_per_day

      expect(result.values.sum).to eq(3)
    end
  end

  describe "#content_by_provider" do
    it "returns topics grouped by provider" do
      result = service.content_by_provider

      expect(result[content_provider.name]).to eq(5)
    end
  end
end
