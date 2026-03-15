import 'dart:io';

abstract interface class LinuxCommandProbe {
  Future<bool> isCommandAvailable(String command);
}

LinuxCommandProbe createLinuxCommandProbe() => _IoLinuxCommandProbe();

class _IoLinuxCommandProbe implements LinuxCommandProbe {
  @override
  Future<bool> isCommandAvailable(String command) async {
    final result = await Process.run('/bin/sh', [
      '-lc',
      'command -v $command >/dev/null 2>&1',
    ]);
    return result.exitCode == 0;
  }
}
