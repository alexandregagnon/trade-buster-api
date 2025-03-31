class AddCollectionsTable < ActiveRecord::Migration[7.2]
  def change
    create_table :collections, id: :uuid do |t|
      t.belongs_to :user, type: :uuid, foreign_key: true, index: true, null: false

      t.string :name, null: false
      t.string :description, null: true

      t.timestamps
    end
  end
end
