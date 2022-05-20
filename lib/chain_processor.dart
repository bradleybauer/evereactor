// the primary use case of this app is to make sure that certain functions do not get called too many times per second.
// a few users:
//    color changer updates the color at like 60fps but should not update the persistence cache 60fps because that'd be too slow.
//    not implemented yet but when adv solver updates the solver it updates the ui and does other computation. shouldn't do it to many times/s
class ChainProcessor {
  var _arg;
  var _didUpdateArg = false;
  bool _isComputing = false;

  final Future<void> Function(dynamic) _computation;
  final Duration? maxFrequency;

  ChainProcessor(this._computation, {this.maxFrequency});

  void _chain() async {
    do {
      _didUpdateArg = false;
      final delay = Future.delayed(maxFrequency ?? const Duration());
      await _computation(_arg);
      await delay;
    } while (_didUpdateArg);
    _isComputing = false;
  }

  void compute([arg]) {
    _arg = arg;
    if (!_isComputing) {
      _isComputing = true;
      _chain();
    } else {
      _didUpdateArg = true;
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
