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
    params = location_params.transform_keys(&:to_sym)
    latitude = params[:latitude] || params['latitude']
    longitude = params[:longitude] || params['longitude']
    radius = params[:radius] || params['radius']

    return none if latitude.to_s.strip.empty? || longitude.to_s.strip.empty? || radius.to_s.strip.empty?

    latitude = latitude.to_f
    longitude = longitude.to_f
    radius = radius.to_f

    where(sanitize_sql_array(["acos(
      sin(radians(?))
        * sin(radians(latitude))
      + cos(radians(?))
        * cos(radians(latitude))
        * cos(radians(?)- radians(longitude))
      ) * 3958.8 <= ?", latitude, latitude, longitude, radius]))
  end

  has_many :user_favorites, dependent: :destroy
  has_many :favorited_by, through: :user_favorites, source: :user
end