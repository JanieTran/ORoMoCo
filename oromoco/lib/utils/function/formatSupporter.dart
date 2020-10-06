import 'package:intl/intl.dart'; 

class FormatSupporter{
  String formatNumber(String string) {
    final format = NumberFormat.decimalPattern('en');
    return format.format(int.parse(string));
  }

  String formatPercent(String string) {
    final format = NumberFormat.percentPattern('en');
    return format.format(double.parse(string));
  }

  String formatAccountID(String index){
    return "U" + index.padLeft(3, "0");
  }

  String formatDateTime(String date){
    return DateFormat("dd/MM/yyyy kk:mm").format(DateTime.parse(date).toLocal()).toString();
  }
}