import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:projet_transverse_l2/AffichagePeremption.dart';
import 'package:provider/provider.dart';

import 'AppState.dart';
import 'image_picker_class.dart';
import 'modal_dialog.dart';
//import 'recognization_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    //
    //final appState = Provider.of<AppState>(context);
    bool isSwitchedOn = true;

    return Scaffold(
      // creation de la Appbar
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Center(
            child: Text(
          "R.E.M.I",
          style: TextStyle(color: Colors.white70),
        )),
      ),
      body: Column(
        children: [
          // creation du bouton poussoir
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 135),
              ),
              LiteRollingSwitch(
                onSwipe: () {},
                onTap: () {},
                onDoubleTap: () {},
                value: isSwitchedOn,
                textOn: "On",
                textOff: "Off",
                colorOn: Colors.greenAccent,
                colorOff: Colors.black38,
                iconOn: Icons.volume_up_rounded,
                iconOff: Icons.volume_off_rounded,
                onChanged: (bool position) {
                  print("c'est validé is $position");
                  isSwitchedOn = position;
                },
              ),
            ],
          ),

          // cration 1er bouton
          Expanded(
              child: Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(280, 80),
                  textStyle: TextStyle(fontSize: 28),
                  primary: Colors.black38, //background
                  onPrimary: Colors.white70, //foreground
                ),
                child: Text("Scannez un article"),
                onPressed: () {
                  imagePickerModal(context, onCameraTap: () {
                    log("Camera");
                    pickImage(source: ImageSource.camera).then((value) {
                      if (value != '') {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => AffichagePeremption(
                              path: value,
                            ),
                          ),
                        );
                      }
                    });
                  });
                }),
          ))
        ],
      ),
    );
  }
}
