module Spree
  class KlarnaCustomer < ActiveRecord::Base
    has_many :payments, :as => :source

    attr_accessor :sso

    validates :sso, :numericality => { :only_integer => true }
  end
end
