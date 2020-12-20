import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const DEFAULT_EDGE = 12.0;

Widget datetimePicker(initDate, onChanged) {
  final format = DateFormat("yyyy-MM-dd HH:mm");

  var df = DateTimeField(
    format: format,
    onChanged: onChanged,
    onShowPicker: (context, currentValue) async {
      final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2012),
          initialDate: initDate ?? DateTime.now(),
          lastDate: DateTime(2100));
      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
        );
        return DateTimeField.combine(date, time);
      } else {
        return currentValue;
      }
    },
  );
  return df;
}
