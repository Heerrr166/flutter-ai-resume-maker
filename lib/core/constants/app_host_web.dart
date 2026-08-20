// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

String currentApiHost() {
  final hostname = html.window.location.hostname;
  return (hostname == null || hostname.isEmpty) ? 'localhost' : hostname;
}