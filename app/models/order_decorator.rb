Spree::Order.class_eval do

  ABANDONED_EMAIL_TIMEFRAME = 6.hours

  preference :abandedon_email_timeframe, 1.minutes

  def self.email_eligible_abandoned_email_orders

    eligible_abandoned_email_orders.each do |order|

      if order.abandoned_count_email = 1
        subject = "We're here to help"
        text = "We noticed that you left #{order.products.count} item(s) in your shopping cart.  Please let us know if you’ve experienced any difficulties with the purchasing process or if you
                have any product-specific questions. As always, our dedicated customer support team is here to assist you.\n"+
                order.products.map do |product|
                   "<img src=#{product.images.first.attachment(:small)}/>"
                 end.join('')+


                "\nSincerely,"
        count = order.abandoned_count_email+1
        order.update(abandoned_count_email: count)
        order.send_abandoned_email(subject, text)
      elsif order.abandoned_count_email == 2
        subject = "Don’t miss out on #{order.products.first.name}!"
        text = "Our inventory is running low on #{order.products.first.name}.  We don’t want you to miss out.
These items are being held for you in our inventory for a limited time only.  Don’t delay, return to your shopping cart and make your purchase today.
Should you have any questions about any products or the purchasing process, please don’t hesitate to reach out to our customer support team. We are here to assist you.\n
        \n
        \n"+
        order.products.map do |product|
          "<img src=#{product.images.first.attachment(:small)}/>"
        end.join('')+


"\nSincerely,"

        count = order.abandoned_count_email+1
        order.update(abandoned_count_email: count)
        order.send_abandoned_email(subject, text)
      elsif order.abandoned_count_email == 3
        subject = "Save 10% on your next purchase"
        text = "You’ve got your eye on our products, and we want to help you create a space you’ll love.
Please accept this certificate to save 10% off your entire purchase. Simply return to your shopping cart and input the
 following promo code into the promo code field during the checkout process to receive your pricing discount, but don’t delay,
 this offer expires on #{(Time.now + 7.day).strftime('%m/%d/%Y') }. Should you have any questions about any products or the purchasing process,
 please don’t hesitate to reach out to our customer support team. We are here to assist you.\n
        \n
        \n"+
        order.products.each do |product|
          "<img src=#{product.images.first.attachment(:small)}/>"
        end.join('')+

"\nSincerely,"
        count = order.abandoned_count_email+1
        order.update(abandoned_count_email: count)
        order.send_abandoned_email(subject, text)
      end
    end
  end

  def self.eligible_abandoned_email_orders
    where("state != ?
            AND (payment_state IS NULL OR payment_state != ?)
            AND email is NOT NULL
            AND abandoned_email_sent_at IS NULL
            AND created_at < ?",
          "complete",
          "paid",
          (Time.zone.now - Spree::AbandonedCartEmailConfig::Config.email_timeframe))
  end

  def send_abandoned_email

    # Don't send anything if the order has no line items.
    return if line_items.empty?
    Spree::AbandonedCartMailer.abandoned_email(self).deliver
    mark_abandoned_email_as_sent
  end

  private

  def mark_abandoned_email_as_sent
    update_attribute :abandoned_email_sent_at, Time.zone.now
  end

end
