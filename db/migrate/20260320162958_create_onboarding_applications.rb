class CreateOnboardingApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.integer :current_step
      t.string :status
      t.text :application_data

      t.timestamps
    end
  end
end
