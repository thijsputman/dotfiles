require ["include", "environment", "variables", "relational", "comparator-i;ascii-numeric", "spamtest"];
require ["fileinto", "imap4flags", "vnd.proton.expire"];

# Generated: Do not run this script on spam messages
if allof (
  environment :matches "vnd.proton.spam-threshold" "*",
  spamtest :value "ge" :comparator "i;ascii-numeric" "${1}"
) {
  return;
}

if anyof(
  address :all :comparator "i;unicode-casemap" :is "From" [
    "noreply@dhlecommerce.nl",
    "noreply@gls-netherlands.com",
    "notificaties@dpd.nl",
    "notifications@nl.dragonflyinternational.com",
    "noreply@verkopen.bol.com",
    "no-reply@sendcloud.com",
    "FedEx@message.fedex.com",
    "noreply@intrapost.nl",
    "mcinfo@ups.com",
    "noreply@dhl.de",
    "feedback@voc.dpd.nl",
    "no.reply.dlv.nl@pdn.express",
    "noreply@fedex.com",
    "cs@nlcare.gofo.com",
    "cs@nlconnect.gofo.com",
    "pkginfo@ups.com"
  ],
  header :comparator "i;unicode-casemap" :contains "X-From" [
    "noreply@dhlecommerce.nl"
  ],
  address :domain :comparator "i;unicode-casemap" :is "From" [
    "edm.postnl.nl",
    "partnerklantenservice.bol.com"
  ]
) {

  fileinto "📦 Stuff";

  if header :comparator "i;unicode-casemap" :contains "Subject" [
    "We komen binnenkort een pakket",
    "gaat bijna op reis",
    "Je pakket is ontvangen",
    "Nieuw pakket",
    "Verwacht:",
    "Hoe ging het ontvangen van je pakket",
    "Je pakket is bij ons aangekomen",
    "klaar voor verzending",
    "Hoe tevreden was je",
    "pakket is gepland",
    "is ingepakt",
    "Hoe was je ervaring met",
    "has already been shipped"
  ] {
    fileinto :flags "\\Seen" "trash";
  }

  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "Onderweg met je pakket",
    "komen we bij je langs",
    "wordt vandaag tussen",
    "bezorgen je pakket vandaag",
    "Vandaag bezorgen we je pakket",
    "We staan vandaag voor de deur",
    "We staan vanavond voor de deur",
    "is onderweg",
    "UPS Update",
    "shipment is on its way",
    "Plan de bezorging van je pakket zelf",
    "We bezorgen jouw pakket",
    "Bezorgupdate:",
    "Parcel Ready for Collection",
    "afgeleverd bij je Pickup Parcelshop",
    "Vandaag ontvang je jouw pakket",
    "Uw zending is onderweg",
    "is vanuit het buitenland naar je onderweg",
    "We komen nog een keer langs",
    "kan vandaag helaas niet bezorgd worden",
    "We hebben je gemist!",
    "De bezorger kon je pakket niet bezorgen",
    "bezorgd bij de buren",
    "Je pakket ligt bij de buren",
    "is verstuurd",
    "wordt binnenkort bezorgd",
    "ligt voor je klaar",
    "pakket is verzonden",
    "pakket komt vandaag",
    "hebben je pakket ontvangen",
    "bestelling is verzonden",
    "bezorgen je pakket op",
    "is nu onderweg",
    "komen vandaag langs",
    "Zending onderweg"
  ] {
    fileinto "Deliveries";
    expire "day" "7";
  }

  elsif header :comparator "i;unicode-casemap" :contains "Subject" [
    "is bezorgd",
    "je pakket bezorgd",
    "Afgeleverd: je pakket",
    "Uw pakket is bezorgd",
    "Herinnering:",
    "Informatie over je zending via GLS",
    "is succesvol bezorgd",
    "pakket is afgeleverd",
    "pakket in handen",
    "binnen een uur voor je deur",
    "gaat naar een DHL Pakketautomaat",
    "has been delivered"
  ] {
    fileinto :flags "\\Seen" "Deliveries";
    expire "day" "3";
  }

}
