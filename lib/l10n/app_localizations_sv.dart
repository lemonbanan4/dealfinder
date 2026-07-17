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
  String get heroHeadline =>
      'Se om priset faktiskt sjönk — inte bara påstås ha gjort det';

  @override
  String get heroSubheading =>
      'Vi bevakar priser dygnet runt hos flera butiker så du slipper – och slår larm så fort ett pris sjunker.';

  @override
  String get howItWorksHeading => 'Så fungerar det';

  @override
  String get howItWorksSubheading =>
      'Tre steg. Inget konto krävs för att bläddra.';

  @override
  String get howItWorksStep1Title => 'Bläddra bland bevakade produkter';

  @override
  String get howItWorksStep1Body =>
      'Elektronik och hemartiklar hos ett växande antal svenska och norska återförsäljare — uppdaterat flera gånger om dagen.';

  @override
  String get howItWorksStep2Title => 'Se den riktiga prishistoriken';

  @override
  String get howItWorksStep2Body =>
      'Varje produkt har en egen priskurva. Är \"-40%\" en riktig sänkning eller bara en uppskruvad ursprungsprissättning? Nu ser du det direkt.';

  @override
  String get howItWorksStep3Title => 'Sätt ett prislarm (valfritt)';

  @override
  String get howItWorksStep3Body =>
      'Vill du hellre slippa kolla själv? Ange ditt önskepris så mejlar vi dig när det går under gränsen.';

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

  @override
  String get accountSection => 'Konto';

  @override
  String get noEmail => 'Ingen e-post';

  @override
  String get defaultUserName => 'Användare';

  @override
  String get editNameTooltip => 'Redigera namn';

  @override
  String get changePassword => 'Byt lösenord';

  @override
  String get couldNotLoadProfile => 'Kunde inte läsa in profilen';

  @override
  String get fullNameLabel => 'Fullständigt namn';

  @override
  String get nameCannotBeEmpty => 'Namnet får inte vara tomt';

  @override
  String get save => 'Spara';

  @override
  String failedToUpdateName(String error) {
    return 'Det gick inte att uppdatera namnet: $error';
  }

  @override
  String get newPasswordLabel => 'Nytt lösenord';

  @override
  String get passwordMinLength => 'Lösenordet måste vara minst 6 tecken';

  @override
  String get passwordUpdatedSuccess => 'Lösenordet har uppdaterats!';

  @override
  String get failedToUpdatePassword =>
      'Det gick inte att uppdatera lösenordet.';

  @override
  String get preferencesSection => 'Inställningar';

  @override
  String get favoritesLabel => 'Favoriter';

  @override
  String get myFavoritesTitle => 'Mina favoriter';

  @override
  String get noFavoritesYet =>
      'Du har inte sparat några favoriter än.\nTryck på hjärtat på ett erbjudande för att spara det!';

  @override
  String get regionLabel => 'Region';

  @override
  String get currencyLabel => 'Valuta';

  @override
  String get dataPrivacySection => 'Data & Integritet';

  @override
  String get clearRecentlyViewed => 'Rensa nyligen visade';

  @override
  String get dangerZoneSection => 'Farozon';

  @override
  String get signOut => 'Logga ut';

  @override
  String get signOutConfirm => 'Är du säker på att du vill logga ut?';

  @override
  String get deleteAccount => 'Ta bort konto';

  @override
  String get deleteAccountConfirm =>
      'Är du säker på att du vill radera ditt konto permanent? Detta kan inte ångras.';

  @override
  String get delete => 'Ta bort';

  @override
  String get failedToDeleteAccount =>
      'Det gick inte att ta bort kontot. Försök igen.';

  @override
  String get loginTitle => 'Logga in';

  @override
  String get signUpTitle => 'Registrera dig';

  @override
  String get emailLabel => 'E-post';

  @override
  String get pleaseEnterEmail => 'Ange en e-postadress';

  @override
  String get passwordLabel => 'Lösenord';

  @override
  String get pleaseEnterPassword => 'Ange ett lösenord';

  @override
  String get forgotPassword => 'Glömt lösenordet?';

  @override
  String get resetPasswordTitle => 'Återställ lösenord';

  @override
  String get enterYourEmailAddress => 'Ange din e-postadress';

  @override
  String get sendLink => 'Skicka länk';

  @override
  String get resetLinkSentMessage =>
      'Om ett konto finns har en länk för återställning av lösenord skickats.';

  @override
  String get orDivider => 'ELLER';

  @override
  String get signingIn => 'Loggar in…';

  @override
  String get continueWithGoogle => 'Fortsätt med Google';

  @override
  String get signInWithApple => 'Logga in med Apple';

  @override
  String get noAccountSignUp => 'Har du inget konto? Registrera dig';

  @override
  String get haveAccountLogin => 'Har du redan ett konto? Logga in';

  @override
  String get unexpectedError => 'Ett oväntat fel uppstod.';

  @override
  String get pleaseEnterValidEmail => 'Ange en giltig e-postadress.';

  @override
  String get newsletterThanks => 'Tack! Du är nu på listan.';

  @override
  String get newsletterAlreadySignedUp =>
      'Den e-postadressen är redan registrerad.';

  @override
  String get newsletterSomethingWentWrong => 'Något gick fel. Försök igen.';

  @override
  String get newsletterHeadline => 'Få erbjudandena först';

  @override
  String get newsletterSubtitle =>
      'Anmäl dig till vårt nyhetsbrev och få de bästa erbjudandena direkt i din inkorg.';

  @override
  String get emailAddressHint => 'E-postadress';

  @override
  String get register => 'Registrera';

  @override
  String get aboutWhoWeAreHeading => 'Vilka vi är';

  @override
  String get aboutWhoWeAreBody =>
      'Jag blev trött på \"erbjudanden\" som visar sig vara rena påhitt — en butik sätter en röd \"-40%\"-skylt på ett pris som tyst höjdes veckan innan, utan något enkelt sätt att kolla.\n\nSå jag byggde PrisPuls för att göra det tråkiga men användbara jobbet: faktiskt spåra priser över tid, hos flera butiker, och visa den riktiga historiken — inte bara dagens prislapp. Är ett erbjudande en riktig sänkning ser du det i kurvan. Är det inte det, ser du det också.\n\nDet är tidigt, och det är byggt av en person. Just nu täcker det elektronik och hemartiklar hos ett växande antal svenska och norska återförsäljare, med prislarm om du hellre slipper kolla själv.';

  @override
  String get aboutMissionHeading => 'Vårt uppdrag';

  @override
  String get aboutMissionBody =>
      'Vi tror att alla konsumenter förtjänar att kunna fatta välgrundade köpbeslut utan att behöva lägga timmar på att jämföra priser på dussintals webbplatser. PrisPuls gör det jobbet åt dig — så att du kan handla smartare, spara mer och lägga din tid på det som betyder något.';

  @override
  String get aboutAffiliateBody =>
      'PrisPuls deltar i olika affiliateprogram, vilket innebär att vi kan få provision på redaktionellt utvalda produkter som köps via våra länkar till återförsäljares webbplatser.\n\nNär du klickar på en produktlänk och genomför ett köp kan PrisPuls få en mindre provision från återförsäljaren, utan extra kostnad för dig. Dessa provisioner hjälper oss att underhålla och kontinuerligt förbättra vår tjänst.\n\nVåra redaktionella beslut — inklusive vilka produkter och erbjudanden vi lyfter fram — fattas oberoende av eventuella affiliate-relationer. Vi strävar efter att alltid ge ärlig och opartisk prisinformation, oavsett om det finns en kommersiell relation med en viss återförsäljare eller inte.';

  @override
  String get aboutTeamHeading => 'Bara jag (för nu)';

  @override
  String get aboutTeamBody =>
      'PrisPuls byggs och underhålls av en person — inget kontor, inget team, bara någon som blev irriterad på falska rabatter och bestämde sig för att fixa det. Om något är förvirrande, trasigt, eller om du saknar en butik du önskar bevakades, hör gärna av dig.';

  @override
  String get aboutContactBody =>
      'Har du en fråga, hittat ett felaktigt pris eller vill samarbeta med oss?\n\nE-post: support@prispuls.com\nWebbplats: prispuls.com\n\nVi svarar vanligtvis inom två arbetsdagar.';
}
