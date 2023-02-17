import 'package:chat_gpt/features/chat/chat_sonic_messaging.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: chatMessageType == ChatMessageType.bot
          ? const EdgeInsets.fromLTRB(16.0, 16.0, 32.0, 0)
          : const EdgeInsets.fromLTRB(32.0, 16.0, 16.0, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: chatMessageType == ChatMessageType.bot
              ? Colors.white
              : const Color(0xFFF8FBFF)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: chatMessageType == ChatMessageType.bot
                      ? const AlignmentDirectional(-1, 0)
                      : const AlignmentDirectional(1, 0),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                            color: Color(0xFF0D2F74),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            height: 1.37),
                      ),
                    ),
                    Container(
                        width: 14,
                        height: 14,
                        color: chatMessageType == ChatMessageType.bot
                            ? Colors.white
                            : const Color(0xFFF8FBFF),
                        transform: chatMessageType == ChatMessageType.bot
                            ? Matrix4.translationValues(-8, -4, 0)
                            : Matrix4.translationValues(22, -4, 0)
                          ..rotateZ(3.14 / 4))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
