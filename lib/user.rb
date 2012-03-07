require 'active_record'
require 'digest/sha1'

class User < ActiveRecord::Base

  has_many :utilisations
  has_many :applications, :through => :utilisations

  validates :login, :presence => true
  validates :login, :uniqueness => true
  validates :passwd, :presence => true
   


  def passwd=(passwd)
    if !passwd.empty?
    self[:passwd] = User.encrypt_password(passwd)
    else
    self[:passwd] = nil
  end
end

  def self.encrypt_password(password)
    Digest::SHA1.hexdigest(password).inspect
  end

end

