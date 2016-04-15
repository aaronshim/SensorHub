json.array!(@entries) do |entry|
  json.extract! entry, :id, :data, :sensor_name
  json.url entry_url(entry, format: :json)
end
