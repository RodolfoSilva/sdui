import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef ErrorStateBuilder = Widget Function(BuildContext context, Object? error);

/// Error state
// ignore: prefer_function_declarations_over_variables
ErrorStateBuilder sduiErrorState = (context, error) =>
    Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: const Icon(Icons.error, size: 80, color: Color(0xff8B0000)),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: const Text('Oops', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))
          ),
          Container(
            alignment: Alignment.center,
            child: const Text('An unexpected error has occured', textAlign: TextAlign.center, style: TextStyle(fontSize: 18))
          ),
        ]));
