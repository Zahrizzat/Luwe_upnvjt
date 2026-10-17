import 'package:flutter/material.dart';
import '../../providers/app_state.dart';
import '../common/direct_message_screen.dart';

/// Legacy export wrapper forwarding to DirectMessageScreen
class ChatScreen extends StatelessWidget {
  final AppState state;

  const ChatScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return DirectMessageScreen(state: state);
  }
}
