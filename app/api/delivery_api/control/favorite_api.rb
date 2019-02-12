module DeliveryApi
  module Control
    class FavoriteApi < Grape::API
      resources :favorites do
        get do
          favorites = current_user.favorites.order(:product_id)
          present_with_entities(favorites)
        end

        route_param :id do
          post :create do
            MakeFavorite.call(current_user, params[:id]) do
              on(:ok)      { present(message: 'Successfully added to Favorites.') }
              on(:fail)    { present(message: 'Cant add to favorites.') }
              on(:include) { present(message: 'Already added.') }
            end
          end

          delete :destroy do
            favorite = current_user.favorites.find(params[:id])
            { message: 'Successfully deleted from favorites.' } if favorite.destroy
          end
        end
      end
    end
  end
end