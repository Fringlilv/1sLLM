import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:ones_llm/services/api.dart';
import 'package:ones_llm/components/chat/markdown.dart';
import 'package:ones_llm/services/local.dart';

class MessageCard extends StatelessWidget {
  final Message message;
const MessageCard({ super.key, required this.message});

  @override
  Widget build(BuildContext context){
    final userName = Get.find<LocalService>().userName;
    if (message.role == userName) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const FaIcon(FontAwesomeIcons.person),
              const SizedBox(
                width: 5,
              ),
              Text(userName),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 16,
                        ),
                        message.text,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              const FaIcon(FontAwesomeIcons.robot),
              const SizedBox(
                width: 5,
              ),
              Text(message.role),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Expanded(
              //   child: Card(
              //     elevation: 8,
              //     margin: const EdgeInsets.all(8),
              //     child: Markdown(text: message.text),
              //   ),
              // ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    elevation: 8,
                    child: Markdown(text: message.text),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
