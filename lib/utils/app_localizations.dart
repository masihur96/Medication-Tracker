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
      'newRx': 'New Rx',
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
      'doctor': 'DR',
      'prescriptionDetails': 'Prescription Details',
      'name': 'Name',
      'timesPerDay': 'Times/Day',
      'reminderTimes': 'Reminder Times',
      'for': 'For',
      'required': 'Required',
      'enterValidNumber': 'Please enter a valid number',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'asNeeded': 'As needed',
      'additionalInfo': 'Additional Information',
      'additionalInstructions': 'Add any additional instructions or notes',
      'medicationStatus': 'Medication Status',
      'updatePrescription': 'Update Prescription',
      'saveMedication': 'Save Medication',
      'selectPrescription': 'Select Prescription',
      'selectDateToViewMedications': 'Select a date to view medications',
      'noMedicationsScheduled': 'No medications scheduled for this date',
      'taken': 'Taken',
      'notTakenYet': 'Not taken yet',
      'age': 'Age',
      'date': 'Date',
      'status': 'Status',
      'takenAt': 'Taken At',
      'medication': 'Medication',
      'vibration': 'Vibration',
      'sound': 'Sound',
      'enableNotifications': 'Enable Notifications',
      'turnOnOffReminders': 'Turn on/off all medication reminders',
      'dataPrivacy': 'Data Privacy',
      'dataCollection': 'Data Collection',
      'dataCollectionDescription': 'Allow anonymous usage data collection to improve the app',
      'showMedicationNames': 'Show Medication Names',
      'showMedicationNamesDescription': 'Show medication names in notifications and widgets',
      'biometricLock': 'Biometric Lock',
      'biometricLockDescription': 'Require authentication to open the app',
      'dataManagement': 'Data Management',
      'exportData': 'Export Your Data',
      'exportDataDescription': 'Download a copy of your data',
      'deleteAllData': 'Delete All Data',
      'deleteAllDataDescription': 'Permanently remove all your data',
      'deleteAllDataConfirm': 'Delete All Data?',
      'deleteAllDataWarning': 'This action cannot be undone. All your medication history and settings will be permanently deleted.',
      'aboutDescription': 'MedTrack is your personal medication tracking assistant, helping you stay on top of your medication schedule and maintain better health.',
      'close': 'CLOSE',
      'adherence': 'Adherence',
      'appLocked': 'App Locked',
      'authenticateToAccess': 'Please authenticate to access the app',
      'tryAgain': 'Try Again',
      'biometricsNotAvailable': 'Biometric authentication is not available on this device',
      'aiDoctorTitle': 'AI Doctor Assistant',
      'aiDoctorGreeting': "Hello! I'm your AI Doctor. How can I assist you today?",
      'aiDoctorOption': '- Or just general health tips?',
      'aiDoctorPrompt': 'Tap below to chat with me.',
      'startChat': 'Start Chat',
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
      'newRx': 'নতুন প্রেসক্রিপশন',
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
      'doctor': 'ডাঃ',
      'prescriptionDetails': 'প্রেসক্রিপশন বিবরণ',
      'name': 'নাম',
      'timesPerDay': 'দিনে কতবার',
      'reminderTimes': 'রিমাইন্ডার সময়',
      'for': 'জন্য',
      'required': 'প্রয়োজনীয়',
      'enterValidNumber': 'একটি বৈধ সংখ্যা লিখুন',
      'daily': 'দৈনিক',
      'weekly': 'সাপ্তাহিক',
      'monthly': 'মাসিক',
      'asNeeded': 'প্রয়োজনে',
      'additionalInfo': 'অতিরিক্ত তথ্য',
      'additionalInstructions': 'অতিরিক্ত নির্দেশনা বা নোট যোগ করুন',
      'medicationStatus': 'ঔষধের স্থিতি',
      'updatePrescription': 'ঔষধ আপডেট করুন',
      'saveMedication': 'ঔষধ সংরক্ষণ করুন',
      'selectPrescription': 'প্রেসক্রিপশন নির্বাচন করুন',
      'selectDateToViewMedications': 'ঔষধ দেখতে একটি তারিখ নির্বাচন করুন',
      'noMedicationsScheduled': 'এই তারিখের জন্য কোন ঔষধ নির্ধারিত নেই',
      'taken': 'খাওয়া হয়েছে',
      'notTakenYet': 'এখনও খাওয়া হয়নি',
      'age': 'বয়স',
      'date': 'তারিখ',
      'status': 'স্থিতি',
      'takenAt': 'খাওয়ার সময়',
      'medication': 'ঔষধ',
      'vibration': 'ভাইব্রেশন',
      'sound': 'শব্দ',
      'enableNotifications': 'নোটিফিকেশন চালু করুন',
      'turnOnOffReminders': 'সমস্ত ঔষধের রিমাইন্ডার চালু/বন্ধ করুন',
      'dataPrivacy': 'ডেটা গোপনীয়তা',
      'dataCollection': 'ডেটা সংগ্রহ',
      'dataCollectionDescription': 'অ্যাপ উন্নত করতে বেনামী ব্যবহার ডেটা সংগ্রহের অনুমতি দিন',
      'showMedicationNames': 'ঔষধের নাম দেখান',
      'showMedicationNamesDescription': 'নোটিফিকেশন এবং উইজেটে ঔষধের নাম দেখান',
      'biometricLock': 'বায়োমেট্রিক লক',
      'biometricLockDescription': 'অ্যাপ খোলার জন্য প্রমাণীকরণ প্রয়োজন',
      'dataManagement': 'ডেটা ব্যবস্থাপনা',
      'exportData': 'আপনার ডেটা এক্সপোর্ট করুন',
      'exportDataDescription': 'আপনার ডেটার একটি কপি ডাউনলোড করুন',
      'deleteAllData': 'সমস্ত ডেটা মুছবেন',
      'deleteAllDataDescription': 'আপনার সমস্ত ডেটা স্থায়ীভাবে মুছে ফেলুন',
      'deleteAllDataConfirm': 'সমস্ত ডেটা মুছবেন?',
      'deleteAllDataWarning': 'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না। আপনার সমস্ত ঔষধের ইতিহাস এবং সেটিংস স্থায়ীভাবে মুছে যাবে।',
      'aboutDescription': 'মেডট্র্যাক আপনার ব্যক্তিগত ঔষধ ট্র্যাকিং সহকারী, যা আপনাকে আপনার ঔষধের সময়সূচী মেনে চলতে এবং আরও ভাল স্বাস্থ্য বজায় রাখতে সাহায্য করে।',
      'close': 'বন্ধ করুন',
      'appLocked': 'অ্যাপ লক করা হয়েছে',
      'authenticateToAccess': 'অ্যাপ অ্যাক্সেস করতে প্রমাণীকরণ করুন',
      'tryAgain': 'আবার চেষ্টা করুন',
      'biometricsNotAvailable': 'এই ডিভাইসে বায়োমেট্রিক প্রমাণীকরণ উপলব্ধ নয়',
      'adherence': 'অনুগত্য',
      'aiDoctorTitle': 'এআই ডক্টর সহকারী',
      'aiDoctorGreeting': 'হ্যালো! আমি আপনার এআই ডাক্তার। আমি আজ আপনাকে কীভাবে সহায়তা করতে পারি?',
      'aiDoctorOption': '- অথবা সাধারণ স্বাস্থ্য পরামর্শ?',
      'aiDoctorPrompt': 'আমার সঙ্গে চ্যাট করতে নিচে ট্যাপ করুন।',

      'startChat': 'চ্যাট শুরু করুন',
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
  String get newRx => _localizedValues[locale.languageCode]!['newRx']!;
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
  String get doctor => _localizedValues[locale.languageCode]!['doctor']!;
  String get prescriptionDetails => _localizedValues[locale.languageCode]!['prescriptionDetails']!;
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get timesPerDay => _localizedValues[locale.languageCode]!['timesPerDay']!;
  String get reminderTimes => _localizedValues[locale.languageCode]!['reminderTimes']!;
  String get for_ => _localizedValues[locale.languageCode]!['for']!;
  String get required => _localizedValues[locale.languageCode]!['required']!;
  String get enterValidNumber => _localizedValues[locale.languageCode]!['enterValidNumber']!;
  String get daily => _localizedValues[locale.languageCode]!['daily']!;
  String get weekly => _localizedValues[locale.languageCode]!['weekly']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;
  String get asNeeded => _localizedValues[locale.languageCode]!['asNeeded']!;
  String get additionalInfo => _localizedValues[locale.languageCode]!['additionalInfo']!;
  String get additionalInstructions => _localizedValues[locale.languageCode]!['additionalInstructions']!;
  String get medicationStatus => _localizedValues[locale.languageCode]!['medicationStatus']!;
  String get updatePrescription => _localizedValues[locale.languageCode]!['updatePrescription']!;
  String get saveMedication => _localizedValues[locale.languageCode]!['saveMedication']!;
  String get selectPrescription => _localizedValues[locale.languageCode]!['selectPrescription']!;
  String get selectDateToViewMedications => _localizedValues[locale.languageCode]!['selectDateToViewMedications']!;
  String get noMedicationsScheduled => _localizedValues[locale.languageCode]!['noMedicationsScheduled']!;
  String get taken => _localizedValues[locale.languageCode]!['taken']!;
  String get notTakenYet => _localizedValues[locale.languageCode]!['notTakenYet']!;
  String get age => _localizedValues[locale.languageCode]!['age']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get status => _localizedValues[locale.languageCode]!['status']!;
  String get takenAt => _localizedValues[locale.languageCode]!['takenAt']!;
  String get medication => _localizedValues[locale.languageCode]!['medication']!;
  String get vibration => _localizedValues[locale.languageCode]!['vibration']!;
  String get sound => _localizedValues[locale.languageCode]!['sound']!;
  String get enableNotifications => _localizedValues[locale.languageCode]!['enableNotifications']!;
  String get turnOnOffReminders => _localizedValues[locale.languageCode]!['turnOnOffReminders']!;
  String get dataPrivacy => _localizedValues[locale.languageCode]!['dataPrivacy']!;
  String get dataCollection => _localizedValues[locale.languageCode]!['dataCollection']!;
  String get dataCollectionDescription => _localizedValues[locale.languageCode]!['dataCollectionDescription']!;
  String get showMedicationNames => _localizedValues[locale.languageCode]!['showMedicationNames']!;
  String get showMedicationNamesDescription => _localizedValues[locale.languageCode]!['showMedicationNamesDescription']!;
  String get biometricLock => _localizedValues[locale.languageCode]!['biometricLock']!;
  String get biometricLockDescription => _localizedValues[locale.languageCode]!['biometricLockDescription']!;
  String get dataManagement => _localizedValues[locale.languageCode]!['dataManagement']!;
  String get exportData => _localizedValues[locale.languageCode]!['exportData']!;
  String get exportDataDescription => _localizedValues[locale.languageCode]!['exportDataDescription']!;
  String get deleteAllData => _localizedValues[locale.languageCode]!['deleteAllData']!;
  String get deleteAllDataDescription => _localizedValues[locale.languageCode]!['deleteAllDataDescription']!;
  String get deleteAllDataConfirm => _localizedValues[locale.languageCode]!['deleteAllDataConfirm']!;
  String get deleteAllDataWarning => _localizedValues[locale.languageCode]!['deleteAllDataWarning']!;
  String get aboutDescription => _localizedValues[locale.languageCode]!['aboutDescription']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get adherence => _localizedValues[locale.languageCode]!['adherence']!;
  String get appLocked => _localizedValues[locale.languageCode]!['appLocked']!;
  String get authenticateToAccess => _localizedValues[locale.languageCode]!['authenticateToAccess']!;
  String get tryAgain => _localizedValues[locale.languageCode]!['tryAgain']!;
  String get biometricsNotAvailable => _localizedValues[locale.languageCode]!['biometricsNotAvailable']!;
  String get aiDoctorTitle => _localizedValues[locale.languageCode]!['aiDoctorTitle']!;
  String get aiDoctorGreeting => _localizedValues[locale.languageCode]!['aiDoctorGreeting']!;
  String get aiDoctorOption => _localizedValues[locale.languageCode]!['aiDoctorOption']!;
  String get aiDoctorPrompt => _localizedValues[locale.languageCode]!['aiDoctorPrompt']!;

  String get startChat => _localizedValues[locale.languageCode]!['startChat']!;


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