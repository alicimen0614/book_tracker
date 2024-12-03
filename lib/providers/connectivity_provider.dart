import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  ConnectivityNotifier() {
    _checkConnection();
    // listen to changes on internet connection
    _connectivity.onConnectivityChanged.listen(
      (event) {
        _updateConnectionStatus(event);
      },
    );
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();

    _updateConnectionStatus(result);
  }

  /// Bağlantı durumunu günceller ve değişiklik varsa dinleyicileri bilgilendirir
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final connected = result.contains(ConnectivityResult.none) == false;
    log(connected.toString());
    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }
  }
}

/// ConnectivityNotifier için bir Riverpod sağlayıcısı
final connectivityProvider =
    ChangeNotifierProvider((ref) => ConnectivityNotifier());
