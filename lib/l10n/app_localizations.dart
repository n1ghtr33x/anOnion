import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @authLoginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid login or password'**
  String get authLoginInvalid;

  /// No description provided for @authLoginConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get authLoginConnectionError;

  /// No description provided for @authLoginAccount.
  ///
  /// In en, this message translates to:
  /// **'Account login'**
  String get authLoginAccount;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authLoginPassword;

  /// No description provided for @authLoginLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginLogIn;

  /// No description provided for @authLoginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authLoginSignUp;

  /// No description provided for @authRegistrationLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration successful, but login failed'**
  String get authRegistrationLoginFailed;

  /// No description provided for @authRegistrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get authRegistrationError;

  /// No description provided for @authRegistrationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get authRegistrationInvalid;

  /// No description provided for @authRegistrationConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get authRegistrationConnectionError;

  /// No description provided for @authRegistrationAccountCreation.
  ///
  /// In en, this message translates to:
  /// **'Account creation'**
  String get authRegistrationAccountCreation;

  /// No description provided for @authRegistrationName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authRegistrationName;

  /// No description provided for @authRegistrationPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authRegistrationPassword;

  /// No description provided for @authRegistrationRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegistrationRegister;

  /// No description provided for @authRegistrationAlreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get authRegistrationAlreadyHaveAnAccount;

  /// No description provided for @chatListProfileError.
  ///
  /// In en, this message translates to:
  /// **'Profile retrieval error'**
  String get chatListProfileError;

  /// No description provided for @chatListCreateChatByUsername.
  ///
  /// In en, this message translates to:
  /// **'Create chat by username'**
  String get chatListCreateChatByUsername;

  /// No description provided for @chatListEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get chatListEnterUsername;

  /// No description provided for @chatListCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatListCancel;

  /// No description provided for @chatListUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown..'**
  String get chatListUnknown;

  /// No description provided for @chatListCreationError.
  ///
  /// In en, this message translates to:
  /// **'Chat creation error'**
  String get chatListCreationError;

  /// No description provided for @chatListCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get chatListCreate;

  /// No description provided for @chatListChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatListChats;

  /// No description provided for @chatListCreateChat.
  ///
  /// In en, this message translates to:
  /// **'Create chat'**
  String get chatListCreateChat;

  /// No description provided for @chatListNoChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get chatListNoChatsYet;

  /// No description provided for @chatListPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chatListPhoto;

  /// No description provided for @chatEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get chatEditMessage;

  /// No description provided for @chatNewText.
  ///
  /// In en, this message translates to:
  /// **'Enter new text'**
  String get chatNewText;

  /// No description provided for @chatCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatCancel;

  /// No description provided for @chatSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chatSave;

  /// No description provided for @chatEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get chatEdit;

  /// No description provided for @chatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatDelete;

  /// No description provided for @chatMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsThemeChoice.
  ///
  /// In en, this message translates to:
  /// **'Theme selection'**
  String get settingsThemeChoice;

  /// No description provided for @settingsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get settingsCurrent;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get settingsAboutApp;

  /// No description provided for @settingsChooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get settingsChooseTheme;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 0.0.3'**
  String get settingsAppVersion;

  /// No description provided for @settingsAppAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author: @dima_luts\n© 2025 All rights reserved.'**
  String get settingsAppAuthor;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @settingsApppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsApppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsLanguage;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get appearanceTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageTitle;

  /// No description provided for @mainChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get mainChats;

  /// No description provided for @mainProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get mainProfile;

  /// No description provided for @mainSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mainSettings;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
