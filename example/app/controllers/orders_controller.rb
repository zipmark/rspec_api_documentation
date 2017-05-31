class OrdersController < ApplicationController
  before_action only: :index do
    head :unauthorized unless request.headers['HTTP_AUTH_TOKEN'] =~ /\AAPI_TOKEN$/
  end

  def index
    render :json => Order.all
  end

  def show
    order = Order.find_by(id: params[:id])
    if order
      render json: order
    else
      head :not_found
    end
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
