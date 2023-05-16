require "test_helper"

class Webhooks::ProcessPaypalUpdateTest < ActiveSupport::TestCase
  [
    ["web_accept", Payments::Paypal::Payment::HandleWebAccept],
    ["recurring_payment", Payments::Paypal::Subscription::HandleRecurringPayment],
    ["recurring_payment_expired", Payments::Paypal::Subscription::HandleRecurringPaymentExpired],
    ["recurring_payment_failed", Payments::Paypal::Subscription::HandleRecurringPaymentFailed],
    ["recurring_payment_profile_cancel", Payments::Paypal::Subscription::HandleRecurringPaymentProfileCancel],
    ["recurring_payment_profile_created", Payments::Paypal::Subscription::HandleRecurringPaymentProfileCreated],
    ["recurring_payment_skipped", Payments::Paypal::Subscription::HandleRecurringPaymentSkipped],
    ["recurring_payment_suspended", Payments::Paypal::Subscription::HandleRecurringPaymentSuspended],
    ["recurring_payment_suspended_due_to_max_failed_payment",
     Payments::Paypal::Subscription::HandleRecurringPaymentSuspendedDueToMaxFailedPayment]
  ].each do |(txn_type, expected_command)|
    test "handle IPN event with txn_type #{txn_type}" do
      txn_id = SecureRandom.uuid
      payload = "txn_id=#{txn_id}&txn_type=#{txn_type}"

      stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
        to_return(status: 200, body: "VERIFIED", headers: {})

      expected_command.expects(:call).with({
        "txn_id" => txn_id,
        "txn_type" => txn_type
      })

      Webhooks::ProcessPaypalUpdate.(payload)
    end
  end

  %w[
    adjustment cart express_checkout masspay merch_pmt mp_cancel new_case
  ].each do |txn_type|
    test "ignore IPN event with txn_type #{txn_type}" do
      txn_id = SecureRandom.uuid
      payload = "txn_id=#{txn_id}&txn_type=#{txn_type}"

      stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
        to_return(status: 200, body: "VERIFIED", headers: {})

      Payments::Paypal::Payment::HandleWebAccept.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPayment.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPaymentExpired.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPaymentFailed.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPaymentProfileCancel.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPaymentProfileCreated.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPaymentSkipped.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPaymentSuspended.expects(:call).never
      Payments::Paypal::Subscription::HandleRecurringPaymentSuspendedDueToMaxFailedPayment.expects(:call).never

      Webhooks::ProcessPaypalUpdate.(payload)
    end
  end

  test "bugsnag is created if IPN is invalid" do
    payload = "txn_id=#{SecureRandom.uuid}&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 200, body: "INVALID", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalUpdate.(payload)
  end

  test "bugsnag is created if IPN verification has unknown result" do
    payload = "txn_id=#{SecureRandom.uuid}&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 200, body: "UNKNOWN", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalUpdate.(payload)
  end

  test "bugsnag is created if error occurs in verification request" do
    payload = "txn_id=#{SecureRandom.uuid}&txn_type=web_accept"

    stub_request(:post, "https://ipnpb.paypal.com/cgi-bin/webscr").
      to_return(status: 500, body: "ERROR", headers: {})

    Bugsnag.expects(:notify).once

    Webhooks::ProcessPaypalUpdate.(payload)
  end
end
