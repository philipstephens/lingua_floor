import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<String> loadAppVersionLabel() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.buildNumber.isEmpty) {
      return packageInfo.version;
    }
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  } catch (_) {
    return 'unavailable';
  }
}

class AppVersionText extends StatefulWidget {
  const AppVersionText({
    super.key,
    this.prefix = 'Version: ',
    this.loadingText = 'Version: Loading…',
    this.unavailableText = 'Version: unavailable',
  });

  final String prefix;
  final String loadingText;
  final String unavailableText;

  @override
  State<AppVersionText> createState() => _AppVersionTextState();
}

class _AppVersionTextState extends State<AppVersionText> {
  late final Future<String> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = loadAppVersionLabel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _versionFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(widget.unavailableText);
        }

        final versionLabel = snapshot.data;
        if (versionLabel == null) {
          return Text(widget.loadingText);
        }

        if (versionLabel == 'unavailable') {
          return Text(widget.unavailableText);
        }

        return Text('${widget.prefix}$versionLabel');
      },
    );
  }
}