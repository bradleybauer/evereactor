class BpOptions {
  final int? ME;
  final int? TE;
  final int? maxNumRuns;
  final int? maxNumBPs;

  const BpOptions({
    this.ME,
    this.TE,
    this.maxNumRuns,
    this.maxNumBPs,
  });

  BpOptions copyWithME(int? me) {
    return BpOptions(ME: me, TE: TE, maxNumRuns: maxNumRuns, maxNumBPs: maxNumBPs);
  }

  BpOptions copyWithTE(int? te) {
    return BpOptions(ME: ME, TE: te, maxNumRuns: maxNumRuns, maxNumBPs: maxNumBPs);
  }

  BpOptions copyWithRuns(int? runs) {
    return BpOptions(ME: ME, TE: TE, maxNumRuns: runs, maxNumBPs: maxNumBPs);
  }

  BpOptions copyWithBPs(int? bps) {
    return BpOptions(ME: ME, TE: TE, maxNumRuns: maxNumRuns, maxNumBPs: bps);
  }
}
