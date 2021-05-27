// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String eventDate;
  final String eventTime;
  final String eventTitle;
  final String eventDesc;
  final String eventLocation;
  final String eventType;

  const Event(
      {required this.eventDate,
      required this.eventTime,
      required this.eventTitle,
      required this.eventDesc,
      required this.eventLocation,
      required this.eventType});
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(2020, 10, item * 5),
    value: (item) => List.generate(
        item % 4 + 1,
        (index) => Event(
              eventDate: '',
              eventTime: '10:50AM - 12:30AM',
              eventTitle: 'Event $item | ${index + 1}',
              eventLocation: 'W Sunset Blvd, Los Angeles, CA 89102',
              eventType: 'Work',
              eventDesc: 'Blah',
            )))
  ..addAll({
    DateTime.now(): [
      Event(
        eventDate: '',
        eventTime: '10:50AM - 12:30AM',
        eventTitle: 'Today\'s Event 1',
        eventLocation: '1 W Sunset Blvd, Los Angeles, CA 89102',
        eventType: 'Work',
        eventDesc: 'Blah',
      ),
      Event(
        eventDate: '',
        eventTime: '10:50AM - 12:30AM',
        eventTitle: 'Today\'s Event 2',
        eventLocation: '2 W Sunset Blvd, Los Angeles, CA 89102',
        eventType: 'Work',
        eventDesc: 'Blah',
      ),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kNow = DateTime.now();
final kFirstDay = DateTime(kNow.year, kNow.month - 3, kNow.day);
final kLastDay = DateTime(kNow.year, kNow.month + 3, kNow.day);
