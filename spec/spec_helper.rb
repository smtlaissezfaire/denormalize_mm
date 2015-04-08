require File.dirname(__FILE__) + "/../lib/mongo_mapper/denormalization"

class Region
  include MongoMapper::Document

  key :region, String

  has_many :users

  timestamps!
end

class User
  include MongoMapper::Document

  key :first_name, String
  key :last_name, String
  key :admin, Boolean
  key :registered_at, Time

  belongs_to :region
  has_many :posts

  timestamps!
end

class Post
  include MongoMapper::Document
  include MongoMapper::Denormalization

  key :user_first_name, String
  key :user_admin, Boolean
  key :user_registered_at, Time

  belongs_to :user
  belongs_to :region
  has_many :comments

  timestamps!

  denormalize_field :user, :first_name
  denormalize_field :user, :admin
  denormalize_field :user, :registered_at

  # Denormalize this once on create but don't update it later on
  denormalize_association :region, :from => :user, :on => :create, :reflect_updates => false

  attr_accessor :callback_chain_complete

  validate :run_callback_chain_complete

  def run_callback_chain_complete
    @callback_chain_complete = true
  end
end

class Comment
  include MongoMapper::Document
  include MongoMapper::Denormalization

  belongs_to :post
  belongs_to :user
  belongs_to :post_user, :class_name => "User"
  has_many :favorites

  key :user_first_name, String

  denormalize_field :user, :first_name
  denormalize_association :user, :from => :post, :target_field => :post_user
end

class Favorite
  include MongoMapper::Document
  include MongoMapper::Denormalization

  belongs_to :comment
  belongs_to :user
  belongs_to :post

  denormalize_associations :user, :post, :from => :comment
end


module Namespace
  class Comment
    include MongoMapper::Document
    include MongoMapper::Denormalization

    belongs_to :user
    belongs_to :post

    key :user_first_name, String

    denormalize_association :user, :from => :post
    denormalize_field :user, :first_name
  end
end

RSpec.configure do |config|
  def wipe_db
    MongoMapper.database.collections.each do |c|
      unless (c.name =~ /system/)
        c.remove({})
      end
    end
  end

  config.before(:all) do
    MongoMapper.connection = Mongo::Connection.new('localhost')
    MongoMapper.database = "denormalize_mm"
  end

  config.before(:each) do
    wipe_db
  end
end
