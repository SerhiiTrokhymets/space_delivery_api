class CartsController < ApplicationController
  include ProductsHelper

  def show
    @cart = Cart.includes(line_items: [product_type: [product: :picture]])
                .find(session[:cart_id])

    give_away
    buy_together
  end

  def add_product
    product_type = ProductType.find(params[:id])
    current_cart.add_product(product_type).try(:save)
    ActionCable.server.broadcast :notifiations, message: "#{product_type.product.title} added to cart."

    respond_to do |format|
      format.js
    end
  end

  def buy_together
    ids = product_ids(current_cart).uniq

    product_ids = ProductSale.where('active_id IN (?) AND passive_id NOT IN (?)', ids, ids).order(sales_count: :desc)
                             .pluck(:passive_id).uniq

    @products = Product.includes(:product_types, :picture)
                       .where('id IN (?) AND published IS ?', product_ids, true).limit(3)
  end

  def give_away
    gift = Gift.where('limitation > ?', Time.zone.today).first
    line_items = current_cart.line_items
    product_type = gift.product.product_types.order(price: :desc).first

    if current_cart.total_price >= gift.amount_target
      if line_items.where('product_type_id = ? AND gift_id = ?', product_type.id, gift.id).empty?
        line_items.create(product_type: product_type, gift_id: gift.id)
      end
    else
      unless line_items.where('product_type_id = ? AND gift_id = ?', product_type.id, gift.id).empty?
        line_items.where(gift_id: gift.id).destroy_all
      end
    end

    @gifts = current_cart.line_items.where('gift_id IS NOT NULL')
  end
end
