require File.dirname(__FILE__) + "/../lib/mongo_mapper/denormalization"

class User
  include MongoMapper::Document

  key :first_name, String
  key :last_name, String
  key :admin, Boolean

  has_many :posts

  timestamps!
end

class Post
  include MongoMapper::Document
  include MongoMapper::Denormalization

  key :user_first_name, String
  key :user_admin, Boolean

  belongs_to :user
  has_many :comments

  timestamps!

  denormalize_field :user, :first_name
  denormalize_field :user, :admin

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

  key :user_first_name, String

  denormalize_field :user, :first_name
  denormalize_association :user, :from => :post, :target_field => :post_user
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
