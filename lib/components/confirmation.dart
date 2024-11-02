import 'package:flutter/material.dart';

Future<bool?> confirm(BuildContext context, {String? textOk, String? textCancel, required String titre, String? description}) async {
  bool? a;
  await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(titre),
            content: description == null ? null : Text(description),
            actions: [
              TextButton(
                  onPressed: () {
                    a = true;
                    Navigator.pop(context, a);
                  },
                  child: Text(textOk ?? 'Ok')),
              TextButton(
                  onPressed: () {
                    a = false;
                    Navigator.pop(context, a);
                  },
                  child: Text(textCancel ?? 'Cancel')),
            ],
          ));
  return a;
}
