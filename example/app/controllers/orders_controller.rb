class OrdersController < ApplicationController
  def index
    render :json => Order.all
  end

  def show
    render :json => Order.find(params[:id])
  end

  def create
    order = Order.create(order_params)
    render :json => order, :status => 201, :location => order_url(order)
  end

  def update
    order = Order.find(params[:id])
    order.update(order_params)
    render :nothing => true, :status => 204
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
