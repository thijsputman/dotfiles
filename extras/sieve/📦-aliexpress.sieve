require ["include", "environment", "variables", "relational", "comparator-i;ascii-numeric", "spamtest"];
require ["fileinto", "imap4flags", "vnd.proton.expire"];

# Generated: Do not run this script on spam messages
if allof (
  environment :matches "vnd.proton.spam-threshold" "*",
  spamtest :value "ge" :comparator "i;ascii-numeric" "${1}"
) {
  return;
}

if address :all :comparator "i;unicode-casemap" :is "From" "transaction@notice.aliexpress.com" {

  fileinto "📦 Stuff";

  if header :comparator "i;unicode-casemap" :contains "Subject" [
    "order confirmed",
    "order shipped",
    "partially shipped",
    "ready to ship"
  ] {
    if header :comparator "i;unicode-casemap" :contains "Subject" "order confirmed" {
      fileinto "💶 Money";
    }
    fileinto "Shopping/AliExpress";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "out for delivery",
    "in your country/region",
    "Delivery issue for package",
    "at customs"
  ] {
    fileinto "Deliveries";
    expire "day" "7";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "package in transit",
    "delivery update",
    "cleared customs",
    "at delivery center",
    "collected by the carrier",
    "left the departure region",
    "is at the delivery center",
    "with local carrier",
    "has been delivered",
    "has an update"
  ] {
    fileinto :flags "\\Seen" "Deliveries";
    expire "day" "3";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "how did it go",
    "awaiting confirmation",
    "Confirmation time extended",
    "Your delayed delivery coupon"
  ] {
    fileinto :flags "\\Seen" "trash";
  }

}
