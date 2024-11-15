import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Internet bağlantı durumunu kontrol etmek için bir ChangeNotifier sınıfı
class ConnectivityNotifier extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  ConnectivityNotifier() {
    _checkConnection();
    // İnternet bağlantısı durumundaki değişiklikleri dinler
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  /// Başlangıçta internet bağlantısını kontrol eder
  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();

    _updateConnectionStatus(result);
  }

  /// Bağlantı durumunu günceller ve değişiklik varsa dinleyicileri bilgilendirir
  void _updateConnectionStatus(ConnectivityResult result) {
    final connected =
        result != ConnectivityResult.none && result != ConnectivityResult.vpn;
    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }
  }
}

/// ConnectivityNotifier için bir Riverpod sağlayıcısı
final connectivityProvider =
    ChangeNotifierProvider((ref) => ConnectivityNotifier());
