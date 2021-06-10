import 'package:flutter/material.dart';

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
    if (widget.eventType == 'Personal') { typeColor = const Color.fromARGB(255, 146, 223, 173); }
    if (widget.eventType == 'Work') { typeColor = const Color.fromARGB(255, 103, 200, 225); }
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.eventTime,
                style: const TextStyle(
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
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
           Text(
            widget.eventTitle,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 5),
           Text(
            widget.eventLocation,
             overflow: TextOverflow.ellipsis,
             style: const TextStyle(
              fontSize: 18,
              letterSpacing: -0.3,
              fontFamily: 'Inter-Light',
              color: Color.fromARGB(255, 155, 165, 170),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            child:Text(
              widget.eventDesc,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: -0.3,
                fontFamily: 'Inter-Light',
                color: Color.fromARGB(150, 155, 165, 170),
              ),
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
