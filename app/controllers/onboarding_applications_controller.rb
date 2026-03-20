class OnboardingApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_application, only: [ :show, :step, :update_step ]

  STEP_NAMES = {
    1 => "Pre-Qualification",
    2 => "Financing Details",
    3 => "Document Upload",
    4 => "Review & Sign",
    5 => "Complete"
  }.freeze

  def create
    vehicle = Vehicle.find(params[:vehicle_id])
    @application = current_user.onboarding_applications.find_or_create_by!(
      vehicle: vehicle,
      status: "in_progress"
    )
    redirect_to step_onboarding_application_path(@application, step: 1)
  end

  def show
    redirect_to step_onboarding_application_path(@application, step: @application.current_step)
  end

  def step
    @step = params[:step].to_i
    @step_name = STEP_NAMES[@step]
    @vehicle = @application.vehicle
    render "step#{@step}"
  end

  def update_step
    @step = params[:step].to_i
    @application.update_data(step_params)
    @application.advance_step!
    if @application.complete?
      @application.update!(status: "submitted")
      redirect_to step_onboarding_application_path(@application, step: 5), notice: "Application submitted!"
    else
      redirect_to step_onboarding_application_path(@application, step: @application.current_step)
    end
  end

  private

  def set_application
    @application = current_user.onboarding_applications.find(params[:id])
  end

  def step_params
    params.permit(:annual_income, :employment_status, :employer_name,
                  :loan_term, :down_payment, :first_name, :last_name,
                  :address, :phone, :ssn_last4).to_h
  end
end
