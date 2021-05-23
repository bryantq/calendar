import 'package:flutter/material.dart';

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
      duration: const Duration(milliseconds: 150),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.fromLTRB(70, 15, 70, 15),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 220, 194),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          children: [
            const Text(
              '1 HR 36 MIN',
              style: TextStyle(
                fontSize: 56,
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
            const Text(
              'UNTIL NEXT MEETING',
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
