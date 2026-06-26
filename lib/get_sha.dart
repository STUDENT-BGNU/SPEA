import 'dart:io';

void main() async {
  // Ye command direct SHA-1 nikalne ki koshish karegi
  Process.run('keytool', ['-list', '-v', '-keystore', '${Platform.environment['USERPROFILE']}\\.android\\debug.keystore', '-alias', 'androiddebugkey', '-storepass', 'android', '-keypass', 'android']).then((result) {
    print(result.stdout);
    print(result.stderr);
  });
}