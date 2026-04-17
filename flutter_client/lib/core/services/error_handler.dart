import 'package:flutter/material.dart';
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
      log.w('Silent Failure in $context: ${error.message}',
          error: error, stackTrace: stackTrace,);
    } else {
      log.e('Silent Error in $context: $error',
          error: error, stackTrace: stackTrace,);
    }
  }

  /// Handles an error by logging it and showing a SnackBar to the user.
  void handleAndShow(BuildContext context, dynamic error,
      {StackTrace? stackTrace, String? where,}) {
    if (error is Failure) {
      log.w('Handled Failure in $where: ${error.message}',
          error: error, stackTrace: stackTrace,);
      _showSnackBar(context, error.message, isError: true);
    } else if (error is NetworkException) {
      log.w('Network Exception in $where: ${error.message}',
          error: error, stackTrace: stackTrace,);
      _showSnackBar(context, 'Error de red: revisá tu conexión', isError: true);
    } else if (error is OfflineException) {
      log.i('Offline action in $where: ${error.message}',
          error: error, stackTrace: stackTrace,);
      _showSnackBar(context, 'Estás offline. Acción guardada para luego.',
          isError: false,);
    } else {
      log.e('Unhandled Error in $where: $error',
          error: error, stackTrace: stackTrace,);
      _showSnackBar(context, 'Ha ocurrido un error inesperado', isError: true);
    }
  }

  /// Helper to display a SnackBar with standard styling
  void _showSnackBar(BuildContext context, String message,
      {bool isError = true,}) {
    // Avoid "use_build_context_synchronously" issues by checking if context is still valid
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.red.shade800 : Colors.blue.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Global convenience getter
final errorHandler = ErrorHandler.instance;
