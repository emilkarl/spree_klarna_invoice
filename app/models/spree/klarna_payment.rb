class Spree::KlarnaPayment < ActiveRecord::Base
  has_many :payments, :as => :source
end
