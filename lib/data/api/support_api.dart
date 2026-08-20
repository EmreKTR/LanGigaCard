/// Submits a problem report from Help &amp; Support. `VocabGridSupportApi` is
/// the real implementation; [FakeSupportApi] is an in-memory stand-in for
/// tests.
abstract class SupportApi {
  /// Returns true if the report was sent. False only means the request
  /// itself couldn't be delivered (e.g. offline) -- there's nothing for the
  /// caller to distinguish beyond that, since the only validation is "not
  /// blank," already enforced client-side before this is ever called.
  Future<bool> reportProblem(String message);
}

/// In-memory [SupportApi] for tests: no network, no disk.
class FakeSupportApi implements SupportApi {
  FakeSupportApi({this.failReport = false});

  bool failReport;
  final List<String> submittedReports = [];

  @override
  Future<bool> reportProblem(String message) async {
    if (failReport) return false;
    submittedReports.add(message);
    return true;
  }
}
