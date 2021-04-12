// RUN: %target-swift-frontend -emit-silgen %s -module-name test -swift-version 5 -enable-experimental-concurrency | %FileCheck --enable-var-scope %s --check-prefix=CHECK-RAW
// RUN: %target-swift-frontend -emit-silgen %s -module-name test -swift-version 5 -enable-experimental-concurrency > %t.sil
// RUN: %target-sil-opt -enable-sil-verify-all %t.sil -lower-hop-to-actor -enable-experimental-concurrency | %FileCheck --enable-var-scope %s --check-prefix=CHECK-CANONICAL
// REQUIRES: concurrency

import Swift
import _Concurrency

// CHECK-RAW-LABEL: sil [ossa] @$s4test11onMainActoryyF
// CHECK-RAW: extract_executor [[MAIN_ACTOR:%.*]] : $MainActor

// CHECK-CANONICAL-LABEL: sil [ossa] @$s4test11onMainActoryyF
// CHECK-CANONICAL: function_ref @$ss22_checkExpectedExecutor7Builtin15_filenameLength01_E7IsASCII5_line9_executoryBp_BwBi1_BwBetF
@MainActor public func onMainActor() { }

public actor MyActor {
  var counter = 0

  // CHECK-RAW-LABEL: sil private [ossa] @$s4test7MyActorC10getUpdaterSiycyFSiycfU_
  // CHECK-RAW: extract_executor [[ACTOR:%.*]] : $MyActor

  // CHECK-CANONICAL-LABEL: sil private [ossa] @$s4test7MyActorC10getUpdaterSiycyFSiycfU_
  // CHECK-CANONICAL: function_ref @$ss22_checkExpectedExecutor7Builtin15_filenameLength01_E7IsASCII5_line9_executoryBp_BwBi1_BwBetF
  public func getUpdater() -> (() -> Int) {
    return {
      self.counter = self.counter + 1
      return self.counter
    }
  }
}
