import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oauth2/oauth2.dart';
import 'package:ummobile/modules/internet/models/internet_enum_errors.dart';
import 'package:ummobile/modules/internet/views/content_no_internet.dart';
import 'package:ummobile/modules/login/controllers/login_controller.dart';
import 'package:ummobile_custom_http/ummobile_custom_http.dart';

class ControllerTemplate extends GetxController {
  var isLoading = true
      .obs; // Variable in charge of showing the loading screen while data is loading

  //abstract method which will act based on the button of the NoInternetPage
  void refreshContent() {}

  // Returns the page where says the error in which why the screen couldn't load
  Widget internetPage(String? errorMessage) {
    switch (errorMessage) {
      case "clientError":
        return ContentNoInternet(
          toPageReturn: refreshContent,
          errorType: InternetErrorType.client,
        );
      case "serverError":
        return ContentNoInternet(
          toPageReturn: refreshContent,
          errorType: InternetErrorType.server,
        );
      default:
        return Center(child: Text(errorMessage ?? "null error"));
    }
  }

  RxStatus _getStatusError(HttpExceptions exception) {
    switch (exception) {
      case HttpExceptions.ClientError:
      case HttpExceptions.ConnectionError:
      case HttpExceptions.ClientOffline:
        return RxStatus.error('clientError');
      case HttpExceptions.ServerDown:
      case HttpExceptions.ServerError:
        return RxStatus.error('serverError');
      case HttpExceptions.ExpiredToken:
      case HttpExceptions.Unauthorized:
      case HttpExceptions.Other:
        return RxStatus.error(exception.toString());
    }
  }

  /// Executes a [httpCall] and the result is passed to [onSuccess] callback for his usage.
  ///
  /// If [httpCall] throws any exception that implements `HttpCallException`, a `RxStatus` is defined for the exception type and passed to [onCallError]. If any other exception occurs then the exception object itself is passed to [onError] callback.
  call<T>({
    required Future<T> Function() httpCall,
    required void Function(T) onSuccess,
    required void Function(RxStatus) onCallError,
    required void Function(Object) onError,
  }) async {
    try {
      T res = await httpCall();
      onSuccess(res);
    } on HttpCallException catch (e) {
      onCallError(_getStatusError(e.type));
    } catch (e) {
      onError(e);
    }
  }
}