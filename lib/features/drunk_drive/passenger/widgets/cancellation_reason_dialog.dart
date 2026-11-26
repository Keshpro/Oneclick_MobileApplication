import 'package:flutter/material.dart';

Future<String?> chooseCancellationReason(BuildContext context, {required bool driver}) {
  final reasons = driver
      ? ['Unable to reach pickup', 'Vehicle incompatibility', 'Safety concern', 'Other']
      : ['Plans changed', 'Waiting too long', 'Incorrect booking details', 'Safety concern', 'Other'];
  return showDialog<String>(context: context, builder: (context) => SimpleDialog(
    title: const Text('Reason for cancellation'),
    children: [
      for (final reason in reasons)
        SimpleDialogOption(onPressed: () => Navigator.pop(context, reason), child: Text(reason)),
      SimpleDialogOption(onPressed: () => Navigator.pop(context), child: const Text('Keep booking')),
    ],
  ));
}
