class Vehicle < ApplicationRecord
  has_many :onboarding_applications, dependent: :nullify
  has_many_attached :images

  validates :make, :model, :year, :price, :stock_no, presence: true

  def display_name
    "#{year} #{make} #{model}"
  end

  def formatted_price
    "$#{price.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def formatted_mileage
    "#{mileage.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} miles"
  end

  def hex_color
    COLOR_MAP.fetch(color&.downcase, "#1a1a2e")
  end

  COLOR_MAP = {
    "sonic gray pearl" => "#7a7f85",
    "midnight black metallic" => "#1a1a2e",
    "race red" => "#c41e3a",
    "silver" => "#a0a0a0",
    "white" => "#e8e8e8",
    "blue" => "#1e3a5f",
    "black" => "#1a1a1a"
  }.freeze
end
