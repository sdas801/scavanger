import 'package:flutter/material.dart';
import 'package:scavenger_app/pages/deleteAccount/deleteAccountSecondPage.dart';
import 'package:scavenger_app/services/api.service.dart';

class feedbackQuestion {
  String quid;
  String qestion;

  feedbackQuestion({
    required this.quid,
    required this.qestion,
  });

  factory feedbackQuestion.fromJson(Map<String, dynamic> json) =>
      feedbackQuestion(
        quid: json["quid"],
        qestion: json["qestion"],
      );

  Map<String, dynamic> toJson() => {
        "quid": quid,
        "qestion": qestion,
      };
}

class DeleteAccountFirstPage extends StatefulWidget {
  const DeleteAccountFirstPage({Key? key}) : super(key: key);

  @override
  _DeleteAccountFirstPageState createState() => _DeleteAccountFirstPageState();
}

class _DeleteAccountFirstPageState extends State<DeleteAccountFirstPage> {
  final TextEditingController _feedbackController = TextEditingController();
  // String? _selectedReason;
  // final List<Map<String, String>> options = [
  //   {"label": "Something was broken", "value": "broken"},
  //   {"label": "I'm not getting any invites", "value": "no_invites"},
  //   {"label": "I have a privacy concern", "value": "privacy"},
  //   {"label": "Other", "value": "other"},
  // ];
  // List<feedbackQuestion> questionList = [];

  @override
  void dispose() {
    // deleteAccountQuestion();
    // _feedbackController.dispose();
    super.dispose();
  }

  // Future<void> deleteAccountQuestion() async {
  //   print(">>>>");
  //   ApiService.parchesedHistoryList({}).then((res) {
  //     try {
  //       if (res.success) {
  //         var questionlist = List<feedbackQuestion>.from(
  //             res.response.map((x) => feedbackQuestion.fromJson(x)));
  //         setState(() {
  //           questionList = questionlist;
  //         });

  //         // if (jsonResponseData.items.isNotEmpty) {
  //         //   // items1 = jsonResponseData.items;
  //         //   // print(">>>>>>>>>>>>>>>${items1}");
  //         // }
  //       } else {}
  //     } catch (e) {}
  //   });
  //   // print(">>>>111$items1");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: const Text(
        //   'Delete Account',
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontWeight: FontWeight.bold,
        //     fontSize: 20,
        //   ),
        // ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 5),
              // const Text(
              //   "Reason:-",
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              // ),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: questionList.map((question) {
              //     return RadioListTile<String>(
              //       title: Text(question.qestion),
              //       value: question.quid,
              //       groupValue: _selectedReason,
              //       onChanged: (value) {
              //         setState(() {
              //           _selectedReason = value;
              //         });
              //       },
              //     );
              //   }).toList(),
              // ),
              const SizedBox(height: 10),
              const Text(
                'Can you please share with us what was not working? We are fixing bugs as soon as we spot them. If something slipped through our fingers, we\'d be so grateful to be aware of it and fix it.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _feedbackController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Your explanation is entirely ...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_feedbackController.text == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please enter the reason for our improvment"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeleteProfileConfirmationScreen(
                              reason: _feedbackController.text),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
