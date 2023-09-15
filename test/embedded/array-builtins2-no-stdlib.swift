// RUN: %target-swift-emit-ir %s -parse-stdlib -module-name Swift -enable-experimental-feature Embedded -target arm64e-apple-none | %FileCheck %s

// REQUIRES: swift_in_compiler

class MyClass {}

struct MyStruct {
  var c: MyClass
}

public func foo(x: Builtin.RawPointer, y: Builtin.RawPointer, count: Builtin.Word) {
  var s = MyGenericStruct<MyStruct>()
  s.foo(x: x, y: y, count: count)
}

public struct MyGenericStruct<T> {
  public func foo(x: Builtin.RawPointer, y: Builtin.RawPointer, count: Builtin.Word) {
    Builtin.copyArray(T.self, x, y, count)
    Builtin.copyArray(T.self, x, y, count)
    Builtin.takeArrayNoAlias(T.self, x, y, count)
    Builtin.takeArrayFrontToBack(T.self, x, y, count)
    Builtin.takeArrayBackToFront(T.self, x, y, count)
    Builtin.assignCopyArrayNoAlias(T.self, x, y, count)
    Builtin.assignCopyArrayFrontToBack(T.self, x, y, count)
    Builtin.assignCopyArrayBackToFront(T.self, x, y, count)
    Builtin.assignTakeArray(T.self, x, y, count)
  }
}

// No runtime calls should be present.
// CHECK-NOT: @swift_arrayInitWithCopy
// CHECK-NOT: @swift_arrayAssignWithCopyNoAlias
// CHECK-NOT: @swift_arrayAssignWithCopyFrontToBack
// CHECK-NOT: @swift_arrayAssignWithCopyBackToFront
// CHECK-NOT: @swift_arrayAssignWithTake
