import 'package:flutter_test/flutter_test.dart';
import 'package:vosk_flutter_service/vosk_flutter.dart';

void main() {
  test('defaultModelStoragePath resolves Linux documents-style storage', () {
    expect(
      defaultModelStoragePath(
        operatingSystem: 'linux',
        environment: const {'HOME': '/tmp/test-home'},
        systemTempPath: '/tmp/runtime',
      ),
      '/tmp/test-home/Documents/models',
    );
  });

  test('defaultModelStoragePath derives Android files storage from cache', () {
    expect(
      defaultModelStoragePath(
        operatingSystem: 'android',
        environment: const {'HOME': '/data/user/0/app/cache'},
        systemTempPath: '/tmp/runtime',
      ),
      '/data/user/0/app/files/models',
    );
  });

  test('ModelLoader still respects an explicit modelStorage override', () async {
    const customStorage = '/tmp/custom-models';
    final loader = ModelLoader(modelStorage: customStorage);

    expect(await loader.modelPath('demo-model'), '$customStorage/demo-model');
  });
}