# frozen_string_literal: true

# frozen_string_literal: true$

require 'rails_helper'

describe 'API V1 Products', type: :request do
  describe 'GET /api/v1/products' do
    it 'returns a list of products' do
      get '/api/v1/products'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /api/v1/products/:id' do
    it 'returns a product' do
      get '/api/v1/products/1'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /api/v1/products' do
    it 'creates a product' do
      post '/api/v1/products', params: { product: { name: 'Test', price: 10.0 } }
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PUT /api/v1/products/:id' do
    it 'updates a product' do
      put '/api/v1/products/1', params: { product: { name: 'Updated' } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'DELETE /api/v1/products/:id' do
    it 'destroys a product' do
      delete '/api/v1/products/1'
      expect(response).to have_http_status(:no_content)
    end
  end
end
