class Market < ActiveRecord::Base
  def self.accepts_benefits
    where('fnap IS NOT NULL OR snap_option IS NOT NULL')
  end

  def self.snap_available
    where('snap_option IS NOT NULL')
  end

  def self.fnap_available
    where('fnap IS NOT NULL')
  end

  def self.nearby_markets(location_params)    
    where("acos(
      sin(radians(#{location_params[:latitude]})) 
        * sin(radians(latitude)) 
      + cos(radians(#{location_params[:latitude]})) 
        * cos(radians(latitude)) 
        * cos(radians(#{location_params[:longitude]})
          - radians(longitude))
      ) * 3958.8 <= #{location_params[:radius]}")
  end

  has_many :user_favorites, dependent: :destroy
  has_many :favorited_by, through: :user_favorites, source: :user
end