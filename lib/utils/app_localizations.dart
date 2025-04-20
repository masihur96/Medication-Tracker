import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = {
    'en': {
      'settings': 'Settings',
      'profile': 'Profile',
      'manageProfile': 'Manage your profile information',
      'appSettings': 'App Settings',
      'medicationHistory': 'Medication History',
      'viewHistory': 'View your medication tracking history',
      'notifications': 'Notifications',
      'enableDisableNotifications': 'Enable or disable notifications',
      'darkTheme': 'Dark Theme',
      'switchTheme': 'Switch between light and dark theme',
      'moreOptions': 'More Options',
      'privacy': 'Privacy',
      'managePrivacy': 'Manage your privacy settings',
      'tellFriend': 'Tell a Friend',
      'shareApp': 'Share this app with friends',
      'about': 'About',
      'learnMore': 'Learn more about MedTrack',
      'language': 'Language',
      'selectLanguage': 'Select your preferred language',
      'version': 'Version',
      // Add more translations as needed
    },
    'bn': {
      'settings': 'সেটিংস',
      'profile': 'প্রোফাইল',
      'manageProfile': 'আপনার প্রোফাইল তথ্য পরিচালনা করুন',
      'appSettings': 'অ্যাপ সেটিংস',
      'medicationHistory': 'ঔষধের ইতিহাস',
      'viewHistory': 'আপনার ঔষধের ট্র্যাকিং ইতিহাস দেখুন',
      'notifications': 'নোটিফিকেশন',
      'enableDisableNotifications': 'নোটিফিকেশন চালু বা বন্ধ করুন',
      'darkTheme': 'ডার্ক থিম',
      'switchTheme': 'লাইট এবং ডার্ক থিমের মধ্যে পরিবর্তন করুন',
      'moreOptions': 'আরও অপশন',
      'privacy': 'গোপনীয়তা',
      'managePrivacy': 'আপনার গোপনীয়তা সেটিংস পরিচালনা করুন',
      'tellFriend': 'বন্ধুদের বলুন',
      'shareApp': 'এই অ্যাপটি বন্ধুদের সাথে শেয়ার করুন',
      'about': 'সম্পর্কে',
      'learnMore': 'মেডট্র্যাক সম্পর্কে আরও জানুন',
      'language': 'ভাষা',
      'selectLanguage': 'আপনার পছন্দের ভাষা নির্বাচন করুন',
      'version': 'ভার্সন',
      // Add more translations as needed
    },
  };

  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get manageProfile => _localizedValues[locale.languageCode]!['manageProfile']!;
  String get appSettings => _localizedValues[locale.languageCode]!['appSettings']!;
  String get medicationHistory => _localizedValues[locale.languageCode]!['medicationHistory']!;
  String get viewHistory => _localizedValues[locale.languageCode]!['viewHistory']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get enableDisableNotifications => _localizedValues[locale.languageCode]!['enableDisableNotifications']!;
  String get darkTheme => _localizedValues[locale.languageCode]!['darkTheme']!;
  String get switchTheme => _localizedValues[locale.languageCode]!['switchTheme']!;
  String get moreOptions => _localizedValues[locale.languageCode]!['moreOptions']!;
  String get privacy => _localizedValues[locale.languageCode]!['privacy']!;
  String get managePrivacy => _localizedValues[locale.languageCode]!['managePrivacy']!;
  String get tellFriend => _localizedValues[locale.languageCode]!['tellFriend']!;
  String get shareApp => _localizedValues[locale.languageCode]!['shareApp']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get learnMore => _localizedValues[locale.languageCode]!['learnMore']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get selectLanguage => _localizedValues[locale.languageCode]!['selectLanguage']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 