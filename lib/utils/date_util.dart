String getTimeDistance(String time) {
  DateTime now = DateTime.now();
  DateTime dateTime = DateTime.parse(time);
  int distance = now.difference(dateTime).inDays;
  int hourDistance = now.difference(dateTime).inHours;
  if (distance == 0) {
    return '$hourDistance time ago';
  } else if (distance == 1) {
    return 'yesterday';
  } else if (distance == 2) {
    return 'before yesterday';
  } else if (distance > 2 && distance < 7) {
    return '$distance days ago';
  } else if (distance >= 7 && distance < 30) {
    return '${distance ~/ 7} weeks ago';
  } else if (distance >= 30 && distance < 365) {
    return '${distance ~/ 30} months ago';
  } else {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }
}
