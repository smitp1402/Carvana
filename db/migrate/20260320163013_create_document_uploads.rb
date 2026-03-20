class CreateDocumentUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :document_uploads do |t|
      t.references :onboarding_application, null: false, foreign_key: true
      t.string :document_type
      t.string :status
      t.text :extracted_data
      t.string :filename

      t.timestamps
    end
  end
end
