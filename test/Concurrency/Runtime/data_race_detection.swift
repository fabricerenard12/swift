// RUN: %target-run-simple-swift(-Xfrontend -enable-experimental-concurrency  %import-libdispatch -parse-as-library) > %t.log 2>&1
// RUN: %FileCheck %s < %t.log

// REQUIRES: executable_test
// REQUIRES: concurrency
// REQUIRES: libdispatch

// rdar://76038845
// UNSUPPORTED: use_os_stdlib

import _Concurrency
import Dispatch
import Darwin

@MainActor func onMainActor() {
  print("I'm on the main actor!")
}

func promiseMainThread(_ fn: @escaping @MainActor () -> Void) -> (() -> Void) {
  typealias Fn = () -> Void
  return unsafeBitCast(fn, to: Fn.self)
}

func launchTask(_ fn: @escaping () -> Void) {
  if #available(macOS 10.10, iOS 7.0, watchOS 2.0, tvOS 8.0, *) {
    DispatchQueue.global().async {
      fn()
    }
  }
}

@MainActor func launchFromMainThread() {
  launchTask(promiseMainThread(onMainActor))
}

actor MyActor {
  var counter = 0

  func onMyActor() {
    counter = counter + 1
  }

  func getTaskOnMyActor() -> (() -> Void) {
    return {
      self.onMyActor()
    }
  }
}

@main
struct Runner {
  @MainActor static func main() async {
    print("Launching a main-actor task")
    // CHECK: warning: data race detected: @MainActor function at main/data_race_detection.swift:15 was not called on the main thread
    launchFromMainThread()
    sleep(1)

    let actor = MyActor()
    let actorFn = await actor.getTaskOnMyActor()
    print("Launching an actor-instance task")
    // CHECK: warning: data race detected: actor-isolated function at main/data_race_detection.swift:44 was not called on the same actor
    launchTask(actorFn)

    sleep(1)
  }
}
