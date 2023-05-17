class User::UpdateTotalDonatedInCents
  include Mandate

  initialize_with :user

  def call
    user.update!(total_donated_in_cents: user.payment_payments.sum(:amount_in_cents))
  end
end
