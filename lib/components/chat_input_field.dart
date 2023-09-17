import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../../chat_encrypter/chat_encrypter_service.dart';
import '../../provider/provider_manager.dart';
import '../../api/message_api.dart';
import '../../utils/basic_user_info.dart';
import '../../utils/media_type.dart';
import '../../utils/message.dart';
import '../api/media_api.dart';
import '../utils/user.dart';
import 'container.dart';

import 'package:image_picker/image_picker.dart';

class ChatInputField extends StatefulWidget {
  final bool loading;
  final bool isChatDead;
  final bool isPrivate;
  final String chatId;
  final BasicUserInfo recipient;
  final void Function(Message message) addMessage;

  const ChatInputField({
    super.key,
    required this.loading,
    required this.isChatDead,
    required this.isPrivate,
    required this.chatId,
    required this.recipient,
    required this.addMessage,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late User user;
  final MessageApi _messageApi = MessageApi();
  final MediaApi _mediaApi = MediaApi();
  final TextEditingController _textEditingController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  bool micPermission = false;
  File? image;
  File? video;
  Timer? _timer;
  bool _isTyping = false;
  late String _filePath;

  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  bool _isRecording = false;

  @override
  void initState() {
    user = ProviderManager().getUser(context);
    if (!widget.isPrivate) {
      _textEditingController.addListener(() {
        if (_textEditingController.text.isNotEmpty && !_isTyping) {
          MessageApi().setTypingStatus(
            chatId: widget.chatId,
            email: user.email,
            isTyping: true,
          );
          setState(() => _isTyping = true);
        } else if (_textEditingController.text.isEmpty && _isTyping) {
          MessageApi().setTypingStatus(
            chatId: widget.chatId,
            email: user.email,
            isTyping: false,
          );
          setState(() => _isTyping = false);
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _textEditingController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (image != null) _displayPickedImage,
        Padding(
          padding: const EdgeInsets.fromLTRB(27, 5, 27, 20),
          child: RoundedGradientContainer(
            gradient:
                const LinearGradient(colors: [Colors.black, Colors.black]),
            borderSize: 2,
            child: Row(
              children: <Widget>[
                widget.isPrivate
                    ? const SizedBox(
                        width: 20,
                      )
                    : _popupMenu,
                _textInputField,
                widget.isPrivate ? const SizedBox.shrink() : _recordButton,
                _sendMessageButton,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget get _sendMessageButton {
    return IconButton(
      icon: const Icon(Icons.send),
      onPressed: widget.loading || widget.isChatDead
          ? null
          : () {
              sendMessage();
            },
    );
  }

  Widget get _recordButton {
    return GestureDetector(
      onLongPressStart: widget.loading || widget.isChatDead
          ? null
          : (details) {
              _startRecording();
            },
      onLongPressEnd: widget.loading || widget.isChatDead
          ? null
          : (details) {
              _stopRecording();
            },
      child: Icon(_isRecording ? Icons.stop : Icons.mic),
    );
  }

  Widget get _textInputField {
    return Expanded(
      child: TextField(
        enabled: !widget.loading && !widget.isChatDead,
        controller: _textEditingController,
        decoration: InputDecoration(
          hintText: _isRecording
              ? "Recording..."
              : video != null
                  ? 'Video uploaded!'
                  : 'Enter your message here...',
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  Widget get _displayPickedImage {
    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(image!),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget get _popupMenu {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () => _pickImage(),
          child: const Text('Photo'),
        ),
        PopupMenuItem(
          onTap: () => _pickVideo(),
          child: const Text('Video'),
        ),
      ],
    );
  }

  void sendMessage() {
    if (_textEditingController.text != "") {
      String text = _textEditingController.text;
      widget.addMessage(Message(
        sender: user.email,
        body: text,
        type: MediaType.text.str,
        date: Timestamp.now(),
        seen: false,
        setState: (_) {},
        isPrivate: false,
      ));

      if (widget.isPrivate) {
        text = ChatEncrypterService().encrypt(
          text: text,
          publicKey: ChatEncrypterService().stringToRSAKey(
            widget.recipient.key,
            isPrivate: false,
          ),
          privateKey: user.key,
        );
      }
      _messageApi.sendMessage(
        widget.chatId,
        sender: user.email,
        body: text,
        type: MediaType.text,
        date: Timestamp.now(),
      );
    }
    if (!widget.isPrivate) checkMedia(image, MediaType.image);
    if (!widget.isPrivate) checkMedia(video, MediaType.video);

    setState(() {
      _textEditingController.text = "";
      image = null;
      video = null;
    });
  }

  void checkMedia(File? media, MediaType type) {
    if (media != null) {
      String link = _mediaApi.toPath(user.email, file: media, type: type);
      _mediaApi.uploadFile(
        link,
        file: media,
        type: type,
        onComplete: ({required String fileLink, required String msg}) {
          debugPrint("$media uploaded! $msg");
          _messageApi.sendMessage(
            widget.chatId,
            sender: user.email,
            body: fileLink,
            type: type,
            date: Timestamp.now(),
          );
        },
        onUpdate: (msg, [progress]) => debugPrint(progress.toString()),
        onError: (msg) {
          throw Exception("$media UPLOAD ERROR: $msg");
        },
      );
    }
  }

  void _pickImage() async {
    var newImage = await picker.pickImage(source: ImageSource.gallery);

    if (newImage != null) {
      debugPrint("New Image Picked: ${newImage.path}");
      setState(() => image = File(newImage.path));
    }
  }

  void _pickVideo() async {
    var newVideo = await picker.pickVideo(source: ImageSource.gallery);

    if (newVideo != null) {
      debugPrint("New Video Picked: ${newVideo.path}");
      setState(() => video = File(newVideo.path));
    }
  }

  Future<void> _startRecording() async {
    debugPrint("Start recording");

    try {
      if (micPermission) {
        debugPrint("Microphone permission granted");

        setState(() => _isRecording = true);

        final directory = await getTemporaryDirectory();
        _filePath = '${directory.path}/audio.mp3';
        await _audioRecorder.start(path: _filePath);
      } else {
        debugPrint("No permission to access microphone");
        micPermission = await _audioRecorder.hasPermission();

        setState(() {
          _isRecording = false;
          micPermission = micPermission;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      debugPrint("Stop recording");
      uploadAudio();
      setState(() {
        _filePath = '';
        _isRecording = false;
      });
      await _audioRecorder.stop();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }

  void uploadAudio() {
    if (_filePath != "") {
      String link = _mediaApi.toPath(user.email,
          file: File(_filePath), type: MediaType.audio);
      _mediaApi.uploadFile(
        link,
        file: File(_filePath),
        type: MediaType.audio,
        onComplete: ({required String fileLink, required String msg}) {
          debugPrint("Audio uploaded! $msg");
          _messageApi.sendMessage(
            widget.chatId,
            sender: user.email,
            body: fileLink,
            type: MediaType.audio,
            date: Timestamp.now(),
          );
        },
        onUpdate: (msg, [progress]) => debugPrint(progress.toString()),
        onError: (msg) {
          throw Exception("Audio UPLOAD ERROR: $msg");
        },
      );
    }
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
