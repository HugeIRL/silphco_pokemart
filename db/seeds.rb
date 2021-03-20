require "rest-client"

Type.destroy_all
Creature.destroy_all

pokemon = []
description = []

# limit the amount of Pokemon to 25 for now. End goal is to get the original 151.
(1..25).each do |i|
  data = RestClient.get("https://pokeapi.co/api/v2/pokemon/#{i}")
  json_data = JSON.parse(data)
  pokemon.push(json_data)
  puts "GET data for Pokemon id #{i}"

  desc = RestClient.get("https://pokeapi.co/api/v2/pokemon-species/#{i}")
  json_desc = JSON.parse(desc)
  description.push(json_desc)
end

pokemon.each do |creature|
  type = Type.find_or_create_by(name: creature["types"][0]["type"]["name"])

  if type && type.valid?
    p = type.creatures.create(
      pokedex_id:  creature["id"],
      species:     creature["name"],
      description: description[creature["id"] - 1]["flavor_text_entries"][1]["flavor_text"],
      price_cents: rand(5000..100_000).to_i
    )
    puts "Creating #{p.species} with type #{p.type.name}"

    downloaded_image = URI.open("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{p.pokedex_id}.png")
    p.image.attach(io: downloaded_image, filename: "m-#{p.pokedex_id}.png")
    puts "Downloaded image for #{p.species}" if downloaded_image
  else
    puts "Invalid type #{p['type']} for pokemon #{p['species']}"
  end
end

puts "Created #{Type.count} types."
puts "Created #{Creature.count} pokemon."

if Rails.env.development?
  AdminUser.create!(email: "admin@silph.co", password: "teamrocket",
  password_confirmation: "teamrocket")
end
