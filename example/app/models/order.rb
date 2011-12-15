class Order < ActiveRecord::Base
  attr_accessible :name, :paid, :email

  def as_json(opts = {})
    super(:only => [:name, :paid, :email])
  end
end
