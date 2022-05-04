class ChainProcessor {
  var _arg;
  var didUpdateArg = false;
  bool isComputing = false;

  final Future<void> Function(dynamic) _computation;
  final Duration? maxFrequency;

  ChainProcessor(this._computation, {this.maxFrequency});

  void _chain() async {
    do {
      didUpdateArg = false;
      final delay = Future.delayed(maxFrequency ?? const Duration());
      await _computation(_arg);
      await delay;
    } while (didUpdateArg);
    isComputing = false;
  }

  void compute([arg]) {
    _arg = arg;
    if (!isComputing) {
      isComputing = true;
      _chain();
    } else {
      didUpdateArg = true;
    }
  }
}
/*

Future<void> main() async {
  final processor = ChainProcessor();

  // initial computation request
  processor.compute('1');

  // new computation requests with different arguments
  Future.delayed(const Duration(seconds: 1), () => processor.compute('2'));
  Future.delayed(const Duration(milliseconds: 1500), () => processor.compute('3'));

  // but only the argument in the most recent request is computed
  Future.delayed(const Duration(milliseconds: 1600), () => processor.compute('4'));

  // when no computation is being done, more chains can be started
  Future.delayed(const Duration(seconds: 11), () => processor.compute('5'));
  Future.delayed(const Duration(seconds: 12), () => processor.compute('6'));
}
 */
