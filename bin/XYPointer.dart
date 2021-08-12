import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

/// Utility class to provide two int pointers, for when you need to get coordinate data from C.
class XYPointer {
  Pointer<Int32> xPtr;
  Pointer<Int32> yPtr;

  XYPointer() :
    xPtr = malloc<Int32>(),
    yPtr = malloc<Int32>();
  
  /// Free xPtr and yPtr
  @mustCallSuper
  void destroy() {
    malloc.free(xPtr);
    malloc.free(yPtr);
  }
}