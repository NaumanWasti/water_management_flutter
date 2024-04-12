// ignore_for_file: empty_catches, avoid_print, unrelated_type_equality_checks, non_constant_identifier_names

// import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

import 'db_model/constants.dart';


class SocketService {
  final String hubName;
  final int groupBy;
  final String groupMethodController;
  final String deviceId;
  final String groupByString;
  HubConnection? _connection;
  final String? access_token;
  final String? platform;
  SocketService(
      {required this.hubName,
      required this.groupMethodController,
      required this.groupBy,
      this.deviceId = "",
      this.access_token = "",
      this.platform = "",
      this.groupByString = ""});

  Future<HubConnection?> initSocket() async {
    // String url = '$base_url/$hubName';
    String url = '';

    _connection = HubConnectionBuilder()
        .withUrl(url,
            //'$serverUrl$hubName',
            HttpConnectionOptions(
              //accessTokenFactory: () async=> token=="" ? null : token,
              logging: (level, message) => print(message),
            ))
        // .withAutomaticReconnect()
        .build();
    try {
      await _connection!.start();
      _groupConnection();
      _connection!.onreconnected((connectionId) {
        _groupConnection();
      });
      _connection!.onreconnecting((exception) {});
    } catch (e) {}

    _connection!.onclose((error) {});
    return _connection;
  }

  void _groupConnection() {
    if (groupByString != "") {
      _connection!.invoke(groupMethodController, args: [groupByString]);
    } else {
      _connection!.invoke(groupMethodController,
          args: [deviceId == "" ? groupBy : deviceId]);
    }
  }
}

