import 'package:flutter/material.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import '../errors/failures.dart';
import 'logger_service.dart';

/// Centralized error handling and user notification service.
/// Consumes Failures and Exceptions to display snackbars or dialogs,
/// and logs them to Crashlytics via LoggerService.
class ErrorHandler {
  ErrorHandler._privateConstructor();
  static final ErrorHandler _instance = ErrorHandler._privateConstructor();
  static ErrorHandler get instance => _instance;

  /// Handles an error silently (only logs it, does not show UI).
  void handleSilent(dynamic error, {StackTrace? stackTrace, String? context}) {
    if (error is Failure) {
      log.w(
        'Silent Failure in $context: ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      log.e(
        'Silent Error in $context: $error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handles an error by logging it and showing a SnackBar to the user.
  void handleAndShow(
    BuildContext context,
    dynamic error, {
    StackTrace? stackTrace,
    String? where,
  }) {
    if (error is Failure) {
      log.w(
        'Handled Failure in $where: ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );
      _showSnackBar(context, error.message, isError: true);
    } else if (error is NetworkException) {
      log.w(
        'Network Exception in $where: ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );
      _showSnackBar(context, 'Error de red: revisá tu conexión', isError: true);
    } else if (error is OfflineException) {
      log.i(
        'Offline action in $where: ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );
      _showSnackBar(
        context,
        'Estás offline. Acción guardada para luego.',
        isError: false,
      );
    } else {
      log.e(
        'Unhandled Error in $where: $error',
        error: error,
        stackTrace: stackTrace,
      );
      _showSnackBar(context, 'Ha ocurrido un error inesperado', isError: true);
    }
  }

  /// Helper to display a SnackBar with standard styling
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    // Avoid "use_build_context_synchronously" issues by checking if context is still valid
    if (!context.mounted) return;

    AppSnackBar.show(
      context,
      message: message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.info,
      duration: isError
          ? const Duration(milliseconds: 3200)
          : const Duration(milliseconds: 2200),
    );
  }
}

/// Global convenience getter
final errorHandler = ErrorHandler.instance;
