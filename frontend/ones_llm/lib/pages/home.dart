import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ones_llm/components/chat.dart';
import 'package:ones_llm/components/conversation.dart';

class MyHomePage extends GetResponsiveView {
  @override
  Widget? phone() {
    print('phone');
    return Scaffold(
      appBar: AppBar(
        title: Text('appTitle'.tr),
      ),
      drawer: const ConversationWindow(),
      body: const ChatWindow(),
    );
  }

  @override
  Widget? desktop() {
    print('desktop');
    return const Scaffold(
      body: Row(
        children: [
          ConversationWindow(),
          Expanded(child: ChatWindow()),
        ],
      ),
    );
  }
}