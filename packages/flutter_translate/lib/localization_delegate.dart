import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'constants.dart';
import 'localization_file_service.dart';
import 'localization_configuration.dart';
import 'localization.dart';

class LocalizationDelegate extends LocalizationsDelegate<Localization>
{
    Locale _currentLocale;

    final LocalizationConfiguration configuration;

    Locale get currentLocale => _currentLocale;

    LocalizationDelegate._(this.configuration);

    Future changeLanguage(Locale newLocale) async
    {
        var locale = _findLocale(newLocale) ?? configuration.fallbackLocale;
        
        if(_currentLocale != locale)
        {
            var localizedContent = await _getLocalizedContent(locale);

            Localization.load(localizedContent);

            _currentLocale = locale;
        }
    }

    @override
    Future<Localization> load(Locale newLocale) async
    {
        if(currentLocale != newLocale)
        {
            await changeLanguage(newLocale);
        }

        return Localization.instance;
    }

    Future<Map<String, dynamic>> _getLocalizedContent(Locale locale) async
    {
        var file = configuration.localizations[locale];

        var content = await LocalizationFileService.getLocalizedContent(file);

        return json.decode(content);
    }

    Locale _findLocale(Locale locale)
    {
        var existing = configuration.localizations.keys.firstWhere((x) => x == locale, orElse: () => null);

        if(existing == null)
        {
            existing = configuration.localizations.keys.firstWhere((x) => x.languageCode == locale.languageCode, orElse: () => null);
        }

        return existing;
    }

    @override
    bool isSupported(Locale locale) => locale != null;

    @override
    bool shouldReload(LocalizationsDelegate<Localization> old) => true;

    static Future<LocalizationDelegate> create({@required String fallbackLanguage,
                                                @required List<String> supportedLanguages,
                                                String basePath = Constants.defaultLocalizedAssetsPath}) async
    {
        var configuration = await LocalizationConfiguration.create(fallbackLanguage, supportedLanguages, basePath: basePath);

        return new LocalizationDelegate._(configuration);
    }
}