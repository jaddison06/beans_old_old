void BeansAssert(bool cond, [String? message]) {
  if (!cond) {
    throw Exception(message ?? 'Beans assertion failed');
  }
}