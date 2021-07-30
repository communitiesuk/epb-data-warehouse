class AddTableFunction < ActiveRecord::Migration[6.1]
  def change
    enable_extension "tablefunc"
  end
end
