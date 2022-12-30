import 'package:flutter/material.dart';

nextPage({required context, required page}) {
  return Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

goBack({required context}) {
  return Navigator.of(context).pop();
}
