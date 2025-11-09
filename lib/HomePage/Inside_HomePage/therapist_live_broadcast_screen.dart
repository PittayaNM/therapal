import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/settings.dart';

class TherapistLiveBroadcastScreen extends StatefulWidget {
  final String streamId;
  final String streamTitle;

  const TherapistLiveBroadcastScreen({
    super.key,
    required this.streamId,
    required this.streamTitle,
  });

  @override
  State<TherapistLiveBroadcastScreen> createState() =>
      _TherapistLiveBroadcastScreenState();
}

class _TherapistLiveBroadcastScreenState
    extends State<TherapistLiveBroadcastScreen> {
  late RtcEngine _engine;
  bool _isInitialized = false;
  bool _micEnabled = true;
  bool _camEnabled = true;
  
  Timer? _durationTimer;
  int _secondsElapsed = 0;
  int _viewCount = 0;
  
  final _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startDurationTimer();
    _listenToViewCount();
    _listenToComments();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting);

    final channelId = 'live_${widget.streamId}';
    await _engine.joinChannel(
      token: token.isNotEmpty ? token : '',
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeVideo: false,
        autoSubscribeAudio: false,
      ),
    );

    setState(() => _isInitialized = true);
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _listenToViewCount() {
    FirebaseFirestore.instance
        .collection('liveStreams')
        .doc(widget.streamId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setState(() {
          _viewCount = (doc.data()?['viewCount'] as int?) ?? 0;
        });
      }
    });
  }

  void _listenToComments() {
    FirebaseFirestore.instance
        .collection('liveStreams')
        .doc(widget.streamId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _comments.clear();
        for (var doc in snapshot.docs) {
          _comments.add({...doc.data(), 'id': doc.id});
        }
      });
    });
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

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
  }

  Future<void> _endLive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Live Stream'),
        content: const Text('Are you sure you want to end this live stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Stream'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('liveStreams')
            .doc(widget.streamId)
            .update({
          'isLive': false,
          'endTime': FieldValue.serverTimestamp(),
        });

        // Leave Agora
        await _engine.leaveChannel();
        await _engine.release();
        _durationTimer?.cancel();

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error ending stream: $e')),
          );
        }
      }
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _commentController.dispose();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_isInitialized)
              Positioned.fill(
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                    useFlutterTexture: true,
                    useAndroidSurfaceView: true,
                  ),
                ),
              ),

            // Top bar with stats
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Live indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.fiber_manual_record,
                              size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('LIVE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Duration
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(_secondsElapsed),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    
                    // View count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _viewCount.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Comments section
            Positioned(
              bottom: 100,
              left: 12,
              right: 12,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  reverse: true,
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = _comments.length - 1 - index;
                    final comment = _comments[reversedIndex];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['userName'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            comment['text'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mic toggle
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: Icon(
                          _micEnabled ? Icons.mic : Icons.mic_off,
                          color: Colors.white,
                        ),
                        onPressed: _toggleMic,
                      ),
                    ),
                    
                    // Camera toggle
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: Icon(
                          _camEnabled ? Icons.videocam : Icons.videocam_off,
                          color: Colors.white,
                        ),
                        onPressed: _toggleCam,
                      ),
                    ),
                    
                    // Switch camera
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: const Icon(Icons.cameraswitch, color: Colors.white),
                        onPressed: _switchCamera,
                      ),
                    ),
                    
                    // End stream
                    ElevatedButton.icon(
                      onPressed: _endLive,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.stop, size: 20),
                      label: const Text('End Live'),
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
