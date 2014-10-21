class AddAbandonedCountEmailToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :abandoned_count_email, :integer, default: 0

  end
end
