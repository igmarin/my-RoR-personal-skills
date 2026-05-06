# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 Products', type: :request do
  describe 'GET /api/v1/products' do
    it 'returns a list of products' do
      get '/api/v1/products'
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first).to include('id', 'name', 'price')
    end
  end

  describe 'GET /api/v1/products/:id' do
    it 'returns a product' do
      get '/api/v1/products/1'
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json).to be_a(Hash)
      expect(json['id'].to_i).to eq(1)
    end
  end

  describe 'POST /api/v1/products' do
    it 'creates a product' do
      post '/api/v1/products', params: { product: { name: 'Test', price: 10.0 } }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Test')
      expect(json['id']).to be_present
    end
  end

  describe 'PUT /api/v1/products/:id' do
    it 'updates a product' do
      put '/api/v1/products/1', params: { product: { name: 'Updated' } }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Updated')
    end
  end

  describe 'DELETE /api/v1/products/:id' do
    it 'destroys a product' do
      delete '/api/v1/products/1'
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end
end
