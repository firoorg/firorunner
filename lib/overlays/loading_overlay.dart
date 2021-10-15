import 'package:flutter/material.dart';

import '../main.dart';

/// This is the stateful widget that the main application instantiates.
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    Key? key,
  }) : super(key: key);

  @override
  State<LoadingOverlay> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Loading',
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(color: textColor),
              ),
              const CircularProgressIndicator(
                strokeWidth: 10.0,
                value: null,
                valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                backgroundColor: titleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
