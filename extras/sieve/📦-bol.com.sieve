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
  "automail@bol.com"
] {

  fileinto "📦 Stuff";

  if header :comparator "i;unicode-casemap" :contains "Subject" [
    "Bedankt voor je bestelling",
    "Je pakket is nu bij"
  ] {
    if header :comparator "i;unicode-casemap" :contains "Subject" "Bedankt voor je bestelling" {
      fileinto "💶 Money";
    }
    fileinto "Shopping/Bol.com";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "Je artikelen komen eraan",
    "Je pakket ligt bij de buren",
    "Je pakket ligt bij het afhaalpunt"
  ] {
    fileinto "Deliveries";
    expire "day" "7";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "De bezorger is onderweg",
    "Je pakket is bezorgd",
    "Je pakketten zijn bezorgd",
    "kon je pakket niet bezorgen"
  ] {
    fileinto :flags "\\Seen" "Deliveries";
    expire "day" "3";
  }
  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "Hoe verliep je bestelling",
    "Je eerste punten zijn binnen"
  ] {
    fileinto :flags "\\Seen" "trash";
  }

}

# Also captured by the generic deliveries-sieve (which adds "📦 Stuff"); this
# fishes out the invoices, and directs them to the right place...

if address :all :comparator "i;unicode-casemap" :is "From" [
  "noreply@verkopen.bol.com"
] {

  if header :comparator "i;unicode-casemap" :contains "Subject" [
    "Factuur van"
  ] {
    fileinto "💶 Money";
    fileinto "Shopping/Bol.com";
  }
}
