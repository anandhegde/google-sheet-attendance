class CreateAttendanceDates < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_dates do |t|
      t.string :date
      t.string :taken

      t.timestamps
    end
  end
end
