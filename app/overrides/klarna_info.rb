Deface::Override.new(:virtual_path => "spree/checkout/edit",
                     :name => "klarna_info",
                     :insert_bottom => "[data-hook='checkout_content']",
                     :partial => "spree/klarna/klarna_info")