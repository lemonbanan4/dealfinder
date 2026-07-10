import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb'),
    Locale('sv'),
  ];

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products or brands...'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @categoriesButton.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesButton;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @groupElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics & Tech'**
  String get groupElectronics;

  /// No description provided for @groupLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & Everyday'**
  String get groupLifestyle;

  /// No description provided for @catSmartphones.
  ///
  /// In en, this message translates to:
  /// **'Smartphones'**
  String get catSmartphones;

  /// No description provided for @catTablets.
  ///
  /// In en, this message translates to:
  /// **'Tablets'**
  String get catTablets;

  /// No description provided for @catWearables.
  ///
  /// In en, this message translates to:
  /// **'Wearables'**
  String get catWearables;

  /// No description provided for @catLaptopsPc.
  ///
  /// In en, this message translates to:
  /// **'Laptops/PC'**
  String get catLaptopsPc;

  /// No description provided for @catMonitors.
  ///
  /// In en, this message translates to:
  /// **'Monitors'**
  String get catMonitors;

  /// No description provided for @catTVs.
  ///
  /// In en, this message translates to:
  /// **'TVs'**
  String get catTVs;

  /// No description provided for @catAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get catAudio;

  /// No description provided for @catGamingAccessories.
  ///
  /// In en, this message translates to:
  /// **'Gaming Accessories'**
  String get catGamingAccessories;

  /// No description provided for @catAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get catAccessories;

  /// No description provided for @catHomeElectronics.
  ///
  /// In en, this message translates to:
  /// **'Home Electronics'**
  String get catHomeElectronics;

  /// No description provided for @catFashionClothing.
  ///
  /// In en, this message translates to:
  /// **'Fashion & Clothing'**
  String get catFashionClothing;

  /// No description provided for @catBeautyHealth.
  ///
  /// In en, this message translates to:
  /// **'Beauty & Health'**
  String get catBeautyHealth;

  /// No description provided for @catHomeGarden.
  ///
  /// In en, this message translates to:
  /// **'Home & Garden'**
  String get catHomeGarden;

  /// No description provided for @catSportsOutdoors.
  ///
  /// In en, this message translates to:
  /// **'Sports & Outdoors'**
  String get catSportsOutdoors;

  /// No description provided for @catToysKids.
  ///
  /// In en, this message translates to:
  /// **'Toys & Kids'**
  String get catToysKids;

  /// No description provided for @catGroceriesFood.
  ///
  /// In en, this message translates to:
  /// **'Groceries & Food'**
  String get catGroceriesFood;

  /// No description provided for @catAutomotive.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get catAutomotive;

  /// No description provided for @catBooksMedia.
  ///
  /// In en, this message translates to:
  /// **'Books & Media'**
  String get catBooksMedia;

  /// No description provided for @catPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get catPets;

  /// No description provided for @catTravelLuggage.
  ///
  /// In en, this message translates to:
  /// **'Travel & Luggage'**
  String get catTravelLuggage;

  /// No description provided for @liveHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Live Market Price Tracker'**
  String get liveHeroHeadline;

  /// No description provided for @liveDealsTracked.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count}+ deals tracked right now'**
  String liveDealsTracked(int count);

  /// No description provided for @liveDealsSynced.
  ///
  /// In en, this message translates to:
  /// **'🔥 New deals synced continuously'**
  String get liveDealsSynced;

  /// No description provided for @livePriceDrops.
  ///
  /// In en, this message translates to:
  /// **'📉 Found {count} price drops today'**
  String livePriceDrops(int count);

  /// No description provided for @liveMonitoringActive.
  ///
  /// In en, this message translates to:
  /// **'⚡ Live price monitoring active'**
  String get liveMonitoringActive;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get recentlyViewed;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all recently viewed items?'**
  String get clearHistoryConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @biggestPriceDrops.
  ///
  /// In en, this message translates to:
  /// **'Biggest Price Drops'**
  String get biggestPriceDrops;

  /// No description provided for @last24h.
  ///
  /// In en, this message translates to:
  /// **'Last 24h'**
  String get last24h;

  /// No description provided for @insaneDeals.
  ///
  /// In en, this message translates to:
  /// **'Insane Deals'**
  String get insaneDeals;

  /// No description provided for @minDiscountBadge.
  ///
  /// In en, this message translates to:
  /// **'≥ {percent}% off'**
  String minDiscountBadge(int percent);

  /// No description provided for @refreshDealsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Deals'**
  String get refreshDealsTooltip;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort deals'**
  String get sortTooltip;

  /// No description provided for @sortButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort: {label}'**
  String sortButtonLabel(String label);

  /// No description provided for @sortBestDeals.
  ///
  /// In en, this message translates to:
  /// **'Best Deals'**
  String get sortBestDeals;

  /// No description provided for @sortPriceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLowHigh;

  /// No description provided for @sortPriceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHighLow;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @prevPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get prevPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @lastPage.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get lastPage;

  /// No description provided for @goToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page (1-{total})'**
  String goToPage(int total);

  /// No description provided for @noDealsFound.
  ///
  /// In en, this message translates to:
  /// **'No deals found'**
  String get noDealsFound;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later or tap refresh.'**
  String get checkBackLater;

  /// No description provided for @refreshNow.
  ///
  /// In en, this message translates to:
  /// **'Refresh now'**
  String get refreshNow;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @noDealsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No deals match your filters'**
  String get noDealsMatchFilters;

  /// No description provided for @tryCheckingTypos.
  ///
  /// In en, this message translates to:
  /// **'Try checking for typos or removing some filters.'**
  String get tryCheckingTypos;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @footerTagline.
  ///
  /// In en, this message translates to:
  /// **'Scandinavia\'s smartest way to compare prices.'**
  String get footerTagline;

  /// No description provided for @trustSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure (HTTPS)'**
  String get trustSecure;

  /// No description provided for @trustVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified Affiliate Partner'**
  String get trustVerified;

  /// No description provided for @trustGdpr.
  ///
  /// In en, this message translates to:
  /// **'GDPR Compliant'**
  String get trustGdpr;

  /// No description provided for @trustLiveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Live Price Updates'**
  String get trustLiveUpdates;

  /// No description provided for @trustSweden.
  ///
  /// In en, this message translates to:
  /// **'Sweden'**
  String get trustSweden;

  /// No description provided for @trustNorway.
  ///
  /// In en, this message translates to:
  /// **'Norway'**
  String get trustNorway;

  /// No description provided for @footerShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get footerShop;

  /// No description provided for @footerInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get footerInformation;

  /// No description provided for @footerSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get footerSupport;

  /// No description provided for @footerAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get footerAboutUs;

  /// No description provided for @footerPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get footerPrivacyPolicy;

  /// No description provided for @footerTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get footerTermsOfService;

  /// No description provided for @footerContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get footerContactUs;

  /// No description provided for @footerAffiliateDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Affiliate Disclosure'**
  String get footerAffiliateDisclosure;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} PrisPuls. All rights reserved.'**
  String footerCopyright(int year);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nb', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
