json.array!(@platforms) do |platform|
  json.extract! platform, :description, :identifier, :beacon_ids, :platform_server_id :sky_tracks
  json.url platform_url(platform, format: :json)
end
