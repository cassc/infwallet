import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const DEFAULT_EDGE = 12.0;

Widget datetimePicker(initDate, onChanged){
  final format = DateFormat("yyyy-MM-dd HH:mm");
    var df = DateTimeField(
      format: format,
      onShowPicker: (context, currentValue) {
        return showDatePicker(
            context: context,
            firstDate: DateTime(2012),
            initialDate: initDate,
            lastDate: DateTime(2100));
      },
      onChanged: onChanged,
    );
    return df;
}
