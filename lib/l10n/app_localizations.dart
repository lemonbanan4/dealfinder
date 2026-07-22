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

  /// No description provided for @heroHeadline.
  ///
  /// In en, this message translates to:
  /// **'See if the price actually dropped — not just claimed to'**
  String get heroHeadline;

  /// No description provided for @heroSubheading.
  ///
  /// In en, this message translates to:
  /// **'We track prices around the clock across multiple stores so you don\'t have to — and alert you the moment a price drops.'**
  String get heroSubheading;

  /// No description provided for @howItWorksHeading.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorksHeading;

  /// No description provided for @howItWorksSubheading.
  ///
  /// In en, this message translates to:
  /// **'Three steps. No account needed to browse.'**
  String get howItWorksSubheading;

  /// No description provided for @howItWorksStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Browse tracked products'**
  String get howItWorksStep1Title;

  /// No description provided for @howItWorksStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Electronics and home goods across a growing list of Swedish and Norwegian retailers — updated multiple times a day.'**
  String get howItWorksStep1Body;

  /// No description provided for @howItWorksStep2Title.
  ///
  /// In en, this message translates to:
  /// **'See the real price history'**
  String get howItWorksStep2Title;

  /// No description provided for @howItWorksStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Every product has its own price curve. Is \"-40%\" a real drop or just an inflated original price? Now you can see it instantly.'**
  String get howItWorksStep2Body;

  /// No description provided for @howItWorksStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Set a price alert (optional)'**
  String get howItWorksStep3Title;

  /// No description provided for @howItWorksStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Would rather not check yourself? Set your target price and we\'ll email you when it drops below it.'**
  String get howItWorksStep3Body;

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

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @editNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editNameTooltip;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get couldNotLoadProfile;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @failedToUpdateName.
  ///
  /// In en, this message translates to:
  /// **'Failed to update name: {error}'**
  String failedToUpdateName(String error);

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdatedSuccess;

  /// No description provided for @failedToUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password.'**
  String get failedToUpdatePassword;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @favoritesLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesLabel;

  /// No description provided for @myFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavoritesTitle;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any favorites yet.\nTap the heart on a deal to save it!'**
  String get noFavoritesYet;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @dataPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacySection;

  /// No description provided for @clearRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Clear recently viewed'**
  String get clearRecentlyViewed;

  /// No description provided for @dangerZoneSection.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZoneSection;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @failedToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get failedToDeleteAccount;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterEmail;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @resetLinkSentMessage.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, a password reset link has been sent.'**
  String get resetLinkSentMessage;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get noAccountSignUp;

  /// No description provided for @haveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get haveAccountLogin;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get pleaseEnterValidEmail;

  /// No description provided for @newsletterThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! You\'re on the list.'**
  String get newsletterThanks;

  /// No description provided for @newsletterAlreadySignedUp.
  ///
  /// In en, this message translates to:
  /// **'That email is already signed up.'**
  String get newsletterAlreadySignedUp;

  /// No description provided for @newsletterSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get newsletterSomethingWentWrong;

  /// No description provided for @newsletterHeadline.
  ///
  /// In en, this message translates to:
  /// **'Get the deals first'**
  String get newsletterHeadline;

  /// No description provided for @newsletterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up for our newsletter and get the best deals straight to your inbox.'**
  String get newsletterSubtitle;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressHint;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @aboutWhoWeAreHeading.
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get aboutWhoWeAreHeading;

  /// No description provided for @aboutWhoWeAreBody.
  ///
  /// In en, this message translates to:
  /// **'I got tired of \"deals\" that turn out to be nothing of the sort — a store slaps a red \"-40%\" badge on a price that was quietly raised the week before, with no easy way to check.\n\nSo I built PrisPuls to do the boring, useful thing: actually track prices over time, across stores, and show the real history — not just today\'s sticker price. If a deal is a genuine drop, you\'ll see the line go down. If it isn\'t, you\'ll see that too.\n\nIt\'s early, and it\'s built by one person. Right now it covers electronics and home goods across a growing list of Swedish and Norwegian retailers, with price alerts if you\'d rather not check back yourself.'**
  String get aboutWhoWeAreBody;

  /// No description provided for @aboutMissionHeading.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get aboutMissionHeading;

  /// No description provided for @aboutMissionBody.
  ///
  /// In en, this message translates to:
  /// **'We believe every consumer deserves to make informed purchasing decisions without spending hours comparing prices across dozens of websites. PrisPuls does that work for you — so you can buy smarter, save more, and spend your time on what matters.'**
  String get aboutMissionBody;

  /// No description provided for @aboutAffiliateBody.
  ///
  /// In en, this message translates to:
  /// **'PrisPuls participates in various affiliate marketing programs, which means we may get paid commissions on editorially chosen products purchased through our links to retailer sites.\n\nWhen you click on a product link and complete a purchase, PrisPuls may earn a small commission from the retailer at no additional cost to you. These commissions help us maintain and continuously improve our service.\n\nOur editorial decisions — including which products and deals we feature — are made independently of any affiliate relationship. We are committed to providing honest, unbiased pricing information regardless of whether a commercial relationship exists with a given retailer.'**
  String get aboutAffiliateBody;

  /// No description provided for @aboutTeamHeading.
  ///
  /// In en, this message translates to:
  /// **'Just Me (For Now)'**
  String get aboutTeamHeading;

  /// No description provided for @aboutTeamBody.
  ///
  /// In en, this message translates to:
  /// **'PrisPuls is built and maintained by one person — no office, no team, just someone who got annoyed by fake discounts and decided to fix it. If something\'s confusing, broken, or missing a store you wish it tracked, I\'d genuinely like to hear about it.'**
  String get aboutTeamBody;

  /// No description provided for @aboutContactBody.
  ///
  /// In en, this message translates to:
  /// **'Have a question, found an incorrect price, or want to partner with us?\n\nEmail: support@prispuls.com\nWebsite: prispuls.com\n\nWe typically respond within two business days.'**
  String get aboutContactBody;

  /// No description provided for @priceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Price history'**
  String get priceHistoryTitle;

  /// No description provided for @priceHistoryLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest tracked'**
  String get priceHistoryLowest;

  /// No description provided for @priceHistoryHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest tracked'**
  String get priceHistoryHighest;

  /// No description provided for @priceHistoryCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get priceHistoryCurrent;

  /// No description provided for @priceHistoryNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough price history yet — we\'ve only just started tracking this product. Check back soon to see how its price moves.'**
  String get priceHistoryNotEnough;

  /// No description provided for @priceHistorySince.
  ///
  /// In en, this message translates to:
  /// **'Tracked since {date}'**
  String priceHistorySince(String date);

  /// No description provided for @priceHistoryIsLowest.
  ///
  /// In en, this message translates to:
  /// **'This is the lowest price we\'ve seen 🎉'**
  String get priceHistoryIsLowest;
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
