import 'package:flutter/material.dart';

class UpdateButton extends StatelessWidget {
  const UpdateButton({Key? key, required this.onPressed}) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
            overlayColor:
                MaterialStateProperty.all(Colors.black.withOpacity(0.2))),
        onPressed: onPressed,
        child: Icon(
          Icons.refresh,
          color: Colors.white.withOpacity(0.5),
        ));
  }
}
