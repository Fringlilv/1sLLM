import 'package:flutter/material.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:get/get.dart';

import 'package:ones_llm/services/api.dart';
import 'package:ones_llm/components/chat/markdown.dart';
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
        
        ExpandablePageView.builder(
          controller: pageController,
          itemCount: widget.selectList.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () => previousPage(),
            ),
                Expanded(child: 
                Card(
              // color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
              elevation: 3,
              child:Markdown(text: widget.selectList[index].text)
            ),),
                IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () => nextPage(),
            ),
              ],
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "${widget.selectList[currentIndex].role} ${currentIndex + 1}/${widget.selectList.length}",
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: ()=>widget.onSelect(widget.selectList[currentIndex]),
              child: Text('selectResponse'.tr),
            ),
          ],
        ),
        // Container(
        //   alignment: Alignment.center,
        //     child: 
        // ),
      ],
    );
  }
  
// @override
//   Widget build(BuildContext context) {
//     return 
        
//         ExpandablePageView.builder(
//           controller: pageController,
//           itemCount: widget.selectList.length,
//           itemBuilder: (context, index) {
//             return Column(
//       children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//               icon: Icon(Icons.arrow_left),
//               onPressed: () => previousPage(),
//             ),
//                 Expanded(child: 
//                 Card(
//               // color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
//               elevation: 3,
//               child:Markdown(text: widget.selectList[index].text)
//             ),),
//                 IconButton(
//               icon: Icon(Icons.arrow_right),
//               onPressed: () => nextPage(),
//             ),
//               ],
//             ),
//             Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             Text(
//               "${widget.selectList[index].role} ${index + 1}/${widget.selectList.length}",
//               style: TextStyle(fontSize: 16),
//             ),
//             ElevatedButton(
//               onPressed: ()=>widget.onSelect(widget.selectList[index]),
//               child: Text('selectResponse'.tr),
//             ),
          
//           ],
//         ),],);
//           },
//         );
        
//         // Container(
//         //   alignment: Alignment.center,
//         //     child: 
//         // ),
//   }

}