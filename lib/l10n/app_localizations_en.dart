// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navFeed => 'Feed';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get searchHint => 'Search products or brands...';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get categoriesButton => 'Categories';

  @override
  String get allCategories => 'All Categories';

  @override
  String get groupElectronics => 'Electronics & Tech';

  @override
  String get groupLifestyle => 'Lifestyle & Everyday';

  @override
  String get catSmartphones => 'Smartphones';

  @override
  String get catTablets => 'Tablets';

  @override
  String get catWearables => 'Wearables';

  @override
  String get catLaptopsPc => 'Laptops/PC';

  @override
  String get catMonitors => 'Monitors';

  @override
  String get catTVs => 'TVs';

  @override
  String get catAudio => 'Audio';

  @override
  String get catGamingAccessories => 'Gaming Accessories';

  @override
  String get catAccessories => 'Accessories';

  @override
  String get catHomeElectronics => 'Home Electronics';

  @override
  String get catFashionClothing => 'Fashion & Clothing';

  @override
  String get catBeautyHealth => 'Beauty & Health';

  @override
  String get catHomeGarden => 'Home & Garden';

  @override
  String get catSportsOutdoors => 'Sports & Outdoors';

  @override
  String get catToysKids => 'Toys & Kids';

  @override
  String get catGroceriesFood => 'Groceries & Food';

  @override
  String get catAutomotive => 'Automotive';

  @override
  String get catBooksMedia => 'Books & Media';

  @override
  String get catPets => 'Pets';

  @override
  String get catTravelLuggage => 'Travel & Luggage';

  @override
  String get liveHeroHeadline => 'Live Market Price Tracker';

  @override
  String liveDealsTracked(int count) {
    return '🔥 $count+ deals tracked right now';
  }

  @override
  String get liveDealsSynced => '🔥 New deals synced continuously';

  @override
  String livePriceDrops(int count) {
    return '📉 Found $count price drops today';
  }

  @override
  String get liveMonitoringActive => '⚡ Live price monitoring active';

  @override
  String get recentlyViewed => 'Recently Viewed';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearHistoryTitle => 'Clear History';

  @override
  String get clearHistoryConfirm => 'Clear all recently viewed items?';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get biggestPriceDrops => 'Biggest Price Drops';

  @override
  String get last24h => 'Last 24h';

  @override
  String get insaneDeals => 'Insane Deals';

  @override
  String minDiscountBadge(int percent) {
    return '≥ $percent% off';
  }

  @override
  String get refreshDealsTooltip => 'Refresh Deals';

  @override
  String get sortTooltip => 'Sort deals';

  @override
  String sortButtonLabel(String label) {
    return 'Sort: $label';
  }

  @override
  String get sortBestDeals => 'Best Deals';

  @override
  String get sortPriceLowHigh => 'Price: Low to High';

  @override
  String get sortPriceHighLow => 'Price: High to Low';

  @override
  String get sortNewest => 'Newest';

  @override
  String get prevPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get lastPage => 'Last';

  @override
  String goToPage(int total) {
    return 'Go to page (1-$total)';
  }

  @override
  String get noDealsFound => 'No deals found';

  @override
  String get checkBackLater => 'Check back later or tap refresh.';

  @override
  String get refreshNow => 'Refresh now';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noDealsMatchFilters => 'No deals match your filters';

  @override
  String get tryCheckingTypos =>
      'Try checking for typos or removing some filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get retry => 'Retry';

  @override
  String get footerTagline => 'Scandinavia\'s smartest way to compare prices.';

  @override
  String get trustSecure => 'Secure (HTTPS)';

  @override
  String get trustVerified => 'Verified Affiliate Partner';

  @override
  String get trustGdpr => 'GDPR Compliant';

  @override
  String get trustLiveUpdates => 'Live Price Updates';

  @override
  String get trustSweden => 'Sweden';

  @override
  String get trustNorway => 'Norway';

  @override
  String get footerShop => 'Shop';

  @override
  String get footerInformation => 'Information';

  @override
  String get footerSupport => 'Support';

  @override
  String get footerAboutUs => 'About Us';

  @override
  String get footerPrivacyPolicy => 'Privacy Policy';

  @override
  String get footerTermsOfService => 'Terms of Service';

  @override
  String get footerContactUs => 'Contact Us';

  @override
  String get footerAffiliateDisclosure => 'Affiliate Disclosure';

  @override
  String footerCopyright(int year) {
    return '© $year PrisPuls. All rights reserved.';
  }
}
