Geocoder.configure(
  ip_lookup: :geoip2,
  geoip2: {
    lib: "maxminddb",
    file: Rails.root.join("data", "GeoLite2-Country.mmdb")
  }
)
