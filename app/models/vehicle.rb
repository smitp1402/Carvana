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
end
