import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:collection';
import './utils.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert' show json;
import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  clientId: '9845738125-ktgh7e3bfq20a5oe2pfohue0lt56g5us.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/calendar.readonly',
  ],
);

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'Calendar Dashboard',
      theme: ThemeData(fontFamily: 'Inter'),
      // home: CalendarPage(),
      home: SignInDemo(),
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
  String _eventTime = "";
  var formattedTime = DateFormat('kk:mm').format(DateTime.now()).toString();
  var formattedDate = DateFormat('E, MMMM d, y').format(DateTime.now()).toString();

  Color blueColor = const Color(0xFF67C8FF);
  Color greyColor = const Color(0xFF555555);



  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);

  // Using a `LinkedHashSet` is recommended due to equality comparison override
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

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
    final String formattedTime = DateFormat('kk:mm').format(DateTime.now()).toString();
    final String formattedDate = DateFormat('E, MMMM d, y').format(DateTime.now()).toString();
    _selectedDay = _focusedDay;
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }
  void _getTime() {
    final DateTime now = DateTime.now();
    final String newformattedTime = DateFormat('kk:mm').format(DateTime.now()).toString();
    final String newformattedDate = DateFormat('E, MMMM d, y').format(DateTime.now()).toString();
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
                  Container(
                    child:
                    nextMeeting(),
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
        child: Container(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: eventItem(
                      eventDate: "",
                      eventTime: "10:50AM - 12:30AM",
                      eventTitle: '${value[index]}',
                      eventLocation: "6255 W Sunset Blvd, Los Angeles, CA 89102",
                      eventType:"Work",
                      eventDesc: "Blah",
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
                    style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 200, 200, 200)),
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
                BoxDecoration(color: Color.fromARGB(255, 50, 50, 50), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white),
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

class nextMeeting extends StatelessWidget {
  const nextMeeting({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container (
      margin: EdgeInsets.all(30),
      width: 1000,
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 247, 247, 247),
          width: 10,
          ),
        color: Colors.white,
      ),
      child:eventItem(
        eventDate: "",
        eventTime: "10:50AM - 12:30AM",
        eventTitle: "Dentist Appointment",
        eventLocation: "6255 W Sunset Blvd, Los Angeles, CA 89102",
        eventType:"Personal",
        eventDesc: "Blah",
      ),
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.fromLTRB(70, 15, 70, 15),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0, 220, 194),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          children: [
            Text(
              "1 HR 36 MIN",
              style: TextStyle(
                fontSize: 64,
                fontFamily: 'Inter-SemiBold',
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 0),
                    blurRadius: 1,
                    color: Color.fromARGB(150, 0, 0, 0),
                  ),
                ],
              ),
            ),
            Text(
              "UNTIL NEXT MEETING",
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Inter',
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 0),
                    blurRadius: 1,
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
          padding: EdgeInsets.fromLTRB(0, 80, 0, 10),
          child: Text(
            formattedTime,
            style: TextStyle(
              fontSize: 128,
              fontFamily: 'Inter-SemiBold',
              letterSpacing: -3,
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
            fontSize: 28,
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
        Container(
          padding: const EdgeInsets.all(20),
          child:Text(
              "You have 2 meetings left today!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white38,
              ),
            ),
        )
      ],
    );
  }
}
class eventItem extends StatefulWidget{
  final String eventDate;
  final String eventTime;
  final String eventTitle;
  final String eventDesc;
  final String eventLocation;
  final String eventType;
  const eventItem({Key? key, required this.eventDate, required this.eventTime, required this.eventTitle, required this.eventDesc, required this.eventLocation, required this.eventType}): super(key: key);
  @override
  _eventItemState createState() => _eventItemState();
}
class _eventItemState extends State<eventItem> {
  var typeColor;
  @override
  Widget build(BuildContext context) {
    if (widget.eventType == "Personal") { typeColor = Color.fromARGB(255, 146, 223, 173); }
    if (widget.eventType == "Work") { typeColor = Color.fromARGB(255, 103, 200, 225); }
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.eventTime,
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: -0.5,
                  fontFamily: 'Inter-ExtraLight',
                  color: Color.fromARGB(255, 81, 106, 120),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.eventType,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
           Text(
            widget.eventTitle,
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 5),
           Text(
            widget.eventLocation,
            style: TextStyle(
              fontSize: 18,
              letterSpacing: -0.3,
              fontFamily: 'Inter-Light',
              color: Color.fromARGB(255, 155, 165, 170),
            ),
          ),
          const SizedBox(height: 5),
           Text(
            widget.eventDesc,
            style: TextStyle(
              fontSize: 18,
              letterSpacing: -0.3,
              fontFamily: 'Inter-Light',
              color: Color.fromARGB(255, 155, 165, 170),
            ),
          ),
          const SizedBox(height: 10),
          const Icon(
            Icons.account_circle_rounded,
            color: Colors.grey,
          ),
        ],
      ),

    );
  }
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
      Uri.parse("https://www.googleapis.com/calendar/v3/calendars/${user.email}/events"
        '?timeMin=2021-05-19T00:00:00-07:00'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "Calendar API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('Calendar API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'];
    final Map<String, dynamic>? contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text("Signed in successfully."),
          Text(_contactText),
          ElevatedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          ElevatedButton(
            child: const Text('REFRESH'),
            onPressed: () => _handleGetContact(user),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
