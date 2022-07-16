class Token {
  Token({
    required this.code,
    required this.grant_type,
    required this.client_id,
    required this.client_secret,
    required this.redirect_uri,
  });

  final String code;
  final String grant_type;
  final String client_id;
  final String client_secret;
  final String redirect_uri;
}