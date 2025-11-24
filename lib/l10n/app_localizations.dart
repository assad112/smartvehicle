import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_title': 'Smart Vehicle System',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'dashboard': 'Dashboard',
      'maintenance': 'Maintenance',
      'notifications': 'Notifications',
      'profile': 'Profile',
      'vehicle_status': 'Vehicle Status',
      'add_maintenance': 'Add Maintenance',
      'edit_maintenance': 'Edit Maintenance',
      'delete': 'Delete',
      'edit': 'Edit',
      'save': 'Save',
      'cancel': 'Cancel',
      'logout': 'Logout',
      'change_password': 'Change Password',
      'edit_profile': 'Edit Profile',
    },
    'en': {
      'app_title': 'Smart Vehicle System',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'dashboard': 'Dashboard',
      'maintenance': 'Maintenance',
      'notifications': 'Notifications',
      'profile': 'Profile',
      'vehicle_status': 'Vehicle Status',
      'add_maintenance': 'Add Maintenance',
      'edit_maintenance': 'Edit Maintenance',
      'delete': 'Delete',
      'edit': 'Edit',
      'save': 'Save',
      'cancel': 'Cancel',
      'logout': 'Logout',
      'change_password': 'Change Password',
      'edit_profile': 'Edit Profile',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

