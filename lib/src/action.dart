import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'route.dart';

/// Descriptor of a widget behavior.
/// This class can be used to:
/// - Handle the screen navigation
/// - Handle the page navigation
/// - Execute commands
///
/// ### JSON Attributes
/// - **type**: Type of action. The supported values are:
///   - `screen`: To redirect to another screen
///   - `page`: To redirect to another page, in the context of [PageView]
///   - `command`: To execute a command on the server
/// - **url**: Action URL
///   - ``route:/..``: redirect users to previous route
///   - ``page:/<PAGE_NUMBER>``: redirect users to a given page. `<PAGE_NUMBER>` is the page index (starting with `0`).
///   - URL starting with ``route:/<ROUTE_NAME>`` redirect user the a named route. (Ex: ``route:/checkout``)
///   - URL starting with ``http://`` or ``https`` redirect user to a server driven page
class SDUIAction {
  static final Logger _logger = Logger(
    printer: LogfmtPrinter(),
  );

  static final Future<String> _emptyFuture = Future(() => "{}");

  String type = '';
  String url = '';

  /// controller associated with the action
  PageController? pageController;

  SDUIAction fromJson(Map<String, dynamic>? attributes) {
    url = attributes?["url"] ?? '';
    type = attributes?["type"] ?? '';
    return this;
  }

  Future<String> execute(
      BuildContext context, Map<String, dynamic>? data) async {
    switch (type.toLowerCase()) {
      case 'screen':
        return _gotoRoute(context, data);
      case 'page':
        return _gotoPage(context, data);
      case 'command':
        return _execute(context, data);
      default:
        return _emptyFuture;
    }
  }

  Future<String> _gotoPage(BuildContext context, Map<String, dynamic>? data) {
    _logger.i('Navigating to page $url');

    int page = -1;
    try {
      page = int.parse(url.substring(6));
    } catch (e) {
      page = 0;
    }

    pageController?.animateToPage(page,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    return _emptyFuture;
  }

  Future<String> _gotoRoute(BuildContext context, Map<String, dynamic>? data) {
    if (_isRoute()) {
      _logger.i('Navigating to route $url');
      var route = url.substring(6);
      if (route == '/..') {
        Navigator.pop(context);
      } else {
        Navigator.pushNamed(context, route);
      }
    } else if (_isNetwork()) {
      _logger.i('Navigating to screen $url');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DynamicRoute(provider: HttpRouteContentProvider(url))),
      );
    }
    return _emptyFuture;
  }

  Future<String> _execute(
      BuildContext context, Map<String, dynamic>? data) async {
    _logger.i('Executing command $url $data');
    final response = await http.post(Uri.parse(url),
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('FAILED: $url - ${response.statusCode}');
    }
  }

  bool _isRoute() => url.startsWith('route:') == true;

  bool _isNetwork() => url.startsWith('http://') || url.startsWith('https://');
}
