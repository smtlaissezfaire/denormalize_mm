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
  end

  describe "denormalizing an association" do
    it "should be able to denormalize an association" do
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
  end
end