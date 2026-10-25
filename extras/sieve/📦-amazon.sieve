require ["include", "environment", "variables", "relational", "comparator-i;ascii-numeric", "spamtest"];
require ["fileinto", "imap4flags", "vnd.proton.expire"];

# Generated: Do not run this script on spam messages
if allof (
  environment :matches "vnd.proton.spam-threshold" "*",
  spamtest :value "ge" :comparator "i;ascii-numeric" "${1}"
) {
  return;
}

if address :all :comparator "i;unicode-casemap" :is "From" [
  "bestellbestaetigung@amazon.de",
  "versandbestaetigung@amazon.de",
  "bestellung-aktuell@amazon.de",
  "auto-bevestiging@amazon.nl",
  "update-bestelling@amazon.nl",
  "verzending-volgen@amazon.nl",
  "no-reply@amazon.de",
  "order-update@amazon.de"
] {

  fileinto "📦 Stuff";

  if header :comparator "i;unicode-casemap" :contains "Subject" [
    "Ordered:",
    "Dispatched:",
    "Shipped:"
  ] {
    if header :comparator "i;unicode-casemap" :contains "Subject" "Ordered:" {
      fileinto "💶 Money";
    }
    fileinto "Shopping/Amazon";
  }
  elsif header :contains "Subject" [
    "Out for delivery:",
    "Delivery attempted"
  ] {
    fileinto "Deliveries";
    expire "day" "7";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" "Delivered:" {
    fileinto :flags "\\Seen" "Deliveries";
    expire "day" "3";
  }

}
