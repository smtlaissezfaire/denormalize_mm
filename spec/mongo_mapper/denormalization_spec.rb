require 'spec_helper'

describe MongoMapper::Denormalization do
  describe "dealing with (non-UTC) ActiveSupport::TimeWithZone objects" do
    it "should work" do
      # Setting Time.zone converts all MongoMapper times into TimeWithZone objects
      Time.zone = "Pacific Time (US & Canada)"

      time_1 = Time.now
      time_2 = time_1 + 2.hours

      user = User.create!({
        :registered_at => time_1,
        :first_name => "Andrew"
      })

      post = user.posts.create!

      post.user.registered_at.to_i.should == time_1.to_i
      post.user_registered_at.to_i.should == time_1.to_i

      user.registered_at = time_2
      # This used to raise the following error when we didn't call .utc on TimeWithZone objects in the reverse-denormalization hook.
      # Error was: #<BSON::InvalidDocument: ActiveSupport::TimeWithZone is not currently supported; use a UTC Time instance instead.>
      expect { user.save! }.not_to raise_error

      post.reload
      post.user.registered_at.to_i.should == time_2.to_i
      post.user_registered_at.to_i.should == time_2.to_i
    end
  end

  describe "denormalizing a field" do
    it "should be able to denormalize a field" do
      user = User.new({
        :first_name => "Scott"
      })
      user.save!

      post = user.posts.build(:user => user)
      post.save!

      post.user_first_name.should == "Scott"
    end

    it "should not cancel the callback chain even if the value is false" do
      user = User.new({
        :admin => false
      })
      user.save!

      post = user.posts.build(:user => user)
      post.save!
      post.callback_chain_complete.should be_true
    end

    it "should update other models when the original field is denormalized" do
      user = User.new({
        :first_name => "Scott"
      })
      user.save!

      post = user.posts.build(:user => user)
      post.save!

      post_updated_at = post.updated_at
      post.updated_at.should == post_updated_at

      post.user_first_name.should == "Scott"

      user.reload
      user.first_name = "Andrew"
      user.save!

      post.reload
      post.user.first_name.should == "Andrew"
      post.user_first_name.should == "Andrew"
    end
  end

  describe "denormalizing association(s)" do
    it "should be able to denormalize one association" do
      user = User.new({
        :first_name => "Scott"
      })
      user.save!

      post = user.posts.build(:user => user)
      post.save!

      comment = post.comments.build({
        :post => post,
        :user => user,
      })
      comment.save!

      comment.post_user.should == user
    end

    it "should be able to denormalize multiple associations" do
      user = User.new({
        :first_name => "Scott"
      })
      user.save!

      post = user.posts.build(:user => user)
      post.save!

      comment = post.comments.build({
        :post => post,
        :user => user,
      })
      comment.save!

      favorite = comment.favorites.build
      favorite.save!

      favorite.user.should == user
      favorite.post.should == post
    end

    it "should update the other model when updating the original field" do
      user = User.new({
        :first_name => "Scott"
      })
      user.save!

      user2 = User.new({
        :first_name => "Andrew"
      })
      user2.save!

      post = user.posts.build(:user => user)
      post.save!

      comment = post.comments.build({
        :post => post,
        :user => user,
      })
      comment.save!

      post.user = user2
      post.save!

      comment.reload
      comment.post_user.should == user2
    end

    it "should not update the other model when updating the original field with :reflect_updates => false" do
      region = Region.create!({
        :region => "San Francisco, CA",
      })

      user = User.create!({
        :region => region,
        :first_name => "Andrew",
      })

      post = user.posts.create!

      post.user.should == user
      post.region.should == region

      new_region = Region.create!({
        :region => "Los Angeles, CA",
      })

      user.region = new_region
      user.save!

      # Region should not be updated by reflection
      post.reload
      post.region.should == region

      # Region should not be updated in validation because of :on => :create
      post.should be_valid
      post.region.should == region
    end
  end

  describe "namespaces" do
    it "should work with a namespace" do
      user = User.new({
        :first_name => "Andrew"
      })
      user.save!

      post = user.posts.build(:user => user)
      post.save!

      comment = Namespace::Comment.new({
        :post => post,
      })
      comment.save!

      comment.post.should == post
      comment.user.should == user
      comment.user_first_name.should == "Andrew"
    end
  end
end
