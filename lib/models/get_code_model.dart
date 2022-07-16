class Code {
  const Code({
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