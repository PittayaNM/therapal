import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../utils/settings.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final String? token;

  const CallScreen({super.key, required this.channelId, this.token});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RtcEngine _engine = createAgoraRtcEngine();
  bool _joined = false;
  final Set<int> _remoteUids = <int>{};
  bool _micEnabled = true;
  bool _camEnabled = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1) Ask permissions
    await [Permission.microphone, Permission.camera].request();

    // 2) Init engine
    await _engine.initialize(RtcEngineContext(appId: appId));

    // 3) Register event handlers
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _joined = true;
          _error = null;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() => _remoteUids.add(remoteUid));
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        setState(() => _remoteUids.remove(remoteUid));
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        setState(() {
          _joined = false;
          _remoteUids.clear();
        });
      },
      onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
        if (state == ConnectionStateType.connectionStateFailed) {
          setState(() => _error = 'Connection failed: reason=$reason');
        }
      },
      onError: (ErrorCodeType err, String msg) {
        setState(() => _error = 'Agora error: $err $msg');
      },
    ));

    await _engine.enableVideo();
    await _engine.startPreview();

    // 4) Join channel
    final String effectiveToken = (widget.token != null && widget.token!.isNotEmpty)
        ? widget.token!
        : (token.isNotEmpty ? token : '');

    await _engine.joinChannel(
      token: effectiveToken,
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  @override
  void dispose() {
    _leave();
    super.dispose();
  }

  Future<void> _leave() async {
    try {
      await _engine.leaveChannel();
    } finally {
      await _engine.release();
    }
  }

  Future<void> _toggleMic() async {
    _micEnabled = !_micEnabled;
    await _engine.enableLocalAudio(_micEnabled);
    setState(() {});
  }

  Future<void> _toggleCam() async {
    _camEnabled = !_camEnabled;
    await _engine.enableLocalVideo(_camEnabled);
    setState(() {});
  }

  Widget _buildVideoViews() {
    final tiles = <Widget>[];

    // Local preview
    tiles.add(Container(
      color: Colors.black,
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
          useFlutterTexture: true,
          useAndroidSurfaceView: true,
        ),
      ),
    ));

    // Remote users
    for (final uid in _remoteUids) {
      tiles.add(Container(
        color: Colors.black,
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: uid),
            connection: RtcConnection(channelId: widget.channelId),
            useFlutterTexture: true,
            useAndroidSurfaceView: true,
          ),
        ),
      ));
    }

    if (tiles.length == 1) {
      return tiles.first;
    }
    return GridView.count(
      crossAxisCount: 2,
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildVideoViews(),
            ),
            if (!_joined)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        _error == null ? 'Connecting…' : '$_error',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            // Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(_micEnabled ? Icons.mic : Icons.mic_off, color: Colors.white),
                        onPressed: _toggleMic,
                      ),
                    ),
                    const SizedBox(width: 20),
                    CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: IconButton(
                        icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                        onPressed: () async {
                          await _leave();
                          if (mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(_camEnabled ? Icons.videocam : Icons.videocam_off, color: Colors.white),
                        onPressed: _toggleCam,
                      ),
                    ),
                    const SizedBox(width: 20),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.cameraswitch, color: Colors.white),
                        onPressed: () async {
                          await _engine.switchCamera();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
