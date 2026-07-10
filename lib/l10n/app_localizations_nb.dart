// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get navFeed => 'Tilbud';

  @override
  String get navAlerts => 'Varslinger';

  @override
  String get searchHint => 'Søk produkter eller merker...';

  @override
  String get clearSearch => 'Fjern søk';

  @override
  String get categoriesButton => 'Kategorier';

  @override
  String get allCategories => 'Alle kategorier';

  @override
  String get groupElectronics => 'Elektronikk & Teknologi';

  @override
  String get groupLifestyle => 'Livsstil & Hverdag';

  @override
  String get catSmartphones => 'Mobiltelefoner';

  @override
  String get catTablets => 'Nettbrett';

  @override
  String get catWearables => 'Bærbar teknologi';

  @override
  String get catLaptopsPc => 'Bærbare datamaskiner/PC';

  @override
  String get catMonitors => 'Skjermer';

  @override
  String get catTVs => 'TV-er';

  @override
  String get catAudio => 'Lyd';

  @override
  String get catGamingAccessories => 'Gaming-tilbehør';

  @override
  String get catAccessories => 'Tilbehør';

  @override
  String get catHomeElectronics => 'Hjemmeelektronikk';

  @override
  String get catFashionClothing => 'Mote & Klær';

  @override
  String get catBeautyHealth => 'Skjønnhet & Helse';

  @override
  String get catHomeGarden => 'Hjem & Hage';

  @override
  String get catSportsOutdoors => 'Sport & Friluftsliv';

  @override
  String get catToysKids => 'Leker & Barn';

  @override
  String get catGroceriesFood => 'Mat & Dagligvarer';

  @override
  String get catAutomotive => 'Bil & Motor';

  @override
  String get catBooksMedia => 'Bøker & Media';

  @override
  String get catPets => 'Kjæledyr';

  @override
  String get catTravelLuggage => 'Reise & Bagasje';

  @override
  String get liveHeroHeadline => 'Live Prissporing';

  @override
  String liveDealsTracked(int count) {
    return '🔥 $count+ tilbud spores akkurat nå';
  }

  @override
  String get liveDealsSynced => '🔥 Nye tilbud synkroniseres kontinuerlig';

  @override
  String livePriceDrops(int count) {
    return '📉 Fant $count prisfall i dag';
  }

  @override
  String get liveMonitoringActive => '⚡ Live prisovervåking aktiv';

  @override
  String get recentlyViewed => 'Nylig sett';

  @override
  String get clearAll => 'Fjern alle';

  @override
  String get clearHistoryTitle => 'Slett historikk';

  @override
  String get clearHistoryConfirm => 'Slette alle nylig sette varer?';

  @override
  String get cancel => 'Avbryt';

  @override
  String get clear => 'Fjern';

  @override
  String get biggestPriceDrops => 'Størst prisfall';

  @override
  String get last24h => 'Siste 24t';

  @override
  String get insaneDeals => 'Sinnssyke tilbud';

  @override
  String minDiscountBadge(int percent) {
    return '≥ $percent% avslag';
  }

  @override
  String get refreshDealsTooltip => 'Oppdater tilbud';

  @override
  String get sortTooltip => 'Sorter tilbud';

  @override
  String sortButtonLabel(String label) {
    return 'Sorter: $label';
  }

  @override
  String get sortBestDeals => 'Beste tilbud';

  @override
  String get sortPriceLowHigh => 'Pris: Lav til høy';

  @override
  String get sortPriceHighLow => 'Pris: Høy til lav';

  @override
  String get sortNewest => 'Nyeste';

  @override
  String get prevPage => 'Forrige side';

  @override
  String get nextPage => 'Neste side';

  @override
  String get lastPage => 'Siste';

  @override
  String goToPage(int total) {
    return 'Gå til side (1-$total)';
  }

  @override
  String get noDealsFound => 'Ingen tilbud funnet';

  @override
  String get checkBackLater => 'Kom tilbake senere eller trykk oppdater.';

  @override
  String get refreshNow => 'Oppdater nå';

  @override
  String noResultsFor(String query) {
    return 'Ingen resultater for «$query»';
  }

  @override
  String get noDealsMatchFilters => 'Ingen tilbud samsvarer med filtrene dine';

  @override
  String get tryCheckingTypos =>
      'Sjekk for skrivefeil eller fjern noen filtre.';

  @override
  String get clearFilters => 'Fjern filtre';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get footerTagline =>
      'Skandinavias smarteste måte å sammenligne priser på.';

  @override
  String get trustSecure => 'Sikker (HTTPS)';

  @override
  String get trustVerified => 'Verifisert affiliatepartner';

  @override
  String get trustGdpr => 'GDPR-kompatibel';

  @override
  String get trustLiveUpdates => 'Live prisoppdateringer';

  @override
  String get trustSweden => 'Sverige';

  @override
  String get trustNorway => 'Norge';

  @override
  String get footerShop => 'Handle';

  @override
  String get footerInformation => 'Informasjon';

  @override
  String get footerSupport => 'Support';

  @override
  String get footerAboutUs => 'Om oss';

  @override
  String get footerPrivacyPolicy => 'Personvernerklæring';

  @override
  String get footerTermsOfService => 'Vilkår for bruk';

  @override
  String get footerContactUs => 'Kontakt oss';

  @override
  String get footerAffiliateDisclosure => 'Affiliateinformasjon';

  @override
  String footerCopyright(int year) {
    return '© $year PrisPuls. Alle rettigheter forbeholdt.';
  }
}
