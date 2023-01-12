import 'package:flutter/material.dart';
import 'package:flutteragoradenemecem/pages/callpage.dart';
import '../src/settings.dart';

class LoginHome extends StatefulWidget {
  const LoginHome({super.key});

  @override
  State<LoginHome> createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  String userInput = "";
  final channelController = TextEditingController();
  bool validateError = false;
  bool broadcasterValue = false;
  bool audienceValue = false;
  String uyari = "";

  @override
  void dispose() {
    channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login to your session"),
        backgroundColor: color1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "YouRoom Test Labs",
              style: TextStyle(fontSize: 44, fontFamily: "Chase"),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                uyari,
                style: const TextStyle(color: Colors.red, fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                controller: channelController,
                onChanged: (value) {
                  setState(() {
                    userInput = value.toString();
                  });
                },
                decoration: InputDecoration(
                  errorText: validateError ? 'Channel name is mandatory' : null,
                  focusColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.app_shortcut_outlined,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: Colors.grey,
                  hintText: "Channel Name",
                  labelText: 'Channel Name',
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: "verdana_regular",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Text("Audience"),
                    Checkbox(value: audienceValue, onChanged: _audienceChecked),
                  ],
                ),
                Row(
                  children: [
                    const Text("Broadcaster"),
                    Checkbox(
                        value: broadcasterValue,
                        onChanged: _broadcasterChecked),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 24),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color2,
                    ),
                    onPressed: () {
                      setState(() {
                        channelController.text.isEmpty
                            ? validateError = true
                            : false;
                      });
                      debugPrint(userInput.toString());

                      if (userInput != "") {
                        if (audienceValue != false ||
                            broadcasterValue != false) {
                          debugPrint(userInput.toString());

                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (ctx) => CallPage(
                                        channelName: userInput
                                            .toString()
                                            .replaceAll(' ', ''),
                                        isAudience: audienceValue,
                                      )));
                        } else {
                          setState(() {
                            uyari = "Please check one of the boxes below";
                          });
                        }
                      }
                    },
                    child: const SizedBox(
                      height: 50,
                      width: 100,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Login"),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _audienceChecked(bool? value1) {
    setState(() {
      audienceValue = value1!;
      debugPrint(value1.toString());

      if (value1) {
        broadcasterValue = false;
        uyari = "";
      }
    });
  }

  void _broadcasterChecked(bool? value2) {
    setState(() {
      broadcasterValue = value2!;
      debugPrint(value2.toString());

      if (value2) {
        audienceValue = false;
        uyari = "";
      }
    });
  }
}
