import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/result.dart';

/// Base abstract class for form notifiers to eliminate code duplication.
///
/// Provides generic CRUD operation patterns for all form notifiers.
/// Subclasses should override [refreshParentNotifier] to refresh parent list notifier.
abstract class BaseFormNotifier<S> extends AutoDisposeNotifier<S> {
  @override
  S build();

  /// Performs generic create operation with common error handling
  Future<Result<T>> performCreate<T>({
    required Future<Result<T>> Function() execute,
    required VoidCallback onSuccess,
  }) async {
    try {
      final res = await execute();
      if (res.isSuccess) {
        onSuccess();
      }
      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Performs generic update operation with common error handling
  Future<Result<T>> performUpdate<T>({
    required Future<Result<T>> Function() execute,
    required VoidCallback onSuccess,
  }) async {
    try {
      final res = await execute();
      if (res.isSuccess) {
        onSuccess();
      }
      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Performs generic delete operation with common error handling
  Future<Result<T>> performDelete<T>({
    required Future<Result<T>> Function() execute,
    required VoidCallback onSuccess,
  }) async {
    try {
      final res = await execute();
      if (res.isSuccess) {
        onSuccess();
      }
      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Subclasses must call this after successful CRUD operations
  void refreshParentNotifier();
}
