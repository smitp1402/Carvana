puts "Seeding vehicles..."

vehicles = [
  {
    make: "Honda",
    model: "Accord EX-L",
    year: 2024,
    price: 28990,
    mileage: 14200,
    color: "Sonic Gray Pearl",
    stock_no: "CV-84729",
    featured: true,
    description: "One-owner vehicle with Honda Sensing suite, heated front seats, Apple CarPlay, Android Auto, and a moonroof. Clean Carfax, non-smoker vehicle. Recently serviced."
  },
  {
    make: "Toyota",
    model: "Camry XSE",
    year: 2023,
    price: 31450,
    mileage: 22800,
    color: "Midnight Black Metallic",
    stock_no: "CV-91023",
    featured: true,
    description: "Sporty XSE trim with V6 engine, sport-tuned suspension, JBL audio, wireless charging, and blind spot monitoring. Dealer maintained with full service records."
  },
  {
    make: "Ford",
    model: "Mustang GT",
    year: 2022,
    price: 38750,
    mileage: 31500,
    color: "Race Red",
    stock_no: "CV-67341",
    featured: false,
    description: "5.0L V8 with 460hp, 6-speed manual, Brembo brakes, magnetic ride control, and SYNC 4 infotainment. Only highway miles, garage kept. This is the real deal."
  }
]

vehicles.each do |attrs|
  Vehicle.find_or_create_by!(stock_no: attrs[:stock_no]) do |v|
    v.assign_attributes(attrs)
  end
end

puts "Created #{Vehicle.count} vehicles."

# Demo user
puts "Seeding demo user..."
demo = User.find_or_create_by!(email: "demo@carvana.com") do |u|
  u.password = "demo1234"
  u.password_confirmation = "demo1234"
  u.first_name = "Demo"
  u.last_name = "User"
  u.experience_level = :first_time
end
puts "Demo user: #{demo.email} / demo1234"

puts "Done!"
