class Pair<A, B> {
  A first;
  B second;
  Pair({required this.first, required this.second});

  @override
  int get hashCode => Object.hash(first, second);
}
