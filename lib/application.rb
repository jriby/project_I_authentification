require 'active_record'

class Application < ActiveRecord::Base

  has_many :utilisations
  has_many :user, :through => :utilisations

  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :name, :format => { :with => /^[a-z0-9_-]{2,}$/i, :on => :create }

  validates :url, :presence => true
  validates :url, :format => { :with => /^https?:\/\/[a-z0-9._\/-]+\.[a-z]{2,3}/i, :on => :create }

  validates :user, :presence => true

end
