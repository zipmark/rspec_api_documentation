class OrdersController < ApplicationController
  respond_to :json

  def index
    respond_with Order.all
  end

  def show
    respond_with Order.find(params[:id])
  end

  def create
    respond_with Order.create(order_params)
  end

  def update
    order = Order.find(params[:id])
    order.update(order_params)
    respond_with order
  end

  def destroy
    Order.find(params[:id]).destroy
    head 204
  end

  private

  def order_params
    params.require(:order).permit(:name, :paid, :email)
  end
end
