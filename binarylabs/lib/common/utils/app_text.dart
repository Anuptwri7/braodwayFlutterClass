import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:binarylabs/common/data/app_language.dart';
import 'package:binarylabs/locator.dart';

AppLocalizations get appText {
  return lookupAppLocalizations(Locale(locator<AppLanguage>().currentLanguage));
}
