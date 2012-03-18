require 'active_record'

class Utilisation < ActiveRecord::Base

  belongs_to :application # foreign key - application_id
  belongs_to :user # foreign key - user_id

  validates :user_id, :presence => true

  validates :application_id, :presence => true


end
