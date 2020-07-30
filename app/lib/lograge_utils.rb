module LogrageUtils
  class << self
    def custom_payload_for(controller)
      requester_ip = controller.request.remote_ip
      requester_location = Geocoder.search(requester_ip).first.country
      {
        requester_ip: requester_ip,
        requester_location: "'#{requester_location}'"
      }
    end
  end
end
