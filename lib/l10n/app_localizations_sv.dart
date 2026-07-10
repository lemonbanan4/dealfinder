// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get navFeed => 'Erbjudanden';

  @override
  String get navAlerts => 'Aviseringar';

  @override
  String get searchHint => 'Sök produkter eller varumärken...';

  @override
  String get clearSearch => 'Rensa sökning';

  @override
  String get categoriesButton => 'Kategorier';

  @override
  String get allCategories => 'Alla kategorier';

  @override
  String get groupElectronics => 'Elektronik & Teknik';

  @override
  String get groupLifestyle => 'Livsstil & Vardag';

  @override
  String get catSmartphones => 'Mobiltelefoner';

  @override
  String get catTablets => 'Surfplattor';

  @override
  String get catWearables => 'Bärbar teknik';

  @override
  String get catLaptopsPc => 'Bärbara datorer/PC';

  @override
  String get catMonitors => 'Skärmar';

  @override
  String get catTVs => 'TV-apparater';

  @override
  String get catAudio => 'Ljud';

  @override
  String get catGamingAccessories => 'Gamingtillbehör';

  @override
  String get catAccessories => 'Tillbehör';

  @override
  String get catHomeElectronics => 'Hemelektronik';

  @override
  String get catFashionClothing => 'Mode & Kläder';

  @override
  String get catBeautyHealth => 'Skönhet & Hälsa';

  @override
  String get catHomeGarden => 'Hem & Trädgård';

  @override
  String get catSportsOutdoors => 'Sport & Friluftsliv';

  @override
  String get catToysKids => 'Leksaker & Barn';

  @override
  String get catGroceriesFood => 'Mat & Livsmedel';

  @override
  String get catAutomotive => 'Bil & Motor';

  @override
  String get catBooksMedia => 'Böcker & Media';

  @override
  String get catPets => 'Husdjur';

  @override
  String get catTravelLuggage => 'Resor & Bagage';

  @override
  String get liveHeroHeadline => 'Live Prisspårning';

  @override
  String liveDealsTracked(int count) {
    return '🔥 $count+ erbjudanden bevakas just nu';
  }

  @override
  String get liveDealsSynced => '🔥 Nya erbjudanden synkas kontinuerligt';

  @override
  String livePriceDrops(int count) {
    return '📉 Hittade $count prissänkningar idag';
  }

  @override
  String get liveMonitoringActive => '⚡ Live prisbevakning aktiv';

  @override
  String get recentlyViewed => 'Nyligen visade';

  @override
  String get clearAll => 'Rensa alla';

  @override
  String get clearHistoryTitle => 'Rensa historik';

  @override
  String get clearHistoryConfirm => 'Rensa alla nyligen visade objekt?';

  @override
  String get cancel => 'Avbryt';

  @override
  String get clear => 'Rensa';

  @override
  String get biggestPriceDrops => 'Största prissänkningarna';

  @override
  String get last24h => 'Senaste 24h';

  @override
  String get insaneDeals => 'Galna erbjudanden';

  @override
  String minDiscountBadge(int percent) {
    return '≥ $percent% rabatt';
  }

  @override
  String get refreshDealsTooltip => 'Uppdatera erbjudanden';

  @override
  String get sortTooltip => 'Sortera erbjudanden';

  @override
  String sortButtonLabel(String label) {
    return 'Sortera: $label';
  }

  @override
  String get sortBestDeals => 'Bästa erbjudanden';

  @override
  String get sortPriceLowHigh => 'Pris: Lågt till högt';

  @override
  String get sortPriceHighLow => 'Pris: Högt till lågt';

  @override
  String get sortNewest => 'Nyast';

  @override
  String get prevPage => 'Föregående sida';

  @override
  String get nextPage => 'Nästa sida';

  @override
  String get lastPage => 'Sista';

  @override
  String goToPage(int total) {
    return 'Gå till sida (1-$total)';
  }

  @override
  String get noDealsFound => 'Inga erbjudanden hittades';

  @override
  String get checkBackLater => 'Kom tillbaka senare eller tryck på uppdatera.';

  @override
  String get refreshNow => 'Uppdatera nu';

  @override
  String noResultsFor(String query) {
    return 'Inga resultat för \"$query\"';
  }

  @override
  String get noDealsMatchFilters => 'Inga erbjudanden matchar dina filter';

  @override
  String get tryCheckingTypos =>
      'Kontrollera stavningen eller ta bort några filter.';

  @override
  String get clearFilters => 'Rensa filter';

  @override
  String get retry => 'Försök igen';

  @override
  String get footerTagline =>
      'Skandinaviens smartaste sätt att jämföra priser.';

  @override
  String get trustSecure => 'Säker (HTTPS)';

  @override
  String get trustVerified => 'Verifierad affiliatepartner';

  @override
  String get trustGdpr => 'GDPR-kompatibel';

  @override
  String get trustLiveUpdates => 'Live prisuppdateringar';

  @override
  String get trustSweden => 'Sverige';

  @override
  String get trustNorway => 'Norge';

  @override
  String get footerShop => 'Handla';

  @override
  String get footerInformation => 'Information';

  @override
  String get footerSupport => 'Support';

  @override
  String get footerAboutUs => 'Om oss';

  @override
  String get footerPrivacyPolicy => 'Integritetspolicy';

  @override
  String get footerTermsOfService => 'Användarvillkor';

  @override
  String get footerContactUs => 'Kontakta oss';

  @override
  String get footerAffiliateDisclosure => 'Affiliateinformation';

  @override
  String footerCopyright(int year) {
    return '© $year PrisPuls. Alla rättigheter förbehållna.';
  }
}
