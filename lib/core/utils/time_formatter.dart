import 'package:intl/intl.dart';

class TimeFormatter {
  TimeFormatter._();

  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _dateOnly = DateFormat('dd MMM yyyy');

  static String formatTime(DateTime time) => _timeOnly.format(time);
  static String formatDateTime(DateTime time) => _dateTime.format(time);
  static String formatDate(DateTime time) => _dateOnly.format(time);

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDurationHuman(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$minutes min';
    }
  }
}
