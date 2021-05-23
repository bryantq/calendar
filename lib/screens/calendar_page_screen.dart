import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:calendar/utils/event_item.dart';
import 'package:calendar/utils.dart';
import 'package:calendar/widgets/time_alert.dart';
import 'package:calendar/widgets/time_display.dart';
import 'package:calendar/widgets/next_meeting.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '9845738125-1v71ke84pjckvm7tkvqpglcui4rjnrn7.apps.googleusercontent.com',
  // clientId: '9845738125-ktgh7e3bfq20a5oe2pfohue0lt56g5us.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/calendar.readonly',
  ],
);
GoogleSignInAccount? _currentUser;

class CalendarPageScreen extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPageScreen> {
  bool _alertWidgetVisible = true;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  DateTime? _selectedDay;
  var formattedTime = DateFormat('kk:mm').format(DateTime.now()).toString();
  var formattedDate = DateFormat('E, MMMM d, y').format(DateTime.now()).toString();

  Color blueColor = const Color(0xFF67C8FF);
  Color greyColor = const Color(0xFF555555);

  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);

  // Using a `LinkedHashSet` is recommended due to equality comparison override
  String _contactText = '';

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events'
          '?timeMin=2021-05-19T00:00:00-07:00&maxResults=3&singleEvents=true&orderBy=startTime'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'Calendar API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      print('Calendar API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    List<dynamic> calevents = data['items'];
    calevents.forEach((calevents) {
      (calevents as Map<String, dynamic>).forEach((key, value) {
        print('$key : $value');
      });
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForDays(Set<DateTime> days) {
    // Implementation example
    // Note that days are in selection order (same applies to events)
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  void initState() {
    _selectedDay = _focusedDay;
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
    super.initState();
  }
  void _getTime() {
    final now = DateTime.now();
    final newformattedTime = DateFormat('kk:mm').format(now).toString();
    final newformattedDate = DateFormat('E, MMMM d, y').format(now).toString();
    setState(() {
      formattedTime = newformattedTime;
      formattedDate = newformattedDate;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
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
            // flex: 1,
            child: Container(
              color: Colors.blueGrey[800],
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  timeDisplay(formattedTime: formattedTime, formattedDate: formattedDate),
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
                      child: Container(
                      child:
                      const nextMeeting(),
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
                rightPane(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget rightPane() {
    var user = _currentUser;
    if (user == null) {
      return Expanded(
        child: loginBar(),
      );
    }
    else {
      return Expanded(
        child:
        Column (
          children: [
            calendarView(),
            agendaView(),
            loginBar(),
          ],
        ),
      );
    }
  }

  Widget loginBar() {
    var user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child:CircleAvatar(
                  backgroundImage: NetworkImage(avatarURL),
                ),
              ),

              Expanded (
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName ?? ''),
                    Text(user.email),
                  ],
                )
              ),

              //const Text("Signed in successfully."),
              //Text(_contactText),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child:
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.black38,
                    size: 24.0,
                  ),
                  color: Colors.black38,
                  tooltip: 'Refresh',
                  onPressed: () => _handleGetContact(user),
                )
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                child:
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black38,
                    size: 24.0,
                  ),
                  color: Colors.black38,
                  tooltip: 'Logout',
                  onPressed: _handleSignOut,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }

  Widget agendaView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        //padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        color: const Color(0xFFF2F2F2),
        child: Container(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: eventItem(
                      eventDate: '${value[index].eventDate}',
                      eventTime: '${value[index].eventTime}',
                      eventTitle: '${value[index].eventTitle}',
                      eventLocation: '${value[index].eventLocation}',
                      eventType: '${value[index].eventType}',
                      eventDesc: '${value[index].eventDesc}',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget calendarView() {
    return TableCalendar(
      firstDay: kFirstDay,
      lastDay: kLastDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.week: 'Week'
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: true,
        outsideDaysVisible: true,
      ),
      rowHeight: 50,
      eventLoader: _getEventsForDay,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
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
        outsideBuilder: (BuildContext context, DateTime date, DateTime date2) {
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
                    style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 200, 200, 200)),
                  ),
                ),
              ),
            ),
          );
        },
        todayBuilder: (BuildContext context, DateTime date, DateTime date2) {
          return Container(
            margin: const EdgeInsets.only(top: 5),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Container(
                decoration:
                const BoxDecoration(color: Color.fromARGB(255, 50, 50, 50), shape: BoxShape.circle),
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
    );
  }
}
