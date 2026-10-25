require ["include", "environment", "variables", "relational", "comparator-i;ascii-numeric", "spamtest"];
require ["fileinto", "imap4flags", "vnd.proton.expire"];

# Generated: Do not run this script on spam messages
if allof (
  environment :matches "vnd.proton.spam-threshold" "*",
  spamtest :value "ge" :comparator "i;ascii-numeric" "${1}"
) {
  return;
}

# Shopify
if address :domain :comparator "i;unicode-casemap" :is "From" [
  "t.shopifyemail.com"
] {

  fileinto "📦 Stuff";
  fileinto "Shopping";

  if header :comparator "i;unicode-casemap" :contains "Subject" "confirmed" {
    fileinto "💶 Money";
  }
}

# Zalando
elsif address :all :comparator "i;unicode-casemap" :is "From" [
  "info@service-mail.zalando.nl"
 ] {
  fileinto "📦 Stuff";
  fileinto "Shopping";

  if header :comparator "i;unicode-casemap" :contains "Subject" "Thanks for your order" {
    fileinto "💶 Money";
  }
}

# Coolblue
elsif address :all :comparator "i;unicode-casemap" :is "From" [
  "no-reply@coolblue.nl"
 ] {
  fileinto "📦 Stuff";

  if header :comparator "i;unicode-casemap" :contains "Subject" [
    "Your order is successful",
    "Your order is on its way"
  ] {
    fileinto "Shopping";
    fileinto "💶 Money";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "delivery time",
    "will deliver"
  ] {
    fileinto "Deliveries";
    expire "day" "7";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "was delivered"
  ] {
    fileinto :flags "\\Seen" "Deliveries";
    expire "day" "3";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "What's your experience"
  ] {
    fileinto :flags "\\Seen" "trash";
  }
}
