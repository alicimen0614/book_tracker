import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  FirebaseAnalytics get firebaseAnalytics => _firebaseAnalytics;

  Future<void> logEvent(
      String eventName, Map<String, Object>? parameters) async {
    try {
      _firebaseAnalytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> logUserProperty(String propertyName, String value) async {
    try {
      _firebaseAnalytics.setUserProperty(name: propertyName, value: value);
    } catch (e) {
      print(e);
    }
  }

  Future<void> logAdImpression(
    String adFormat,
  ) async {
    try {
      _firebaseAnalytics.logAdImpression(
        adFormat: adFormat,
      );
    } catch (e) {
      print(e);
    }
  }
}
