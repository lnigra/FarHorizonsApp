class GroundTrack
  include MongoMapper::Document

  key :source_id, String
  key :no_edit, Boolean, :default => true
  
  belongs_to :chase_vehicle
  
  has_many :points
  
  timestamps!

  def add_point point
    points << point
    self
  end

end
