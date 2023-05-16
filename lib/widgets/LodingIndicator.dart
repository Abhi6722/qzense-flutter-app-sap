import 'package:flutter/material.dart';
import 'package:qzenesapp/screens/homepage.dart';


class LodingInd extends StatefulWidget {
  String msg = '';
  String model = ' ';

  LodingInd({required this.msg, required this.model});

  @override
  State<LodingInd> createState() => _LodingIndState();
}

class _LodingIndState extends State<LodingInd> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(),
        child: Dialog(
            backgroundColor: primaryColor,
            elevation: 2,
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.model == "BANANA"
                        ? Image.asset("images/assets/BananLoading.gif")
                        : Image.asset("images/assets/FisLoading.gif"),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      ' ${widget.msg}',
                      style: TextStyle(color: Colors.white),
                    )
                  ]),
            )),
      ),
    );
  }
}
