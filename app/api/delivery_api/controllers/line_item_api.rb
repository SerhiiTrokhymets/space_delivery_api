module DeliveryApi
  module Controllers
    class LineItemApi < Root
      helpers DeliveryApi::Helpers::CartHelpers
      helpers do
        def line_item
          current_cart.line_items.find(params[:line_item_id])
        end
      end

      resources :line_items do
        before { authenticate! }

        route_param :line_item_id, type: Integer do
          desc 'Change product quantity.'
          params { requires :quantity, type: Integer }
          patch :quantity do
            return error!('Quantity must be positive!', 400) unless params[:quantity].positive?

            command = line_item.change_quantity(declared_params[:quantity])
            present(message: 'Quantity updated!', quantity: declared_params[:quantity]) if command
          end

          desc 'Delete product from cart.'
          delete { present(message: 'Deleted.') if line_item.destroy }
        end
      end
    end
  end
end
