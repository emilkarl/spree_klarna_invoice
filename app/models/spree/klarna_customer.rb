module Spree
  class KlarnaCustomer < ActiveRecord::Base
    has_many :payments, :as => :source

    attr_accessor :sso

    validates :sso, :numericality => { :only_integer => true }

    def actions
      %w{capture credit}
    end

    def capture(payment)
    end

    def can_capture?(payment)
    end

    def credit(payment, amount=nil)
    end

    def can_credit?(payment)
    end
  end
end
