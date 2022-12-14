import 'dart:math';

import 'package:appchat/utils/timePassed.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class ChatBubble extends StatefulWidget {
  final String message, time, type, messageId, chatItemId;
  final bool isMe, isReply;

  const ChatBubble({
    required this.message,
    required this.messageId,
    required this.chatItemId,
    required this.time,
    required this.isMe,
    // required this.isGroup,
    // required this.username,
    required this.type,
    // required this.replyText,
    required this.isReply,
    // required this.replyName,
    super.key,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  List colors = Colors.primaries;
  static Random random = Random();
  int rNum = random.nextInt(18);

  Widget buildTimePassed() {
    DateTime tempDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(widget.time);
    // int timePassed =
    return Text(
      timePassed(tempDate),
      style: TextStyle(
        color: Theme.of(context).textTheme.headline6?.color,
        fontSize: 10.0,
      ),
    );
  }

  Color chatBubbleColor() {
    if (widget.isMe) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      if (Theme.of(context).brightness == Brightness.dark) {
        return const Color.fromARGB(255, 66, 66, 66);
      } else {
        return const Color.fromARGB(255, 238, 238, 238);
      }
    }
  }

  Color chatBubbleReplyColor() {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const Color.fromARGB(255, 126, 126, 126);
    } else {
      return const Color.fromARGB(255, 255, 255, 255);
    }
  }

  @override
  Widget build(BuildContext context) {
    final align =
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = widget.isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        GestureDetector(
          onLongPress: () {
            _bottomPopUp();
          },
          child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: chatBubbleColor(),
              borderRadius: radius,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.3,
              minWidth: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 2.0),
                widget.isReply ? const SizedBox(height: 5) : SizedBox(),
                Padding(
                  padding: EdgeInsets.all(widget.type == "text" ? 5 : 0),
                  child: widget.type == "text"
                      ? !widget.isReply
                          ? Text(
                              widget.message,
                              style: TextStyle(
                                color: widget.isMe
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.color,
                              ),
                            )
                          : Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.message,
                                style: TextStyle(
                                  color: widget.isMe
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.color,
                                ),
                              ),
                            )
                      : Image.asset(
                          "${widget.message}",
                          height: 130,
                          width: MediaQuery.of(context).size.width / 1.3,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: widget.isMe
              ? const EdgeInsets.only(right: 10, bottom: 10.0)
              : const EdgeInsets.only(left: 10, bottom: 10.0),
          child: buildTimePassed(),
        ),
      ],
    );
  }

  void _bottomPopUp() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * .15,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 30,
                left: 0,
                right: 0,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      child: Column(children: const [
                        Icon(Icons.arrow_back),
                        Text("Reply"),
                      ]),
                      onPressed: () {},
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      child: Column(children: const [
                        Icon(Icons.copy),
                        Text("Copy"),
                      ]),
                      onPressed: () {},
                    ),
                  ),
                  if (widget.isMe == true)
                    Expanded(
                      child: TextButton(
                        child: Column(children: const [
                          Icon(Icons.delete_outlined),
                          Text("Delete"),
                        ]),
                        onPressed: () {
                          if (widget.isMe) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Are you sure remove?'),
                                content: Text('"${widget.message}"'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('No'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () {
                                      FirebaseDatabase.instance
                                          .ref(
                                              "chatMessages/${widget.chatItemId}/${widget.messageId}")
                                          .remove();
                                      Navigator.of(ctx).pop(true);
                                      Navigator.of(ctx).pop(true);
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  Expanded(
                    child: TextButton(
                      child: Column(children: const [
                        Icon(Icons.arrow_forward),
                        Text("Foward"),
                      ]),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
