import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
//import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import 'dart:developer';
//import 'dart:io';

import 'package:path_provider/path_provider.dart';
//import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'AppState.dart';

class AffichagePeremption extends StatefulWidget {
  final String? path;
  const AffichagePeremption({Key? key, this.path}) : super(key: key);

  @override
  _AffichagePeremptionState createState() => _AffichagePeremptionState();
}

class _AffichagePeremptionState extends State<AffichagePeremption> {
  FlutterTts flutterTts = FlutterTts();
  String datePeremption = '';
  bool isSwitchedOn = true;
  bool isSearching = false;
  bool _isBusy = false;
  String outputFilePath = '';

  /*@override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    final InputImage inputImage = InputImage.fromFilePath(widget.path!);

    processImage(inputImage);
    _searchDatePeremption().then((_) {
      if (appState.isSwitchedOn && datePeremption.isNotEmpty) {
        _speak(datePeremption);
      }
    });
  }*/

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context, listen: false);

    if (widget.path != null) {
      final InputImage inputImage = InputImage.fromFilePath(widget.path!);
      processImage(inputImage);
    }

    //final InputImage inputImage = InputImage.fromFilePath(widget.path!);

    //processImage(inputImage);
    /*_searchDatePeremption().then((_) {
    if (appState.isSwitchedOn && datePeremption.isNotEmpty) {
      _speak(datePeremption);
    }
  });*/
  }

  @override
  Widget build(BuildContext context) {
    //final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Center(
            child: Text(
          "R.E.M.I",
          style: TextStyle(color: Colors.white70),
        )),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSearching)
                const CircularProgressIndicator()
              else if (datePeremption.isNotEmpty)
                Text(
                  'Ce produit périme le $datePeremption',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )
              else
                const Text(
                  "La date de péremption n'est pas visible sur l'image. Reprenez la photo sous un autre angle.",
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (datePeremption.isNotEmpty) {
                    _speak(datePeremption);
                  }
                },
                child: const Text('Lire le texte'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 90, right: 5),
        child: LiteRollingSwitch(
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
            setState(() {
              isSwitchedOn = position;
            });
            if (isSwitchedOn && datePeremption.isNotEmpty) {
              _speak(datePeremption);
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  void processImage(InputImage image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    log(image.filePath!);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);

    // Obtenir le texte reconnu
    String recognizedTextString = recognizedText.text;

    // Chemin du fichier de sortie
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    outputFilePath =
        '${appDocumentsDir.path}/sortie.txt'; // Affectation de outputFilePath

    try {
      // Créer un fichier de sortie
      File outputFile = File(outputFilePath);

      // Écrire le texte reconnu dans le fichier
      await outputFile.writeAsString(recognizedTextString);

      // Vérifier si le fichier existe
      if (await File(outputFilePath).exists()) {
        // Lire le contenu du fichier
        String fileContent = await outputFile.readAsString();
        print('Contenu du fichier : $fileContent');

        await _searchDatePeremption();
      } else {
        print('Le fichier n\'existe pas');
      }

      // Afficher un message de succès ou effectuer d'autres opérations
    } catch (e) {
      // Gérer les erreurs lors de l'écriture du fichier
      print('Erreur lors de l' 'enregistrement du texte dans le fichier : $e');
    }

    ///End busy state
    setState(() {
      _isBusy = false;
    });
  }

  Future<List<String>> lireFichier(String nomFichier, String separateur) async {
    final fichier = await rootBundle.loadString('assets/$nomFichier');
    final lines = fichier.split('\n');
    final elements = <String>{};
    for (final i in lines) {
      final lineElements = i.split(separateur);
      for (final element in lineElements) {
        final separateElement = element.trim();
        if (separateElement.isNotEmpty) {
          elements.add(separateElement);
        }
      }
    }
    return elements.toList();
  }

  Future<List<String>> lireFichierLocal(
      String filePath, String separateur) async {
    final file = File(filePath);
    final lines = await file.readAsLines();
    final elements = <String>{};
    for (final line in lines) {
      final lineElements = line.split(separateur);
      for (final element in lineElements) {
        final separateElement = element.trim();
        if (separateElement.isNotEmpty) {
          elements.add(separateElement);
        }
      }
    }
    return elements.toList();
  }

  Future<void> _searchDatePeremption() async {
    setState(() {
      isSearching = true;
    });

    //final appState = Provider.of<AppState>(context);

    final fichier1 = await lireFichierLocal(outputFilePath, ' ');
    final fichier2 = await lireFichier('files/date_péremption.txt', ' ');

    final setFichier1 = Set<String>.from(fichier1);

    final setFichier2 = Set<String>.from(fichier2);

    final elementsCommuns = setFichier1.intersection(setFichier2);

    if (elementsCommuns.isNotEmpty) {
      print('Element en commun: $elementsCommuns');
      setState(() {
        datePeremption = elementsCommuns.first;
      });

      if (isSwitchedOn) {
        _speak(datePeremption);
      }
    } else {
      setState(() {
        datePeremption = '';
      });
    }

    setState(() {
      isSearching = false;
    });
    return; // Ajout de l'instruction de retour
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.speak("Ce produit périme le $text");
  }
}
