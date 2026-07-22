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
  String get heroHeadline =>
      'See if the price actually dropped — not just claimed to';

  @override
  String get heroSubheading =>
      'We track prices around the clock across multiple stores so you don\'t have to — and alert you the moment a price drops.';

  @override
  String get howItWorksHeading => 'How It Works';

  @override
  String get howItWorksSubheading =>
      'Three steps. No account needed to browse.';

  @override
  String get howItWorksStep1Title => 'Browse tracked products';

  @override
  String get howItWorksStep1Body =>
      'Electronics and home goods across a growing list of Swedish and Norwegian retailers — updated multiple times a day.';

  @override
  String get howItWorksStep2Title => 'See the real price history';

  @override
  String get howItWorksStep2Body =>
      'Every product has its own price curve. Is \"-40%\" a real drop or just an inflated original price? Now you can see it instantly.';

  @override
  String get howItWorksStep3Title => 'Set a price alert (optional)';

  @override
  String get howItWorksStep3Body =>
      'Would rather not check yourself? Set your target price and we\'ll email you when it drops below it.';

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
  String get favoritesLabel => 'Favorites';

  @override
  String get myFavoritesTitle => 'My Favorites';

  @override
  String get noFavoritesYet =>
      'You haven\'t saved any favorites yet.\nTap the heart on a deal to save it!';

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
      'I got tired of \"deals\" that turn out to be nothing of the sort — a store slaps a red \"-40%\" badge on a price that was quietly raised the week before, with no easy way to check.\n\nSo I built PrisPuls to do the boring, useful thing: actually track prices over time, across stores, and show the real history — not just today\'s sticker price. If a deal is a genuine drop, you\'ll see the line go down. If it isn\'t, you\'ll see that too.\n\nIt\'s early, and it\'s built by one person. Right now it covers electronics and home goods across a growing list of Swedish and Norwegian retailers, with price alerts if you\'d rather not check back yourself.';

  @override
  String get aboutMissionHeading => 'Our Mission';

  @override
  String get aboutMissionBody =>
      'We believe every consumer deserves to make informed purchasing decisions without spending hours comparing prices across dozens of websites. PrisPuls does that work for you — so you can buy smarter, save more, and spend your time on what matters.';

  @override
  String get aboutAffiliateBody =>
      'PrisPuls participates in various affiliate marketing programs, which means we may get paid commissions on editorially chosen products purchased through our links to retailer sites.\n\nWhen you click on a product link and complete a purchase, PrisPuls may earn a small commission from the retailer at no additional cost to you. These commissions help us maintain and continuously improve our service.\n\nOur editorial decisions — including which products and deals we feature — are made independently of any affiliate relationship. We are committed to providing honest, unbiased pricing information regardless of whether a commercial relationship exists with a given retailer.';

  @override
  String get aboutTeamHeading => 'Just Me (For Now)';

  @override
  String get aboutTeamBody =>
      'PrisPuls is built and maintained by one person — no office, no team, just someone who got annoyed by fake discounts and decided to fix it. If something\'s confusing, broken, or missing a store you wish it tracked, I\'d genuinely like to hear about it.';

  @override
  String get aboutContactBody =>
      'Have a question, found an incorrect price, or want to partner with us?\n\nEmail: support@prispuls.com\nWebsite: prispuls.com\n\nWe typically respond within two business days.';

  @override
  String get priceHistoryTitle => 'Price history';

  @override
  String get priceHistoryLowest => 'Lowest tracked';

  @override
  String get priceHistoryHighest => 'Highest tracked';

  @override
  String get priceHistoryCurrent => 'Current';

  @override
  String get priceHistoryNotEnough =>
      'Not enough price history yet — we\'ve only just started tracking this product. Check back soon to see how its price moves.';

  @override
  String priceHistorySince(String date) {
    return 'Tracked since $date';
  }

  @override
  String get priceHistoryIsLowest => 'This is the lowest price we\'ve seen 🎉';

  @override
  String get linkNotTracked =>
      'We don\'t track that product yet — try searching by name, or check one of our covered stores.';
}
