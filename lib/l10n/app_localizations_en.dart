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

  @override
  String get accountSection => 'Account';

  @override
  String get noEmail => 'No email';

  @override
  String get defaultUserName => 'User';

  @override
  String get editNameTooltip => 'Edit Name';

  @override
  String get changePassword => 'Change Password';

  @override
  String get couldNotLoadProfile => 'Could not load profile';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get save => 'Save';

  @override
  String failedToUpdateName(String error) {
    return 'Failed to update name: $error';
  }

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully!';

  @override
  String get failedToUpdatePassword => 'Failed to update password.';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get regionLabel => 'Region';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get dataPrivacySection => 'Data & Privacy';

  @override
  String get clearRecentlyViewed => 'Clear recently viewed';

  @override
  String get dangerZoneSection => 'Danger Zone';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get failedToDeleteAccount =>
      'Failed to delete account. Please try again.';

  @override
  String get loginTitle => 'Login';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get emailLabel => 'Email';

  @override
  String get pleaseEnterEmail => 'Please enter an email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get enterYourEmailAddress => 'Enter your email address';

  @override
  String get sendLink => 'Send Link';

  @override
  String get resetLinkSentMessage =>
      'If an account exists, a password reset link has been sent.';

  @override
  String get orDivider => 'OR';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign Up';

  @override
  String get haveAccountLogin => 'Already have an account? Login';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email.';

  @override
  String get newsletterThanks => 'Thanks! You\'re on the list.';

  @override
  String get newsletterAlreadySignedUp => 'That email is already signed up.';

  @override
  String get newsletterSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get newsletterHeadline => 'Get the deals first';

  @override
  String get newsletterSubtitle =>
      'Sign up for our newsletter and get the best deals straight to your inbox.';

  @override
  String get emailAddressHint => 'Email address';

  @override
  String get register => 'Register';

  @override
  String get aboutWhoWeAreHeading => 'Who We Are';

  @override
  String get aboutWhoWeAreBody =>
      'PrisPuls is a Scandinavian price-comparison and deal-discovery service built to help consumers find the best prices on electronics, home goods, fashion, and more — all in one place.\n\nOur platform aggregates offers from hundreds of retailers, refreshed multiple times a day, so you always have the most current pricing at your fingertips.';

  @override
  String get aboutMissionHeading => 'Our Mission';

  @override
  String get aboutMissionBody =>
      'We believe every consumer deserves to make informed purchasing decisions without spending hours comparing prices across dozens of websites. PrisPuls does that work for you — so you can buy smarter, save more, and spend your time on what matters.';

  @override
  String get aboutAffiliateBody =>
      'PrisPuls participates in various affiliate marketing programs, which means we may get paid commissions on editorially chosen products purchased through our links to retailer sites.\n\nWhen you click on a product link and complete a purchase, PrisPuls may earn a small commission from the retailer at no additional cost to you. These commissions help us maintain and continuously improve our service.\n\nOur editorial decisions — including which products and deals we feature — are made independently of any affiliate relationship. We are committed to providing honest, unbiased pricing information regardless of whether a commercial relationship exists with a given retailer.';

  @override
  String get aboutTeamHeading => 'Our Team';

  @override
  String get aboutTeamBody =>
      'PrisPuls is built and maintained by a small, passionate team dedicated to consumer transparency and fair pricing. We are headquartered in Norway and serve users across the Nordic region.';

  @override
  String get aboutContactBody =>
      'Have a question, found an incorrect price, or want to partner with us?\n\nEmail: support@prispuls.com\nWebsite: www.prispuls.com\n\nWe typically respond within two business days.';
}
