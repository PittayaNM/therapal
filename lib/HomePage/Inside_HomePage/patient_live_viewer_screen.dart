import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/settings.dart';

class PatientLiveViewerScreen extends StatefulWidget {
  final String streamId;
  final String streamTitle;

  const PatientLiveViewerScreen({
    super.key,
    required this.streamId,
    required this.streamTitle,
  });

  @override
  State<PatientLiveViewerScreen> createState() =>
      _PatientLiveViewerScreenState();
}

class _PatientLiveViewerScreenState extends State<PatientLiveViewerScreen> {
  late RtcEngine _engine;
  bool _isInitialized = false;
  int _remoteUid = 0;
  
  int _viewCount = 0;
  Timestamp? _startTime;
  
  final _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _incrementViewCount();
    _listenToStream();
    _listenToComments();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    
    // Enable video to receive video stream
    await _engine.enableVideo();
    
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() => _isInitialized = true);
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() => _remoteUid = remoteUid);
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        setState(() => _remoteUid = 0);
      },
    ));

    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting);

    final channelId = 'live_${widget.streamId}';
    await _engine.joinChannel(
      token: token.isNotEmpty ? token : '',
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      ),
    );
  }

  Future<void> _incrementViewCount() async {
    await FirebaseFirestore.instance
        .collection('liveStreams')
        .doc(widget.streamId)
        .update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Future<void> _decrementViewCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('liveStreams')
          .doc(widget.streamId)
          .update({
        'viewCount': FieldValue.increment(-1),
      });
    } catch (e) {
      // Silently fail if document doesn't exist
    }
  }

  void _listenToStream() {
    _streamSubscription = FirebaseFirestore.instance
        .collection('liveStreams')
        .doc(widget.streamId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists || doc.data()?['isLive'] == false) {
        // Stream ended
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live stream has ended')),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _viewCount = (doc.data()?['viewCount'] as int?) ?? 0;
          _startTime = doc.data()?['startTime'] as Timestamp?;
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

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      final userName = userDoc.data()?['name'] as String? ?? 'Unknown';

      await FirebaseFirestore.instance
          .collection('liveStreams')
          .doc(widget.streamId)
          .collection('comments')
          .add({
        'userId': uid,
        'userName': userName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending comment: $e')),
        );
      }
    }
  }

  String _formatDuration() {
    if (_startTime == null) return '00:00';
    
    final start = _startTime!.toDate();
    final now = DateTime.now();
    final diff = now.difference(start);
    
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final secs = diff.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _commentController.dispose();
    _decrementViewCount();
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
            // Video view
            if (_isInitialized && _remoteUid != 0)
              Positioned.fill(
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: 'live_${widget.streamId}'),
                    useFlutterTexture: true,
                    useAndroidSurfaceView: true,
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),

            // Top bar
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    
                    // LIVE badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                        _formatDuration(),
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
              bottom: 80,
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

            // Comment input
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
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF00B2E3),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendComment,
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
