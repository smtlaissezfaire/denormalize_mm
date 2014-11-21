require 'spec_helper'

describe MongoMapper::Denormalization do
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
