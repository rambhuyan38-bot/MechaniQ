import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'MechaniQ',
      'scan_now': 'SCAN VEHICLE',
      'scanning': 'Scanning Protocol...',
      'battery_voltage': 'Battery Voltage',
      'engine_temp': 'Engine Temp',
      'rpm': 'Engine RPM',
      'speed': 'Vehicle Speed',
      'health_score': 'Vehicle Health Score',
      'rider_view': 'Rider View',
      'mechanic_view': 'Mechanic View',
      'ai_view': 'AI Root Cause',
      'cost_view': 'Repair Cost',
      'clear_dtc': 'Clear DTC Codes',
      'book_mechanic': 'Consult Expert Mechanic',
      'onboarding_title': 'Configure Your Ride',
      'payment_title': 'Razorpay / UPI Secure Payment',
      'connection_manager': 'OBD Connection Manager',
      'select_protocol': 'Select Connection protocol'
    },
    'hi': {
      'title': 'मैकेनिकक्यू',
      'scan_now': 'स्कैन करें',
      'scanning': 'प्रोटोकॉल स्कैन हो रहा है...',
      'battery_voltage': 'बैटरी वोल्टेज',
      'engine_temp': 'इंजन तापमान',
      'rpm': 'इंजन आरपीएम',
      'speed': 'गति',
      'health_score': 'वाहन स्वास्थ्य स्कोर',
      'rider_view': 'चालक दृष्टिकोण',
      'mechanic_view': 'मैकेनिक दृष्टिकोण',
      'ai_view': 'एआई मूल कारण विश्लेषण',
      'cost_view': 'मरम्मत लागत',
      'clear_dtc': 'डीटीसी कोड हटाएं',
      'book_mechanic': 'मैकेनिक से सलाह लें',
      'onboarding_title': 'अपना वाहन चुनें',
      'payment_title': 'रेज़रपे / यूपीआई सुरक्षित भुगतान',
      'connection_manager': 'ओबीडी कनेक्शन मैनेजर',
      'select_protocol': 'कनेक्शन प्रोटोकॉल चुनें'
    },
    'mr': {
      'title': 'मेकॅनिकक्यू',
      'scan_now': 'स्कॅन करा',
      'scanning': 'प्रोटोकॉल स्कॅन होत आहे...',
      'battery_voltage': 'बॅटरी व्होल्टेज',
      'engine_temp': 'इंजिन तापमान',
      'rpm': 'इंजिन आरपीएम',
      'speed': 'वाहन वेग',
      'health_score': 'वाहन आरोग्य स्कोर',
      'rider_view': 'चालक दृष्टिकोन',
      'mechanic_view': 'मेकॅनिक दृष्टिकोन',
      'ai_view': 'एआय मूळ कारण',
      'cost_view': 'दुरुस्ती खर्च',
      'clear_dtc': 'डीटीसी कोड हटवा',
      'book_mechanic': 'तज्ञ मेकॅनिकचा सल्ला घ्या',
      'onboarding_title': 'तुमचे वाहन निवडा',
      'payment_title': 'रेझरपे / यूपीआय सुरक्षित पेमेंट',
      'connection_manager': 'ओबीडी कनेक्शन व्यवस्थापक',
      'select_protocol': 'कनेक्शन प्रोटोकॉल निवडा'
    },
    'ta': {
      'title': 'மெக்கானிக்-க்யூ',
      'scan_now': 'ஸ்கேன் செய்',
      'scanning': 'நெறிமுறை ஸ்கேன் செய்யப்படுகிறது...',
      'battery_voltage': 'பேட்டரி மின்னழுத்தம்',
      'engine_temp': 'என்ஜின் வெப்பம்',
      'rpm': 'என்ஜின் ஆர்பிஎம்',
      'speed': 'வாகன வேகம்',
      'health_score': 'வாகன ஆரோக்கிய மதிப்பீடு',
      'rider_view': 'ஓட்டுநர் பார்வை',
      'mechanic_view': 'மெக்கானிக் பார்வை',
      'ai_view': 'செயற்கை நுண்ணறிவு பகுப்பாய்வு',
      'cost_view': 'பழுதுபார்ப்பு செலவு',
      'clear_dtc': 'டிடிசி குறியீடுகளை அழி',
      'book_mechanic': 'மெக்கானிக் ஆலோசனை',
      'onboarding_title': 'உங்கள் வாகனத்தை தேர்வு செய்க',
      'payment_title': 'ரேஸர்பே / யுபிஐ பாதுகாப்பான கட்டணம்',
      'connection_manager': 'OBD இணைப்பு மேலாளர்',
      'select_protocol': 'இணைப்பு நெறிமுறையைத் தேர்ந்தெடுக்கவும்'
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'mr', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}