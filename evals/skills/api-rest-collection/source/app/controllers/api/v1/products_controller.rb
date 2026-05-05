# frozen_string_literal: true

module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: %i[show update destroy]

      # GET /api/v1/products
      def index
        @products = Product.all
        render json: @products
      end

      # GET /api/v1/products/:id
      def show
        render json: @product
      end

      # POST /api/v1/products
      def create
        @product = Product.new(product_params)

        if @product.save
          render json: @product, status: :created
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/products/:id
      def update
        if @product.update(product_params)
          render json: @product
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product.destroy
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      def product_params
        params.require(:product).permit(:name, :price, :description)
      end
    end
  end
end
