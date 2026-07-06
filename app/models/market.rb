class Market < ActiveRecord::Base
  MAX_RADIUS_MILES = 500
  MIN_LATITUDE = -90
  MAX_LATITUDE = 90
  MIN_LONGITUDE = -180
  MAX_LONGITUDE = 180

  has_many :user_favorites, dependent: :destroy
  has_many :favorited_by, through: :user_favorites, source: :user

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

    return none if latitude < MIN_LATITUDE || latitude > MAX_LATITUDE
    return none if longitude < MIN_LONGITUDE || longitude > MAX_LONGITUDE
    return none if radius <= 0

    radius = MAX_RADIUS_MILES if radius > MAX_RADIUS_MILES

    where(sanitize_sql_array(["acos(
      sin(radians(?))
        * sin(radians(latitude))
      + cos(radians(?))
        * cos(radians(latitude))
        * cos(radians(?)- radians(longitude))
      ) * 3958.8 <= ?", latitude, latitude, longitude, radius]))
  end

  def self.market_by_address(location_params)
    params = location_params.transform_keys(&:to_sym)

    address_line1 = params[:addressLine1]
    city = params[:city]
    state = params[:state]
    zip_code = params[:zipCode]

    return none if [address_line1, city, state, zip_code].all? { |p| p.to_s.strip.empty? }

    conditions = []
    values = []

    if address_line1.present?
      conditions << "address ILIKE ?"
      values << "%#{escape_like(address_line1.strip)}%"
    end
    if city.present?
      conditions << "address ILIKE ?"
      values << "%#{escape_like(city.strip)}%"
    end
    if state.present?
      conditions << "address ILIKE ?"
      values << "%, #{escape_like(state.strip)}%"
    end
    if zip_code.present?
      conditions << "address ILIKE ?"
      values << "%#{escape_like(zip_code.strip)}%"
    end

    where(sanitize_sql_array([conditions.join(" AND "), *values]))
  end

  def self.market_by_name(location_params)
    params = location_params.transform_keys(&:to_sym)
    name = params[:name]

    return none if name.to_s.strip.empty?

    where(sanitize_sql_array([
      "LOWER(name) LIKE ?",
      "%#{escape_like(name.to_s.strip.downcase)}%"
    ]))
  end

  def self.escape_like(string)
    string.gsub(/[%_\\]/) { |char| "\\#{char}" }
  end
end