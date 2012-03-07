require 'active_record'

class User < ActiveRecord::Base

validates :login, :presence => true
validates :login, :uniqueness => true
validates :passwd, :presence => true

end
