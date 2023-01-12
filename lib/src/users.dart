import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final bool? localMute;
  final bool? remoteMute;
  final bool? serverMute;
  //final String email;
  //final String bio;

  UserModel(this.id, {this.localMute, this.remoteMute, this.serverMute});

  UserModel userBul(int id) {
    return UserModel(id);
  }
}
