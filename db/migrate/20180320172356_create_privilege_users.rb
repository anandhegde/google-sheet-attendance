class CreatePrivilegeUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :privilege_users do |t|
      t.string :email
      t.string :role

      t.timestamps
    end
  end
end
