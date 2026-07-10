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

  @override
  String get accountSection => 'Konto';

  @override
  String get noEmail => 'Ingen e-post';

  @override
  String get defaultUserName => 'Bruker';

  @override
  String get editNameTooltip => 'Rediger navn';

  @override
  String get changePassword => 'Endre passord';

  @override
  String get couldNotLoadProfile => 'Kunne ikke laste inn profilen';

  @override
  String get fullNameLabel => 'Fullt navn';

  @override
  String get nameCannotBeEmpty => 'Navnet kan ikke være tomt';

  @override
  String get save => 'Lagre';

  @override
  String failedToUpdateName(String error) {
    return 'Kunne ikke oppdatere navnet: $error';
  }

  @override
  String get newPasswordLabel => 'Nytt passord';

  @override
  String get passwordMinLength => 'Passordet må være minst 6 tegn';

  @override
  String get passwordUpdatedSuccess => 'Passordet er oppdatert!';

  @override
  String get failedToUpdatePassword => 'Kunne ikke oppdatere passordet.';

  @override
  String get preferencesSection => 'Innstillinger';

  @override
  String get regionLabel => 'Region';

  @override
  String get themeLabel => 'Tema';

  @override
  String get currencyLabel => 'Valuta';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Lyst';

  @override
  String get themeDark => 'Mørkt';

  @override
  String get themeAmoled => 'Amoled';

  @override
  String get dataPrivacySection => 'Data & Personvern';

  @override
  String get clearRecentlyViewed => 'Fjern nylig sett';

  @override
  String get dangerZoneSection => 'Faresone';

  @override
  String get signOut => 'Logg ut';

  @override
  String get signOutConfirm => 'Er du sikker på at du vil logge ut?';

  @override
  String get deleteAccount => 'Slett konto';

  @override
  String get deleteAccountConfirm =>
      'Er du sikker på at du vil slette kontoen din permanent? Dette kan ikke angres.';

  @override
  String get delete => 'Slett';

  @override
  String get failedToDeleteAccount => 'Kunne ikke slette kontoen. Prøv igjen.';

  @override
  String get loginTitle => 'Logg inn';

  @override
  String get signUpTitle => 'Registrer deg';

  @override
  String get emailLabel => 'E-post';

  @override
  String get pleaseEnterEmail => 'Oppgi en e-postadresse';

  @override
  String get passwordLabel => 'Passord';

  @override
  String get pleaseEnterPassword => 'Oppgi et passord';

  @override
  String get forgotPassword => 'Glemt passord?';

  @override
  String get resetPasswordTitle => 'Tilbakestill passord';

  @override
  String get enterYourEmailAddress => 'Oppgi e-postadressen din';

  @override
  String get sendLink => 'Send lenke';

  @override
  String get resetLinkSentMessage =>
      'Hvis en konto finnes, er en lenke for tilbakestilling av passord sendt.';

  @override
  String get orDivider => 'ELLER';

  @override
  String get signingIn => 'Logger inn…';

  @override
  String get continueWithGoogle => 'Fortsett med Google';

  @override
  String get continueWithApple => 'Fortsett med Apple';

  @override
  String get noAccountSignUp => 'Har du ikke en konto? Registrer deg';

  @override
  String get haveAccountLogin => 'Har du allerede en konto? Logg inn';

  @override
  String get unexpectedError => 'En uventet feil oppstod.';

  @override
  String get pleaseEnterValidEmail => 'Oppgi en gyldig e-postadresse.';

  @override
  String get newsletterThanks => 'Takk! Du er nå på listen.';

  @override
  String get newsletterAlreadySignedUp =>
      'Den e-postadressen er allerede registrert.';

  @override
  String get newsletterSomethingWentWrong => 'Noe gikk galt. Prøv igjen.';

  @override
  String get newsletterHeadline => 'Få tilbudene først';

  @override
  String get newsletterSubtitle =>
      'Meld deg på nyhetsbrevet vårt og få de beste tilbudene rett i innboksen.';

  @override
  String get emailAddressHint => 'E-postadresse';

  @override
  String get register => 'Registrer';

  @override
  String get aboutWhoWeAreHeading => 'Hvem vi er';

  @override
  String get aboutWhoWeAreBody =>
      'PrisPuls er en skandinavisk tjeneste for prissammenligning og tilbud, bygget for å hjelpe forbrukere med å finne de beste prisene på elektronikk, hjemmeartikler, mote og mer — alt på ett sted.\n\nPlattformen vår samler tilbud fra hundrevis av forhandlere, oppdatert flere ganger daglig, slik at du alltid har de mest oppdaterte prisene lett tilgjengelig.';

  @override
  String get aboutMissionHeading => 'Vårt oppdrag';

  @override
  String get aboutMissionBody =>
      'Vi mener at alle forbrukere fortjener å kunne ta informerte kjøpsbeslutninger uten å bruke timevis på å sammenligne priser på dusinvis av nettsteder. PrisPuls gjør den jobben for deg — slik at du kan handle smartere, spare mer og bruke tiden din på det som betyr noe.';

  @override
  String get aboutAffiliateBody =>
      'PrisPuls deltar i ulike affiliateprogrammer, noe som betyr at vi kan motta provisjon på redaksjonelt utvalgte produkter kjøpt gjennom våre lenker til forhandleres nettsteder.\n\nNår du klikker på en produktlenke og gjennomfører et kjøp, kan PrisPuls motta en liten provisjon fra forhandleren, uten ekstra kostnad for deg. Disse provisjonene hjelper oss å vedlikeholde og kontinuerlig forbedre tjenesten.\n\nVåre redaksjonelle beslutninger — inkludert hvilke produkter og tilbud vi fremhever — tas uavhengig av eventuelle affiliate-relasjoner. Vi er forpliktet til å gi ærlig og upartisk prisinformasjon, uavhengig av om det foreligger et kommersielt forhold til en gitt forhandler.';

  @override
  String get aboutTeamHeading => 'Vårt team';

  @override
  String get aboutTeamBody =>
      'PrisPuls bygges og driftes av et lite, engasjert team dedikert til forbrukertransparens og rettferdige priser. Vi har hovedkontor i Norge og betjener brukere i hele Norden.';

  @override
  String get aboutContactBody =>
      'Har du et spørsmål, funnet en feil pris, eller ønsker å samarbeide med oss?\n\nE-post: support@prispuls.com\nNettside: www.prispuls.com\n\nVi svarer vanligvis innen to virkedager.';
}
