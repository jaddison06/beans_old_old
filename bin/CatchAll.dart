/// utility to execute code, catching all exceptions
mixin CatchAll {
  void catchAll(void Function() risky, void Function(Object, StackTrace) onError) {
    try {
      risky();
    } catch (e, trace) {
      onError(e, trace);
    }
  }
}