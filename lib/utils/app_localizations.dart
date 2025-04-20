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
      'addMedication': 'Add Medication',
      'medicationName': 'Medication Name',
      'dosage': 'Dosage',
      'frequency': 'Frequency',
      'schedule': 'Schedule',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'home': 'Home',
      'upcomingDoses': 'Upcoming Doses',
      'todaysMedications': "Today's Medications",
      'noMedications': 'No medications scheduled',
      'confirmDelete': 'Confirm Delete',
      'deleteConfirmMessage': 'Are you sure you want to delete this medication?',
      'yes': 'Yes',
      'no': 'No',
      'dashboard': 'Dashboard',
      'drug': 'Drug',
      'rx': 'Rx',
      'dosageMonitor': 'Dosage Monitor',
      'pending': 'Pending',
      'medications': 'Medications',
      'drugs': 'Drugs',
      'stock': 'Stock',
      'active': 'Active',
      'inactive': 'Inactive',
      'noMedicationsYet': 'No medications added yet',
      'time': 'Time',
      'notes': 'Notes',
      'notSet': 'Not set',
      'notTaking': 'Not taking',
      'discontinued': 'Discontinued',
      'currentStock': 'Current Stock',
      'units': 'units',
      'prescriptions': 'Prescriptions',
      'noPrescriptionsFound': 'No prescriptions found',
      'addPrescription': 'Add Prescription',
      'chamber': 'Ch',
      'patient': 'Pt',
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
      'addMedication': 'ঔষধ যোগ করুন',
      'medicationName': 'ঔষধের নাম',
      'dosage': 'মাত্রা',
      'frequency': 'ফ্রিকোয়েন্সি',
      'schedule': 'সময়সূচী',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল করুন',
      'delete': 'মুছে ফেলুন',
      'edit': 'সম্পাদনা করুন',
      'home': 'হোম',
      'upcomingDoses': 'আসন্ন ডোজ',
      'todaysMedications': 'আজকের ঔষধ',
      'noMedications': 'কোন ঔষধ নির্ধারিত নেই',
      'confirmDelete': 'মুছে ফেলা নিশ্চিত করুন',
      'deleteConfirmMessage': 'আপনি কি এই ঔষধটি মুছে ফেলতে চান?',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'dashboard': 'ড্যাশবোর্ড',
      'drug': 'ঔষধ',
      'rx': 'প্রেসক্রিপশন',
      'dosageMonitor': 'ডোজ মনিটর',
      'medications': 'ঔষধসমূহ',
      'drugs': 'ঔষধ',
      'stock': 'মজুদ',
      'active': 'সক্রিয়',
      'inactive': 'নিষ্ক্রিয়',
      'noMedicationsYet': 'এখনও কোন ঔষধ যোগ করা হয়নি',
      'time': 'সময়',
      'notes': 'নোট',
      'notSet': 'সেট করা হয়নি',
      'notTaking': 'খাচ্ছি না',
      'discontinued': 'বন্ধ করা হয়েছে',
      'currentStock': 'বর্তমান মজুদ',
      'units': 'ইউনিট',
      'prescriptions': 'প্রেসক্রিপশন',
      'noPrescriptionsFound': 'কোন প্রেসক্রিপশন পাওয়া যায়নি',
      'addPrescription': 'প্রেসক্রিপশন যোগ করুন',
      'chamber': 'চে',
      'patient': 'রো',
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
  String get addMedication => _localizedValues[locale.languageCode]!['addMedication']!;
  String get medicationName => _localizedValues[locale.languageCode]!['medicationName']!;
  String get dosage => _localizedValues[locale.languageCode]!['dosage']!;
  String get frequency => _localizedValues[locale.languageCode]!['frequency']!;
  String get schedule => _localizedValues[locale.languageCode]!['schedule']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get upcomingDoses => _localizedValues[locale.languageCode]!['upcomingDoses']!;
  String get todaysMedications => _localizedValues[locale.languageCode]!['todaysMedications']!;
  String get noMedications => _localizedValues[locale.languageCode]!['noMedications']!;
  String get confirmDelete => _localizedValues[locale.languageCode]!['confirmDelete']!;
  String get deleteConfirmMessage => _localizedValues[locale.languageCode]!['deleteConfirmMessage']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get dashboard => _localizedValues[locale.languageCode]!['dashboard']!;
  String get drug => _localizedValues[locale.languageCode]!['drug']!;
  String get rx => _localizedValues[locale.languageCode]!['rx']!;
  String get dosageMonitor => _localizedValues[locale.languageCode]!['dosageMonitor']!;
  String get medications => _localizedValues[locale.languageCode]!['medications']!;
  String get drugs => _localizedValues[locale.languageCode]!['drugs']!;
  String get stock => _localizedValues[locale.languageCode]!['stock']!;
  String get active => _localizedValues[locale.languageCode]!['active']!;
  String get inactive => _localizedValues[locale.languageCode]!['inactive']!;
  String get noMedicationsYet => _localizedValues[locale.languageCode]!['noMedicationsYet']!;
  String get time => _localizedValues[locale.languageCode]!['time']!;
  String get notes => _localizedValues[locale.languageCode]!['notes']!;
  String get notSet => _localizedValues[locale.languageCode]!['notSet']!;
  String get notTaking => _localizedValues[locale.languageCode]!['notTaking']!;
  String get discontinued => _localizedValues[locale.languageCode]!['discontinued']!;
  String get currentStock => _localizedValues[locale.languageCode]!['currentStock']!;
  String get units => _localizedValues[locale.languageCode]!['units']!;
  String get prescriptions => _localizedValues[locale.languageCode]!['prescriptions']!;
  String get noPrescriptionsFound => _localizedValues[locale.languageCode]!['noPrescriptionsFound']!;
  String get addPrescription => _localizedValues[locale.languageCode]!['addPrescription']!;
  String get chamber => _localizedValues[locale.languageCode]!['chamber']!;
  String get patient => _localizedValues[locale.languageCode]!['patient']!;

  String medicationDueIn(String time) {
    return _localizedValues[locale.languageCode]!['medicationDueIn']!
        .replaceAll('{time}', time);
  }
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