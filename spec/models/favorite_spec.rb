require "rails_helper"

RSpec.describe Favorite, type: :model do
  let(:user) { create(:user) }
  let(:content_provider) { create(:content_provider) }
  let(:topic) { create(:topic, content_provider: content_provider) }

  describe "associations" do
    it "belongs to user" do
      favorite = Favorite.new(user: user, topic: topic)
      expect(favorite.user).to eq(user)
    end

    it "belongs to topic" do
      favorite = Favorite.new(user: user, topic: topic)
      expect(favorite.topic).to eq(topic)
    end
  end

  describe "validations" do
    it "requires user" do
      favorite = Favorite.new(topic: topic)
      expect(favorite).not_to be_valid
    end

    it "requires topic" do
      favorite = Favorite.new(user: user)
      expect(favorite).not_to be_valid
    end

    it "prevents duplicate favorites for same user and topic" do
      Favorite.create!(user: user, topic: topic)
      duplicate = Favorite.new(user: user, topic: topic)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "allows same topic to be favorited by different users" do
      other_user = create(:user)
      Favorite.create!(user: user, topic: topic)
      favorite = Favorite.new(user: other_user, topic: topic)
      expect(favorite).to be_valid
    end

    it "allows same user to favorite different topics" do
      other_topic = create(:topic, content_provider: content_provider)
      Favorite.create!(user: user, topic: topic)
      favorite = Favorite.new(user: user, topic: other_topic)
      expect(favorite).to be_valid
    end
  end
end
