require 'active_record'

class Person < ActiveRecord::Base

validates :login, :presence => true
validates :login, :uniqueness => true
validates :passwd, :presence => true


has_one :office

end
