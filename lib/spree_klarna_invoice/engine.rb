module SpreeKlarnaInvoice
  class Engine < Rails::Engine
    engine_name 'spree_klarna_invoice'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      #Spree::PaymentMethod::KlarnaInvoice.register
      initializer "spree_payment_network.register.payment_methods" do |app|
        app.config.spree.payment_methods += [Spree::PaymentMethod::KlarnaInvoice]
      end
      
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
