//
//  LaunchBehavior.swift
//  GTStudyBuddy
//
//  Created by Jai Chawla on 4/17/22.
//

import Foundation

import Foundation

/// Use `LaunchBehaviour` to conditionally override app behaviours, based on launch flags configured in Xcode.
///
/// Useful in cases where developers wish to override certain app functionality for testing, or
/// perform actions with side effects that should only be performed in development environments.
///
/// ## Using Launch Flags
///
/// - To enable a certain behaviour flag, go to "Product > Scheme > Edit Scheme ..." for the "GTStudyBuddy" Scheme.
enum LaunchBehaviour: String {
  /// Ensure the user is always prompted to sign in at every app launch.
  case ensureSignIn = "EnsureSignIn"

  /// Call a function once when a launch is present.
  ///
  /// By convention, all behaviour modifying launch flags are prefixed with "-GTSB". This method will
  /// ignore any flags without the prefix present.
  static func when<T>(_ flag: Self, _ action: () throws -> T) rethrows -> T? {
    return ProcessInfo.processInfo.arguments.contains("-GTSB\(flag.rawValue)") ? try action() : nil
  }

  static func when<T>(_ flag: Self, _ action: () -> T) -> T? {
    return ProcessInfo.processInfo.arguments.contains("-GTSB\(flag.rawValue)") ? action() : nil
  }
}
