import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteragoradenemecem/pages/loginPage.dart';
import 'package:flutteragoradenemecem/src/buttonapp.dart';
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
  final infoStrings = <String>[];
  List<String> usernames = [];

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
    usernames.clear();
    _localUserJoined = false;
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    // _addAgoraEventHandler();
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
            usernames.add(connection.localUid.toString());
            users.add(connection.localUid!);
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
            usernames.add(_remoteUid.toString());
            users.add(_remoteUid!);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
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

  List<String> forloopfunc() {
    for (var i = 0; i <= users.length; i++) {
      usernames.add(users[i].toString());
    }
    return usernames;
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
                  debugPrint("Usernames empty mi: ${usernames.isEmpty} ");
                  debugPrint("Remote ID: $_remoteUid");
                  debugPrint("Users emtpy mi: ${users.isEmpty}");
                  debugPrint("Local User Joined: $_localUserJoined");
                  debugPrint("Channel Name: ${widget.channelName}");
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

  // Display remote user's video
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
                int remoteuid = _remoteUid!;
                _engine.muteRemoteAudioStream(uid: remoteuid, mute: true);
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
                int remoteuid = _remoteUid!;
                _engine.muteRemoteAudioStream(uid: remoteuid, mute: false);
                Navigator.of(context).pop();
                remoteUsermuted = false;
              });
            },
            child: Text(unmuteFrom),
          ),
          widget.isAudience!
              ? Text("")
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: color6),
                  onPressed: () {},
                  child: const Text("Ban"),
                ),
          widget.isAudience!
              ? Text("")
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

  Widget listViewdeneme() {
    if (users.isNotEmpty) {
      return ListView.builder(
          itemCount: users.length - 1,
          itemBuilder: ((context, index) {
            if (users.isEmpty) {
              return Center(
                  child: Container(
                      height: 250,
                      width: 250,
                      color: Colors.cyan,
                      child: const Text('null')));
            } else {
              return Row(
                children: [
                  _remoteVideo(),
                ],
              );
            }
          }));
    } else {
      return ListView.builder(
          itemCount: users.length,
          itemBuilder: ((context, index) {
            if (users.isEmpty) {
              return Center(
                  child: Container(
                      height: 250,
                      width: 250,
                      color: Colors.cyan,
                      child: const Text('null')));
            } else {
              return Row(
                children: [
                  _remoteVideo(),
                ],
              );
            }
          }));
    }
  }

  /* 
  return FutureBuilder(
        future: initAgora(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: users.length - 1,
                itemBuilder: ((context, index) {
                  if (users.isEmpty) {
                    return Center(
                        child: Container(
                            height: 250,
                            width: 250,
                            color: Colors.cyan,
                            child: const Text('null')));
                  } else {
                    return Row(
                      children: [
                        _remoteVideo(),
                      ],
                    );
                  }
                }));
          } else {
            return Center(
                child: Container(
                    height: 250,
                    width: 250,
                    color: Colors.cyan,
                    child: const Text('null')));
          }
        });
  */
/* 
ListView.builder(
        itemCount: users.length - 1,
        itemBuilder: ((context, index) {
          if (users.isEmpty) {
            return Center(
                child: Container(
                    height: 250,
                    width: 250,
                    color: Colors.cyan,
                    child: const Text('null')));
          } else {
            return Row(
              children: [
                _remoteVideo(),
              ],
            );
          }
        }));
*/

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 130 / 300,
        height: 240,
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

  Widget stackView() {
    return Stack(
      children: [
        Center(
          child: _remoteVideo(),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 150,
            height: 200,
            child: Center(
              child: _localUserJoined
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

class Constants {
  static const String muteAll = 'Mute All';
  static const String unmuteAll = 'Unmute All';

  static const List<String> choices = <String>[muteAll, unmuteAll];
}
