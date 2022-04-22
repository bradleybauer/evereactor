class BPOptions {
  final int? ME;
  final int? TE;
  final int? maxNumRuns;
  final int? maxNumBPs;

  const BPOptions({
    this.ME,
    this.TE,
    this.maxNumRuns,
    this.maxNumBPs,
  });

  BPOptions copyWithME(int? me) {
    return BPOptions(ME: me, TE: TE, maxNumRuns: maxNumRuns, maxNumBPs: maxNumBPs);
  }

  BPOptions copyWithTE(int? te) {
    return BPOptions(ME: ME, TE: te, maxNumRuns: maxNumRuns, maxNumBPs: maxNumBPs);
  }

  BPOptions copyWithRuns(int? runs) {
    return BPOptions(ME: ME, TE: TE, maxNumRuns: runs, maxNumBPs: maxNumBPs);
  }

  BPOptions copyWithBPs(int? bps) {
    return BPOptions(ME: ME, TE: TE, maxNumRuns: maxNumRuns, maxNumBPs: bps);
  }
}
