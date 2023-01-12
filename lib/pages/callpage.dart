import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteragoradenemecem/pages/loginPage.dart';
import 'package:flutteragoradenemecem/src/buttonapp.dart';
import 'package:flutteragoradenemecem/src/users.dart';
import 'package:permission_handler/permission_handler.dart';
import '../src/settings.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key, this.channelName, this.isAudience})
      : super(key: key);
  final bool? isAudience;
  final String? channelName;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool muted = false;
  bool remoteUsermuted = false;
  final users = <int>[];
  List<int> remoteUserIDs = [];
  final infoStrings = <String>[];

  List<UserModel> userModels = [];
  String muteFrom = "";
  String unmuteFrom = "";

  @override
  void initState() {
    super.initState();
    initAgora();
    if (widget.isAudience!) {
      muteFrom = "Mute for yourself";
      unmuteFrom = "Unmute for yourself";
    } else if (widget.isAudience! == false) {
      muteFrom = "Mute from server";
      unmuteFrom = "Unmute from server";
    }
  }

  @override
  void dispose() {
    super.dispose();
    users.clear();
    _engine.leaveChannel();
    _localUserJoined = false;
    userModels.clear();
  }

// ********************AGORA ENGINE INITIALIZATION*******************
  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
            userModels.add(UserModel(remoteUid,
                localMute: false, serverMute: false, remoteMute: false));

            remoteUserIDs.add(remoteUid);
            users.add(_remoteUid!);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            remoteUserIDs.remove(remoteUid);
            userModels.remove(UserModel(remoteUid));
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: homeWidget());
  }

  Widget homeWidget() {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Agora Call"),
          backgroundColor: color1,
          actions: widget.isAudience!
              ? []
              : <Widget>[
                  PopupMenuButton<String>(
                    onSelected: choiceAction,
                    itemBuilder: (BuildContext context) {
                      return Constants.choices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  )
                ],
        ),
        body: Stack(
          children: [
            listViewdeneme(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 5),
                child: SizedBox(
                  width: 200,
                  height: 250,
                  child: Stack(children: [
                    Center(
                      child: _localUserJoined
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: _engine,
                                canvas: const VideoCanvas(uid: 0),
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: muted
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 6, top: 6, right: 4),
                              child: Container(
                                color: Colors.blueGrey.shade600,
                                child: const Icon(
                                  Icons.mic_off,
                                  size: 45,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : const Text(""),
                    )
                  ]),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color6),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context),
                  );
                  debugPrint("BASILDIIIIIIIII ");
                  debugPrint("Info string in icinde ne var: $infoStrings");
                  debugPrint("Remote ID: $_remoteUid");
                  debugPrint("Users emtpy mi: ${users.isEmpty}");
                  debugPrint("Local User Joined: $_localUserJoined");
                  debugPrint("Channel Name: ${widget.channelName}");
                  debugPrint("RemoteuserIDs: ${remoteUserIDs.toString()}");
                  debugPrint("users.lenght : ${users.length.toString()}");
                },
                child: const Text("Debug Console"),
              ),
            ),
            toolBar(),
          ],
        ),
      ),
    );
  }

// ************** FUNCTIONS *************************

  void endCall() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const LoginHome()));
  }

  void handleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                  _engine.leaveChannel();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void choiceAction(String choice) {
    if (choice == Constants.muteAll) {
      _engine.muteAllRemoteAudioStreams(true);
      setState(() {
        remoteUsermuted = true;
      });
    } else if (choice == Constants.unmuteAll) {
      _engine.muteAllRemoteAudioStreams(false);
      setState(() {
        remoteUsermuted = false;
      });
    }
  }
  //  *****************WIDGETS***********************

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Popup example'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color6),
            onPressed: () {
              setState(() {
                _engine.muteRemoteAudioStream(uid: _remoteUid!, mute: true);
                remoteUsermuted = true;
              });

              Navigator.of(context).pop();
            },
            child: Text(muteFrom),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color6),
            onPressed: () {
              setState(() {
                _engine.muteRemoteAudioStream(uid: _remoteUid!, mute: false);
                Navigator.of(context).pop();
                remoteUsermuted = false;
              });
            },
            child: Text(unmuteFrom),
          ),
          widget.isAudience!
              ? const Text("")
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: color6),
                  onPressed: () {},
                  child: const Text("Ban"),
                ),
          widget.isAudience!
              ? const Text("")
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: color6),
                  onPressed: () {},
                  child: const Text("Kick"),
                ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color1),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget toolBar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProjectRawMaterialButton(
              type: ButtonType.mic, muted: muted, onPressed: handleMute),
          ProjectRawMaterialButton(type: ButtonType.close, onPressed: endCall),
        ],
      ),
    );
  }

  Widget listViewdeneme() {
    if (remoteUserIDs.isNotEmpty) {
      return GridView.builder(
          itemCount: users.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 23.8 / 30,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          itemBuilder: ((context, index) {
            return _remoteVideo();
          }));
    } else {
      try {
        return const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text(
                "You are alone in this room",
                style: TextStyle(fontSize: 24),
              ),
            ));
      } catch (e) {
        debugPrint("HATAAAAAAAAAA" + e.toString());
      }
    }
    return const Text("");
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        height: 360,
        child: Stack(children: [
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext ctxx) => _buildPopupDialog(ctxx),
                );
              },
              icon: const Icon(
                Icons.menu,
                size: 40,
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: remoteUsermuted
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 5, right: 5),
                      child: Container(
                        color: Colors.red.shade300,
                        child: const Icon(
                          Icons.mic_off_rounded,
                          size: 40,
                        ),
                      ),
                    )
                  : const Text("")),
        ]),
      );
    } else {
      return Container(
        height: 120,
        width: 120,
        color: Colors.pink,
        child: const Text(
          'Please wait for \n remote user to join',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}

class Constants {
  static const String muteAll = 'Mute All';
  static const String unmuteAll = 'Unmute All';

  static const List<String> choices = <String>[muteAll, unmuteAll];
}
