import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sdui/sdui.dart';

import 'http.dart';
import 'parser.dart';

/// Returns the content of a route
abstract class RouteContentProvider {
  Future<String> getContent();
}

/// Static implementation of RouteContentProvider with static content
class StaticRouteContentProvider implements RouteContentProvider {
  String json;

  StaticRouteContentProvider(this.json);

  @override
  Future<String> getContent() {
    return Future(() => json);
  }
}

/// Static implementation of RouteContentProvider with static content
class HttpRouteContentProvider implements RouteContentProvider {
  String url;

  HttpRouteContentProvider(this.url);

  @override
  Future<String> getContent() async => Http.getInstance().post(url, null);
}

/// Dynamic Route
class DynamicRoute extends StatefulWidget {
  final RouteContentProvider provider;
  final PageController? pageController;

  const DynamicRoute({Key? key, this.pageController, required this.provider})
      : super(key: key);

  @override
  DynamicRouteState createState() =>
      DynamicRouteState(provider, pageController);
}

class DynamicRouteState extends State<DynamicRoute> {
  static final Logger _logger = Logger(
    printer: LogfmtPrinter(),
  );
  final RouteContentProvider provider;
  final PageController? pageController;
  late Future<String> content;

  DynamicRouteState(this.provider, this.pageController);

  @override
  void initState() {
    super.initState();
    content = provider.getContent();
  }

  @override
  Widget build(BuildContext context) => Center(
      child: FutureBuilder<String>(
          future: content,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              SDUIWidget widget =
                  SDUIParser.getInstance().fromJson(jsonDecode(snapshot.data!));
              widget.attachPageController(pageController);
              return widget.toWidget(context);
            } else if (snapshot.hasError) {
              _logger.e('Unable to get content - $snapshot.error');
              return const Icon(Icons.error);
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          }));
}
