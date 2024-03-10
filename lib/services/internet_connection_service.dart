import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkForInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }

  return false;
}
