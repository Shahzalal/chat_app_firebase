import 'package:flutter/material.dart';
import '../config/size_config.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;

  const ChatInput({super.key, required this.onSendMessage});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    widget.onSendMessage(_messageController.text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.ws(16),
        vertical: SizeConfig.hs(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.ws(16)),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(SizeConfig.ws(24)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: SizeConfig.fs(14),
                    color: Colors.grey.shade600,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.ws(12)),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0084FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: SizeConfig.fs(20),
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
