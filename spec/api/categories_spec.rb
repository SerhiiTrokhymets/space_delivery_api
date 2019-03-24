require 'rails_helper'

describe DeliveryApi::Controllers::CategoryApi, type: :api do
  def app
    DeliveryApi::Controllers::CategoryApi
  end

  describe 'Categories' do
    let(:user) { create(:user) }
    let(:category) { create(:category_with_products, products_count: 1) }

    let(:product_attributes) do
      lambda do |category|
        category.products.map do |product|
          {
            id: product.id,
            category_id: product.category_id,
            title: product.title,
            description: product.description,
            image_url: product.picture.image_name.url,
            product_types: [
              product_type_attributes[product]
            ].flatten
          }
        end
      end
    end

    let(:product_type_attributes) do
      lambda do |product|
        product.product_types.map do |type|
          {
            id: type.id,
            product_id: type.product_id,
            price: type.price,
            weight: type.weight,
            proportion: type.proportion
          }
        end
      end
    end

    let(:category_responce) do
      lambda do |category|
        {
          id: category.id,
          title: category.title,
          image_url: category.picture.image_name.url,
          products: [
            product_attributes[category]
          ].flatten
        }
      end
    end

    let(:categories) { create(:category_with_products, products_count: 3) }

    before { header 'Authorization', user.auth_token }

    context 'GET /api/categories' do
      it 'shoud return positive status' do
        get '/api/categories'
        expect(last_response.status).to eq(200)
      end

      it 'should return valid params' do
        responce = category
        get '/api/categories'
        expect(responce_body[:categories][0]).to eq(category_responce[responce])
      end
    end

    context 'GET /api/categories/:id/products' do
      it 'shoud return positive status' do
        get "/api/categories/#{categories.id}/products"
        expect(last_response.status).to eq(200)
      end

      it 'should return valid params' do
        responce = categories
        get "/api/categories/#{categories.id}/products"
        expect(responce_body[:category]).to eq(category_responce[responce])
      end

      context 'invalid :id' do
        before { get '/api/categories/0/products' }

        it 'should return error message' do
          expect(responce_body).to eq(error: 'Record not found!')
        end

        it 'should return status 404' do
          expect(responce_body).to eq(error: 'Record not found!')
        end
      end
    end
  end
end
