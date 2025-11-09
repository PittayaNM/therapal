import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../utils/settings.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final String? token;
  final bool isLocalTherapist;

  const CallScreen({
    super.key,
    required this.channelId,
    this.token,
    this.isLocalTherapist = false,
  });

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
  int? _pinnedUid; // null = no pin; 0 = local; >0 = remote uid

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await [Permission.microphone, Permission.camera].request();
    await _engine.initialize(RtcEngineContext(appId: appId));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _joined = true;
          _error = null;
        });
      },
      onUserJoined: (RtcConnection conn, int remoteUid, int elapsed) {
        setState(() => _remoteUids.add(remoteUid));
      },
      onUserOffline: (RtcConnection conn, int remoteUid, UserOfflineReasonType reason) {
        setState(() {
          _remoteUids.remove(remoteUid);
          if (_pinnedUid == remoteUid) _pinnedUid = null;
        });
      },
      onLeaveChannel: (RtcConnection conn, RtcStats stats) {
        setState(() {
          _joined = false;
          _remoteUids.clear();
          _pinnedUid = null;
        });
      },
      onConnectionStateChanged: (RtcConnection conn, ConnectionStateType state, ConnectionChangedReasonType reason) {
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

  Widget _buildVideoTile(int uid, {bool rounded = false}) {
    final isLocal = uid == 0;
    // Determine which tile should show the therapist badge for ALL participants.
    // - If this client is the therapist, mark the local tile (uid==0).
    // - If this client is a patient and there is exactly one remote, mark that remote tile.
    //   For multi-party calls, we can't reliably identify the therapist without name mapping,
    //   so we skip the badge when multiple remotes are present.
    bool isTherapist;
    if (widget.isLocalTherapist) {
      isTherapist = isLocal;
    } else {
      final therapistRemoteUid = _remoteUids.length == 1 ? _remoteUids.first : null;
      isTherapist = (!isLocal && therapistRemoteUid != null && uid == therapistRemoteUid);
    }

    final view = Container(
      color: Colors.black,
      child: isLocal
          ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
                useFlutterTexture: true,
                useAndroidSurfaceView: true,
              ),
            )
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: widget.channelId),
                useFlutterTexture: true,
                useAndroidSurfaceView: true,
              ),
            ),
    );

    final baseView = rounded
        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: view)
        : view;

    if (!isTherapist) return baseView;

    return Stack(
      children: [
        Positioned.fill(child: baseView),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF27C07D).withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_services, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Therapist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<int> _allUids() => [0, ..._remoteUids];

  Widget _buildGrid() {
    final uids = _allUids();
    if (uids.length == 1) {
      final sole = uids.first;
      return GestureDetector(
        onTap: () => setState(() => _pinnedUid = sole),
        child: _buildVideoTile(sole),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      children: [
        for (final uid in uids)
          GestureDetector(
            onTap: () => setState(() => _pinnedUid = uid),
            child: Stack(
              children: [
                Positioned.fill(child: _buildVideoTile(uid)),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.push_pin, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPinnedLayout() {
    final pinned = _pinnedUid!;
    final others = _allUids().where((u) => u != _pinnedUid).toList(growable: false);
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Positioned.fill(child: _buildVideoTile(pinned)),
              Positioned(
                top: 12,
                left: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _pinnedUid = null),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white38, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.push_pin_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text('Unpin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (others.isNotEmpty)
          Container(
            height: 140,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final uid = others[index];
                return GestureDetector(
                  onTap: () => setState(() => _pinnedUid = uid),
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white38, width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: _buildVideoTile(uid, rounded: true)),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.push_pin_outlined, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: others.length,
            ),
          ),
      ],
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
              child: _pinnedUid == null ? _buildGrid() : _buildPinnedLayout(),
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
            ),
          ],
        ),
      ),
    );
  }
}
