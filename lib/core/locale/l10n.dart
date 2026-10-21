import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import 'locale_controller.dart';

AppLocalizations get l10n =>
    lookupAppLocalizations(LocaleController.instance.locale.value);

AppLocalizations l10nFor(String languageCode) =>
    lookupAppLocalizations(Locale(languageCode));
