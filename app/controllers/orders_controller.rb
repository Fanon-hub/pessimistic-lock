class OrdersController < ApplicationController
  def index
    @orders = Order.where(user_id: current_user.id).order(created_at: :desc)
  end

  def new
    @order = Order.new
    @order.ordered_lists.build
    @items = Item.all.order(:created_at)
  end

  def create
    ActiveRecord::Base.transaction do
      @order = current_user.orders.build(order_params)
      if @order.save
        @order.update_total_quantity_with_lock
        redirect_to orders_path, notice: 'Order was successfully created.'
      else
        render :new
      end
    end
  rescue => e
    redirect_to orders_path, alert: "Order creation failed: #{e.message}"
  end

  private

  def order_params
    params.require(:order).permit(ordered_lists_attributes: [:item_id, :quantity])
  end

end
