// Dart imports:
import 'dart:convert';
import 'dart:core';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
// import 'package:invoiceninja_flutter/.env.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/mock/mock_login.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/web_client.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';
import 'package:invoiceninja_flutter/utils/serialization.dart';

// import '../../redux/client/client_selectors.dart';

class AuthRepository {
  const AuthRepository({
    this.webClient = const WebClient(),
  });

  final WebClient webClient;

  Future<LoginResponse> signUp({
    String? url,
    String? secret,
    required String email,
    required String password,
    required String referralCode,
  }) async {
    final credentials = {
      'email': email,
      'password': password,
      'terms_of_service': true,
      'privacy_policy': true,
      'token_name': _tokenName,
      'platform': getPlatformName(),
    };

    if ((url ?? '').isEmpty) {
      url = Constants.hostedApiUrl;
    }
    return sendRequest(
        url: formatApiUrl(url) + '/signup?rc=$referralCode',
        data: credentials,
        secret: secret,
        settings: []);
  }

  Future<LoginResponse> oauthSignUp({
    required String url,
    required String? idToken,
    required String? accessToken,
    required String referralCode,
    required String provider,
    String? firstName = '',
    String? lastName = '',
  }) async {
    final credentials = {
      'terms_of_service': true,
      'privacy_policy': true,
      'token_name': _tokenName,
      'id_token': idToken,
      'access_token': accessToken,
      'provider': provider,
      'platform': getPlatformName(),
      'first_name': firstName,
      'last_name': lastName,
    };

    return sendRequest(
      url: formatApiUrl(url) + '/oauth_login?create=true&rc=$referralCode',
      data: credentials,
      settings: [],
    );
  }

  Future<LoginResponse> login(
      {String? email,
      String? password,
      String? url,
      String? secret,
      String? platform,
      String? oneTimePassword}) async {
    final credentials = {
      'email': email,
      'password': password,
      'one_time_password': oneTimePassword,
    };

    url = formatApiUrl(url) + '/login';

    return sendRequest(
        url: url, data: credentials, secret: secret, settings: []);
  }

  Future<dynamic> logout({required Credentials credentials}) async {
    return webClient.post(
      '${credentials.url}/logout',
  Future<LoginResponse> oauthLogin({
    required String? idToken,
    required String? accessToken,
    required String url,
    required String secret,
    required String platform,
    required String provider,
    required String? email,
    required String? authCode,
  }) async {
    final credentials = {
      'id_token': idToken,
      'provider': provider,
      'access_token': accessToken,
      'email': email,
      'auth_code': authCode,
    };

    url = formatApiUrl(url) + '/oauth_login';

    return await sendRequest(
      url: url,
      data: credentials,
      secret: secret,
      settings: [],
    );
  }
    required String secret,
    required String platform,
    required String provider,
    required String? userEmail,
    required String? authCode,
  }) async {
    final credentials = {
      'id_token': idToken,
      'provider': provider,
      'access_token': accessToken,
      'email': userEmail,
      'auth_code': authCode,
    };
      'access_token': accessToken,
      'email': email,
      'auth_code': authCode,
    };
    url = formatApiUrl(url) + '/oauth_login';

    return sendRequest(
        url: url, data: credentials, secret: secret, settings: []);
    required String? idToken,
    required String? accessToken,
    required String url,
    required String secret,
    required String platform,
    required String provider,
    required String? email,
    required String? authCode,
  }) async {
    final credentials = {
      'id_token': idToken,
      'provider': provider,
      'access_token': accessToken,
      'email': email,
      'auth_code': authCode,
    };
    url = formatApiUrl(url) + '/oauth_login';

    return sendRequest(
        url: url, data: credentials, secret: secret, settings: []);
  }

  Future<LoginResponse> refresh({
    required String url,
    required String token,
    required int updatedAt,
    required bool currentCompany,
    required bool includeStatic,
  }) async {
    url = formatApiUrl(url) + '/refresh?';

    if (currentCompany) {
      url += 'current_company=$currentCompany';
    }

    if (updatedAt > 0) {
      url += '&updated_at=$updatedAt';
      includeStatic = includeStatic ||
          DateTime.now().millisecondsSinceEpoch - (updatedAt * 1000) >
              kMillisecondsToRefreshStaticData;
    } else {
      includeStatic = true;
    }

    return sendRequest(
        url: url, token: token, includeStatic: includeStatic, settings: []);
  }

  Future<LoginResponse> recoverPassword(
      {String? email, String? url, String? secret, String? platform}) async {
    final credentials = {
      'email': email,
    };
    url = formatApiUrl(url) + '/reset_password';

    return sendRequest(url: url, data: credentials, settings: []);
  }

  Future<void> setDefaultCompany({
    required Credentials credentials,
    required String companyId,
  }) async {
    final url = '${credentials.url}/companies/$companyId/default';
    return webClient.post(url, credentials.token);
  }

  Future<dynamic> addCompany({
    required Credentials credentials,
  }) async {
    final url = '${credentials.url}/companies';
    final data = {
      'token_name': _tokenName,
    };

    return webClient.post(url, credentials.token, data: json.encode(data));
  }

  Future<dynamic> deleteCompany({
    required Credentials credentials,
    required String companyId,
    required String password,
    required String reason,
  }) async {
    final url = '${credentials.url}/companies/$companyId';
    return webClient.delete(
      url,
      credentials.token,
      password: password,
      data: json.encode(
        {'cancellation_message': reason},
      ),
    );
  }

  Future<dynamic> purgeData({
    required Credentials credentials,
    required String companyId,
    required String password,
    required String idToken,
  }) async {
    return webClient.post(
      '${credentials.url}/companies/purge_save_settings/$companyId',
      credentials.token,
      password: password,
      idToken: idToken,
    );
  }

  Future<dynamic> resendConfirmation(
      {required Credentials credentials, required String userId}) async {
    return webClient.post(
      '${credentials.url}/user/$userId/reconfirm',
      credentials.token,
    );
  }

  Future<LoginResponse> sendRequest({
    required String url,
    dynamic data,
    String? token,
    String? secret,
    bool includeStatic = true,
    required dynamic settings,
  }) async {
    if (url.contains('?')) {
      url += '&';
    } else {
      url += '?';
    }

    url += 'first_load=true';

    if (includeStatic) {
      url += '&include_static=true&einvoice=true';
    }

    dynamic response;

    if (settings.isDemoMode) {
      response = json.decode(kMockLogin);
    } else {
      response = await webClient.post(url, token ?? '',
          secret: secret, data: json.encode(data));
    }

    return await compute<dynamic, dynamic>(SerializationUtils.deserializeWith,
        <dynamic>[LoginResponse.serializer, response]);
  }

  String get _tokenName => kIsWeb
      ? 'web_client'
      : Platform.isAndroid
          ? 'android_client'
          : 'ios_client';
}
