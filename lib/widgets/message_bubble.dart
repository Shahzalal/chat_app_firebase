import 'package:flutter/material.dart';
import '../config/size_config.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: SizeConfig.hs(4),
        horizontal: SizeConfig.ws(8),
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: const Color(0xFF0084FF),
              radius: SizeConfig.ws(16),
              child: Text(
                message['senderEmail']
                        ?.toString()
                        .substring(0, 1)
                        .toUpperCase() ??
                    'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.fs(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: SizeConfig.ws(8)),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.ws(16),
                vertical: SizeConfig.hs(10),
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF0084FF) : Colors.white,
                borderRadius: BorderRadius.circular(SizeConfig.ws(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message['senderEmail'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0084FF),
                        fontSize: SizeConfig.fs(12),
                      ),
                    ),
                  if (!isMe) SizedBox(height: SizeConfig.hs(4)),
                  Text(
                    message['text'] ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: SizeConfig.fs(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: SizeConfig.ws(8)),
          if (isMe)
            CircleAvatar(
              backgroundColor: const Color(0xFF0084FF),
              radius: SizeConfig.ws(16),
              child: Text(
                'Me',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.fs(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
