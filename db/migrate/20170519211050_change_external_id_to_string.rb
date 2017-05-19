class ChangeExternalIdToString < ActiveRecord::Migration[5.0]
  def up
    temp_committees = Committee.all.load

    remove_column :committees, :external_id
    remove_index :committees, :external_id

    add_column :committees, :external_id, :string, null: false
    add_index :committees, :external_id, unique: true

    temp_committees.each{|x| x.save!}
  end

  def down
    temp_committees = Committee.all.load

    remove_column :committees, :external_id
    remove_index :committees, :external_id

    add_column :committees, :external_id, :integer, null: false
    add_index :committees, :external_id, unique: true

    temp_committees.each{|x| x.save!}
  end
end
