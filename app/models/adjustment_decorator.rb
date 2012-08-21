Spree::Adjustment.class_eval do
  scope :klarna_invoice_cost, lambda { where('label LIKE ?', "#{I18n.t(:invoice_fee)}%") }
  attr_accessible :source, :originator, :locked
end
