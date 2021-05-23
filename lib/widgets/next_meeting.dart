import 'package:flutter/material.dart';
import 'package:calendar/utils/event_item.dart';

class nextMeeting extends StatelessWidget {
  const nextMeeting({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container (
      // margin: const EdgeInsets.all(10),
      // width: 1000,
      decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 247, 247, 247),
          width: 10,
          ),
        color: Colors.white,
      ),
      child: const eventItem(
        eventDate: '',
        eventTime: '10:50AM - 12:30AM',
        eventTitle: 'Dentist Appointment',
        eventLocation: '6255 W Sunset Blvd, Los Angeles, CA 89102',
        eventType:'Personal',
        eventDesc: 'Blah',
      ),
    );
  }
}
