require 'test_helper'

class ConcurrentOrderTest < ActiveSupport::TestCase
  def setup
    @item = Item.create!(name: 'Test Item', total_quantity: 0)
    @user_a = User.create!(name: 'User A', email: 'a@example.com', password: 'password')
    @user_b = User.create!(name: 'User B', email: 'b@example.com', password: 'password')
  end

  def test_concurrent_orders
    threads = []
    threads << Thread.new do
      Order.transaction do
        order_a = @user_a.orders.create!(ordered_lists_attributes: [{item_id: @item.id, quantity: 5}])
        order_a.update_total_quantity_with_lock
      end
    end
    threads << Thread.new do
      Order.transaction do
        order_b = @user_b.orders.create!(ordered_lists_attributes: [{item_id: @item.id, quantity: 5}])
        order_b.update_total_quantity_with_lock
      end
    end
    threads.each(&:join)
    @item.reload
    assert_equal 10, @item.total_quantity, "Total quantity should be 10 after concurrent orders"
  end
end
