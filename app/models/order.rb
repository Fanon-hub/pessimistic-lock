class Order < ApplicationRecord
  belongs_to :user
  has_many :ordered_lists, dependent: :destroy 
  # has_many :items, through: :ordered_lists
  accepts_nested_attributes_for :ordered_lists

  def update_total_quantity_with_lock
    ordered_lists.each do |ordered_list|
      update_item_quantity(ordered_list)
    end
  end

  private
  def update_item_quantity(ordered_list)
    item = Item.lock.find(ordered_list.item_id)
    
    item.increment!(:total_quantity, ordered_list.quantity)
  end
end  

