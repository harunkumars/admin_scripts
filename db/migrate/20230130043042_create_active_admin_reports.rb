class CreateActiveAdminReports < ActiveRecord::Migration[7.0]
  def change
    create_table :active_admin_reports do |t|
      t.string :name
      t.text :description
      t.text :ruby_script

      t.timestamps
    end
  end
end
