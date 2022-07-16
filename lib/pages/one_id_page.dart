import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_id/models/get_code_model.dart';
import 'package:one_id/models/get_token_model.dart';
import 'package:one_id/models/get_user_info.dart';
import 'package:one_id/services/dio_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OneID extends StatefulWidget {
  const OneID({Key? key,
    required this.token,
    required this.code,
    required this.userInfo,
  }) : super(key: key);

  final Code code;
  final Token token;
  final UserInfo userInfo;

  @override
  State<OneID> createState() => _OneIDState();
}

class _OneIDState extends State<OneID> {
  late String urlOneId;
  late WebViewController _webViewController;
  late String code;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(defaultTargetPlatform == TargetPlatform.android) {
      urlOneId = "https://sso.egov.uz/sso/oauth/Authorization.do?response_type=${widget.code.response_type}&client_id=${widget.code.client_id}&redirect_uri=${widget.code.redirect_uri}&scope=${widget.code.scope}&state=${widget.code.state}";
      WebView.platform = AndroidWebView();

    } else if(defaultTargetPlatform == TargetPlatform.iOS) {
      urlOneId = "https://sso.egov.uz/sso/oauth/Authorization.do?response_type=${widget.code.response_type}&client_id=${widget.code.client_id}&redirect_uri=${widget.code.redirect_uri}&scope=${widget.code.scope}&state=${widget.code.state}";
      WebView.platform = CupertinoWebView();
    }
  }
  
  void apiGetCode(String url) async {
    if(url.contains("code=")) {
      setState((){
        code = url.substring(url.indexOf("code=") + 1, url.indexOf("&state"));
        apiGetToken();
      });
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
  
  void apiGetToken() async {
    String? response = await DioService.post(api: "/sso/oauth/Authorization.do", params: queryToken());

    if(response != null) {
      print(response);
    } else {
      print("Error");
    }
  }

  // api get token for query
  Map<String, String> queryUserInfo() {
    Map<String, String> map = {
      "grant_type": widget.userInfo.grant_type,
      "client_id": widget.userInfo.client_id,
      "client_secret": widget.userInfo.client_secret,
      "scope": widget.userInfo.scope,
      "access_token": widget.userInfo.access_token,
    };
    return map;
  }

  void apiGetUserInfo() async {
    String? response = await DioService.get(api: "/sso/oauth/Authorization.do", params: queryUserInfo());
    if(response != null) {
      print(response);
    } else {
      print("Error");
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
          await _webViewController.currentUrl().then((value) => {
            if(value != null) {
             apiGetCode(value),
            }
          });
        },
        onWebResourceError: (error){
          if(kDebugMode) {
            print("Error");
          }
        },
      ),
    );
  }
}