class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
      t.column :package, :string
      t.column :build, :string
      t.column :map, :string
    end
  end

  def self.down
    drop_table :maps
  end
end
