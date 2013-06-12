class CreateClones < ActiveRecord::Migration
  def change
    create_table :clones do |t|
      t.string :student
      t.string :hw
      t.string :url
      t.text :info
      t.text :message
      t.text :error
      t.integer :version
      t.integer :status

      t.timestamps
    end
  end
end
