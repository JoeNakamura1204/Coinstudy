class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.string :title
      t.date :date
      t.string :place
      t.string :url

      t.timestamps null: false
    end
  end
end
