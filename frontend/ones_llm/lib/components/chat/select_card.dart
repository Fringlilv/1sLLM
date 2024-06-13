import 'package:flutter/material.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:ones_llm/services/api.dart';
import 'package:ones_llm/controller/user.dart';
import 'package:ones_llm/components/markdown.dart';
class SelectCard extends StatefulWidget {
  final List<Message> selectList;
  final void Function(Message) onSelect;
  const SelectCard({super.key, required this.selectList, required this.onSelect});

  @override
  SelectCardState createState() => SelectCardState();
}

class SelectCardState extends State<SelectCard> {
  int currentIndex = 0;

  PageController pageController = PageController(initialPage: 0);

  void nextPage() {
    if (currentIndex < widget.selectList.length - 1) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
      setState(() {
        currentIndex++;
      });
    }
  }

  void previousPage() {
    if (currentIndex > 0) {
      pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () => previousPage(),
            ),
            Text(
              "${widget.selectList[currentIndex].role} ${currentIndex + 1}/${widget.selectList.length}",
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: ()=>widget.onSelect(widget.selectList[currentIndex]),
              child: Text('selectResponse'.tr),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () => nextPage(),
            ),
          ],
        ),
        ExpandablePageView(
          controller: pageController,
          children: widget.selectList.map((msg) {
            return Card(
              // color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
              elevation: 3,
              child:Markdown(text: msg.text)
            );
          }).toList(),
        ),
        
      ],
    );
  }
}