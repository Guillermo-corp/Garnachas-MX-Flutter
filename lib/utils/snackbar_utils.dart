import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

void showWarningSnackbar(BuildContext context, String title, String message) {
  _showCustomSnackbar(context, title, message, ContentType.warning);
}

void showSuccessSnackbar(BuildContext context, String title, String message) {
  _showCustomSnackbar(context, title, message, ContentType.success);
}

void showFailureSnackbar(BuildContext context, String title, String message) {
  _showCustomSnackbar(context, title, message, ContentType.failure);
}

void showHelpSnackbar(BuildContext context, String title, String message) {
  _showCustomSnackbar(context, title, message, ContentType.help);
}

void _showCustomSnackbar(
    BuildContext context, String title, String message, ContentType type) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    ),
  );
}
