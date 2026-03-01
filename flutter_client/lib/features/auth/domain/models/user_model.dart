import 'package:flutter/foundation.dart';

/// Strongly typed user model for the domain layer.
/// The UI and providers NEVER work with raw Maps for user data.
@immutable
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? mercadopagoAlias;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.mercadopagoAlias,
  });

  String get displayName => fullName ?? email.split('@').first;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      mercadopagoAlias: json['mercadopago_alias'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
