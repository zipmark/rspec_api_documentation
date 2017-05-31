class UploadsController < ApplicationController
  http_basic_authenticate_with name: 'user', password: 'password'

  def create
    head 201
  end
end
