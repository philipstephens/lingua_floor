abstract interface class LinuxCommandProbe {
  Future<bool> isCommandAvailable(String command);
}

LinuxCommandProbe createLinuxCommandProbe() => _StubLinuxCommandProbe();

class _StubLinuxCommandProbe implements LinuxCommandProbe {
  @override
  Future<bool> isCommandAvailable(String command) async => false;
}
