import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_id/dio_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OneID extends StatefulWidget {
  const OneID({
    Key? key,
    required this.token,
    required this.code,
    required this.userInfo,
    required this.onUserInfo,
  }) : super(key: key);

  final GetCode code;
  final GetToken token;
  final GetUserInfo userInfo;
  final Function(String? userInfo) onUserInfo;

  @override
  State<OneID> createState() => _OneIDState();
}

class _OneIDState extends State<OneID> {
  late String urlOneId;
  late WebViewController _webViewController;
  late String code;
  late String access_token;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      urlOneId =
          "https://sso.egov.uz/sso/oauth/Authorization.do?response_type=${widget.code.response_type}&client_id=${widget.code.client_id}&redirect_uri=${widget.code.redirect_uri}&scope=${widget.code.scope}&state=${widget.code.state}";
      WebView.platform = AndroidWebView();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      urlOneId =
          "https://sso.egov.uz/sso/oauth/Authorization.do?response_type=${widget.code.response_type}&client_id=${widget.code.client_id}&redirect_uri=${widget.code.redirect_uri}&scope=${widget.code.scope}&state=${widget.code.state}";
      WebView.platform = CupertinoWebView();
    }
  }

  void apiGetCode(String url) async {
    if (url.contains("code=")) {
      setState(() {
        code = url.substring(url.indexOf("code=") + 5, url.indexOf("&state"));
      });
      apiGetToken();
    }
  }

  // api get token for query
  Map<String, String> queryToken() {
    Map<String, String> map = {
      "grant_type": widget.token.grant_type,
      "client_id": widget.token.client_id,
      "client_secret": widget.token.client_secret,
      "redirect_uri": widget.token.redirect_uri,
      "code": code
    };
    return map;
  }

  Future<void> apiGetToken() async {
    String? response = await DioService.post(
        api: "/sso/oauth/Authorization.do", params: queryToken());
    if (response != null) {
      setState(() {
        access_token = jsonDecode(response)['access_token'];
      });
    } else {
      log("Get token error");
    }
  }

  // api get token for query
  Map<String, String> queryUserInfo() {
    Map<String, String> map = {
      "grant_type": widget.userInfo.grant_type,
      "client_id": widget.userInfo.client_id,
      "client_secret": widget.userInfo.client_secret,
      "scope": widget.userInfo.scope,
      "access_token": access_token,
    };
    return map;
  }

  void apiGetUserInfo() async {
    String? response = await DioService.post(
        api: "/sso/oauth/Authorization.do", params: queryUserInfo());

    if (response != null) {
      setState(() {
        _webViewController.clearCache();
        widget.onUserInfo(response);
      });
    } else {
      log("User info error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: urlOneId,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) async {
          _webViewController = controller;
          await _webViewController.clearCache();
        },
        onProgress: (_) async {
          final url = await _webViewController.currentUrl();
          if (url != null) {
            apiGetCode(url);
          }
        },
        onPageFinished: (_) {
          apiGetUserInfo();
        },
        onWebResourceError: (error) {
          if (kDebugMode) {
            log("Error");
          }
        },
      ),
    );
  }
}

class GetCode {
  const GetCode({
    required this.response_type,
    required this.client_id,
    required this.redirect_uri,
    required this.scope,
    required this.state,
  });

  final String response_type;
  final String client_id;
  final String redirect_uri;
  final String scope;
  final String state;
}

class GetToken {
  GetToken({
    required this.grant_type,
    required this.client_id,
    required this.client_secret,
    required this.redirect_uri,
  });

  final String grant_type;
  final String client_id;
  final String client_secret;
  final String redirect_uri;
}

class GetUserInfo {
  final String grant_type;
  final String client_id;
  final String client_secret;
  final String scope;

  GetUserInfo({
    required this.grant_type,
    required this.client_id,
    required this.scope,
    required this.client_secret,
  });
}
