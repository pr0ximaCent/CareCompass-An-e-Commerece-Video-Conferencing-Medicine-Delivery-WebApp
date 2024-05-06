// Flutter imports:
import 'dart:convert';

import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/providers/socket_provider.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatefulWidget {
  static const String routeName = "/video_call_screen";
  final String callID;

  const VideoCallPage({Key? key, required this.callID}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VideoCallPageState();
}

class VideoCallPageState extends State<VideoCallPage> {
  @override
  void initState() {
    super.initState();
    // print(widget.callID);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (event, defaultAction) {
            final data = {
              'chatId':
                  widget.callID, // Replace with the actual receiver's user ID
              'startConsultationRequest': false,
              'authToken': Provider.of<UserProvider>(context, listen: false)
                  .user
                  .token, // Replace with the actual authentication token
            };
            Provider.of<SocketIOProvider>(context, listen: false)
                .getSocket()
                .emit('set_video_call_request', data);
            // print("call end");
            // print(event);
            defaultAction();
          },
        ),
        onDispose: () {},
        appID: 299445426,
        appSign:
            "bdf09171e088264c85c6c3d52d8308ab014dfb73304c5b8964ae48fe35edc83d",
        userID: Provider.of<UserProvider>(context, listen: false).user.id,
        userName: Provider.of<UserProvider>(context, listen: false).user.name,
        callID: widget.callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          // ..bottomMenuBarConfig.buttons = [
          //   ZegoMenuBarButtonName.toggleCameraButton,
          //   ZegoMenuBarButtonName.switchCameraButton,
          //   ZegoMenuBarButtonName.toggleMicrophoneButton,
          //   ZegoMenuBarButtonName.toggleScreenSharingButton,
          // ]

          /// support minimizing
          ..topMenuBarConfig.isVisible = true
          ..topMenuBarConfig.buttons = [
            ZegoMenuBarButtonName.minimizingButton,
            ZegoMenuBarButtonName.showMemberListButton,
          ]
          ..avatarBuilder = customAvatarBuilder,
      ),
    );
  }
}

Widget customAvatarBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  return CachedNetworkImage(
    imageUrl: 'https://robohash.org/${user?.id}.png',
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        CircularProgressIndicator(value: downloadProgress.progress),
    errorWidget: (context, url, error) {
      ZegoLoggerService.logInfo(
        '$user avatar url is invalid',
        tag: 'live audio',
        subTag: 'live page',
      );
      return ZegoAvatar(user: user, avatarSize: size);
    },
  );
}
