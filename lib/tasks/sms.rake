desc "send a test sms message"
task :sms_test, [:to] do |task, args|
  require "twilio-ruby"

  account_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
  auth_token = ENV.fetch("TWILIO_AUTH_TOKEN")
  from = ENV.fetch("TWILIO_FROM_NUMBER")

  client = Twilio::REST::Client.new(account_sid, auth_token)

  raise "provide a to number, including country code: +1xxxxxxxxxx" unless args.key? :to

  to = args.fetch(:to)
  client.messages.create(
    from: from,
    to: to,
    body: "Testing!",
    status_callback: "https://postb.in/1581030366772-7630687530618",
  )
end