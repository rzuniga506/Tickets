class LoginRequest {
  final String email;
  final String password;
  final String? dispositivoInfo;

  LoginRequest({
    required this.email,
    required this.password,
    this.dispositivoInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (dispositivoInfo != null) 'dispositivoInfo': dispositivoInfo,
    };
  }
}
