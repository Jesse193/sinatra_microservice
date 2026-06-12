class CreateUserFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :users_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :market, null: false, foreign_key: true

      t.timestamps
    end

    add_index :users_favorites, [:user_id, :market_id], unique: true
  end
end
