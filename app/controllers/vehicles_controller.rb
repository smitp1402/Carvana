class VehiclesController < ApplicationController
  def index
    @vehicles = Vehicle.all.order(featured: :desc, created_at: :asc)
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end
end
