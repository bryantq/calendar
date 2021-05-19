import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: 'Inter'),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _alertWidgetVisible = true;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime? _selectedDay;
  var formattedTime = DateFormat('kk:mm').format(DateTime.now()).toString();
  var formattedDate =
      DateFormat('E, MMMM d, y').format(DateTime.now()).toString();

  Color blueColor = const Color(0xFF67C8FF);
  Color greyColor = const Color(0xFF555555);

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //  title: const Text(
      //    'Calendar',
      //    style: TextStyle(fontFamily: 'Arial Bold'),
      //  ),
      //),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueGrey[800],
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: timeDisplay(formattedTime: formattedTime, formattedDate: formattedDate),
                  ),
                  Container(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _alertWidgetVisible = !_alertWidgetVisible;
                        });
                      },
                      child: timeAlert(alertWidgetVisible: _alertWidgetVisible),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Next Meeting Placeholder",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                calendarView(),
                agendaView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget agendaView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        color: const Color(0xFFF2F2F2),
        child: ListView(
          children: [
            AgendaItem(selectedDay: _selectedDay),
            Divider(color: Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget calendarView() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.week: 'Week'
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
      ),
      rowHeight: 50,
      calendarBuilders: CalendarBuilders(
        markerBuilder:
            (BuildContext context, DateTime date, List<dynamic> events) {
          if (events.isEmpty) {
            return null;
          }
          return Container(
            padding: const EdgeInsets.only(bottom: 2),
            child: SizedBox(
              width: 6,
              height: 6,
              child: Container(
                decoration: BoxDecoration(
                    color: isSameDay(_selectedDay, date)
                        ? Colors.white
                        : blueColor,
                    shape: BoxShape.circle),
              ),
            ),
          );
        },
        defaultBuilder: (BuildContext context, DateTime date, DateTime date2) {
          return Container(
            margin: const EdgeInsets.only(top: 5),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Container(
                child: Center(
                  child: Text(
                    date.day.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: greyColor),
                  ),
                ),
              ),
            ),
          );
        },
        selectedBuilder: (BuildContext context, DateTime date, DateTime date2) {
          return Container(
            margin: const EdgeInsets.only(top: 5),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Container(
                decoration:
                    BoxDecoration(color: blueColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      headerStyle: const HeaderStyle(
        // formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: Color(0xFF9BA5AA),
        ),
        titleCentered: true,
        leftChevronIcon: Icon(
          Icons.arrow_left_rounded,
          color: Colors.grey,
          size: 30,
        ),
        rightChevronIcon: Icon(
          Icons.arrow_right_rounded,
          color: Colors.grey,
          size: 30,
        ),
      ),
      eventLoader: (day) {
        if (day.weekday == DateTime.monday) {
          return [Text('Cyclic event')];
        }

        return [];
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
    );
  }
}

class timeAlert extends StatelessWidget {
  const timeAlert({
    Key? key,
    required bool alertWidgetVisible,
  }) : _alertWidgetVisible = alertWidgetVisible, super(key: key);

  final bool _alertWidgetVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _alertWidgetVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 150),
      child: Container(
        padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
        decoration: BoxDecoration(
          color: Color(0xff7c94b6),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          children: [
            Text(
              "1 HR 36 MIN",
              style: TextStyle(
                fontSize: 48,
                fontFamily: 'Inter-SemiBold',
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 0),
                    blurRadius: 2,
                    color: Color.fromARGB(100, 0, 0, 0),
                  ),
                ],
              ),
            ),
            Text(
              "UNTIL NEXT MEETING",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Inter',
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 0),
                    blurRadius: 2,
                    color: Color.fromARGB(100, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class timeDisplay extends StatelessWidget {
  const timeDisplay({
    Key? key,
    required this.formattedTime,
    required this.formattedDate,
  }) : super(key: key);

  final String formattedTime;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
          child: Text(
            formattedTime,
            style: TextStyle(
              fontSize: 96,
              fontFamily: 'Inter-SemiBold',
              letterSpacing: -5,
              color: Colors.white,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(0, 0),
                  blurRadius: 10.0,
                  color: Color.fromARGB(150, 0, 0, 0),
                ),
              ],
            ),
          ),
        ),
        Text(
          formattedDate,
          style: TextStyle(
            fontFamily: 'Inter-ExtraLight',
            fontSize: 20,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0, 0),
                blurRadius: 5.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        Chip(
          backgroundColor: Colors.white,
          padding: EdgeInsets.all(10),
          label: Text(
            "You have no meetings left today!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class AgendaItem extends StatelessWidget {
  const AgendaItem({
    Key? key,
    required DateTime? selectedDay,
  })   : _selectedDay = selectedDay,
        super(key: key);

  final DateTime? _selectedDay;


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          child: Column(
            children: [
              Text(
                _selectedDay!.day.toString(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Color(0xFF9BA5AA),
                ),
              ),
              Text(
                DateFormat('EEE').format(_selectedDay!),
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF9BA5AA),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '10:00AM - 10:45AM',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF92E0AD),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Personal',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Dentist Appointment',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  '3692 W Sunset Blvd, Las Vegas, NV 89113',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9BA5AA),
                  ),
                ),
                const Text(
                  'Weekly Leadership Meeting',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9BA5AA),
                  ),
                ),
                const SizedBox(height: 15),
                const Icon(Icons.account_circle_rounded)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
