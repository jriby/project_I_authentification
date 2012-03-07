require 'active_record'
require 'digest/sha1'

class User < ActiveRecord::Base

  validates :login, :presence => true
  validates :login, :uniqueness => true
  validates :passwd, :presence => true


  def passwd=(passwd)
    unless passwd.nil?
    self[:passwd] = User.encrypt_password(passwd)
  end
end

  def self.encrypt_password(password)
    Digest::SHA1.hexdigest(password).inspect
  end

end

