class UserInfo {
  final String grant_type;
  final String client_id;
  final String client_secret;
  final String scope;
  final String access_token;

  UserInfo({required this.grant_type,
    required this.client_id,
    required this.scope,
    required this.access_token,
    required this.client_secret,
  });

}
