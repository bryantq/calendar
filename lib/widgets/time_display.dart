import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 10),
          child: Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 96,
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
          style: const TextStyle(
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
          child: const Text(
              'You have 2 meetings left today!',
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
