import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scavenger_app/CreateHuntPictureForm.dart';
import 'package:scavenger_app/HuntTimeResponse.dart';
import 'package:scavenger_app/ManualAddItemResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:scavenger_app/constants.dart';
import 'package:scavenger_app/custom_textfield.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';

class ChallengeTimeSet extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const ChallengeTimeSet(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _ChallengeTimeSetState createState() => _ChallengeTimeSetState();
}

class _ChallengeTimeSetState extends State<ChallengeTimeSet> {
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  DateTime? _selectedDate2;
  TimeOfDay? _selectedTime2;

  // Function to show Date Picker first, then Time Picker
  Future<void> _selectDateAndTime(BuildContext context) async {
    // Show Date Picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });

      // After selecting the date, show Time Picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input,
      );

      if (pickedTime != null) {
        setState(() {
          _selectedTime = pickedTime;
        });
      }
    }
  }

  bool _isLoading = false;

  String formattedStartDateString = "";
  String formattedEndDateString = "";
  String _formattedDateTimeStart({String format = 'yyyy-MM-dd – HH:mm'}) {
    if (_selectedDate != null && _selectedTime != null) {
      final DateTime combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Using intl package to format the DateTime into a readable string
      //formattedStartDateString = DateFormat('yyyy-MM-dd – kk:mm').format(combinedDateTime);
      return DateFormat(format).format(combinedDateTime);
      // return formattedStartDateString;
    }
    return 'No Date/Time Selected';
  }

  String _formattedDateTimeStart2({String format = 'yyyy-MM-dd – HH:mm'}) {
    if (_selectedDate2 != null && _selectedTime2 != null) {
      final DateTime combinedDateTime = DateTime(
        _selectedDate2!.year,
        _selectedDate2!.month,
        _selectedDate2!.day,
        _selectedTime2!.hour,
        _selectedTime2!.minute,
      );

      // Using intl package to format the DateTime into a readable string
      //formattedStartDateString = DateFormat('yyyy-MM-dd – kk:mm').format(combinedDateTime);
      return DateFormat(format).format(combinedDateTime);
      // return formattedStartDateString;
    }
    return 'No Date/Time Selected';
  }

  String timeDiff() {
    // Define the two DateTime objects
    // Calculate the difference
    DateTime startTime = DateTime.parse(formattedStartDateString);
    DateTime endTime = DateTime.parse(formattedEndDateString);
    Duration difference = endTime.difference(startTime);

    // Output the difference in minutes
    /* print('Difference in minutes: ${difference.inMinutes} minutes');
    print('Difference in seconds: ${difference.inSeconds} seconds');
    print('Difference in seconds: ${difference.inHours} hr');
    print('Difference in seconds: ${difference.inDays} day'); */
    return '${difference.inSeconds}';
  }

  Future<void> _createGame4() async {
    // Parse the strings to DateTime objects
    DateTime dateTime1 = DateTime.parse(formattedStartDateString);
    DateTime dateTime2 = DateTime.parse(formattedEndDateString);

    // Calculate the difference
    Duration difference = dateTime2.difference(dateTime1);
    int dateDiff = 0;
    if (difference.inSeconds > 60) {
      dateDiff = difference.inMinutes;
    } else if (difference.inMinutes > 60) {
      dateDiff = difference.inHours;
    } else if (difference.inHours > 60) {
      dateDiff = difference.inDays;
    } else {
      dateDiff = difference.inSeconds;
    }

    // Print the difference in days, hours, minutes, seconds
    /* print("Difference in days: ${difference.inDays}");
    print("Difference in hours: ${difference.inHours}");
    print("Difference in minutes: ${difference.inMinutes}");
    print("Difference in seconds: ${difference.inSeconds}");
    print(dateDiff); */
    setState(() {
      _isLoading = true;
    });
    ApiService.setGameTime({
      "id": widget.gameId,
      "start_time": formattedStartDateString,
      "end_time": formattedEndDateString,
      "duration": timeDiff(),
    }).then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        if (res.success) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HuntCreationCompleteScreen(
                      gameId: widget.gameId,
                      gameuniqueId: widget.gameuniqueId,
                      gameType: 'challenge',
                      cardType: 'joined',
                      myteam: '')));
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Create a Quest"),
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: const Color(0xFF0B00AB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0B00AB),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Container(
            width: screenSize.width, // 80% of the screen width
            height: screenSize.height,
            decoration: const ShapeDecoration(
              color: Color(0xFFF2F2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
            ),

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _startTimeController,
                    labelText: 'Select Start Time:',
                    hintText: 'Enter your In Time',
                    maxLines: 1,
                    readOnly: true,
                    onTap: () async {
                      // Show date picker when the TextField is tapped
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });

                        // After selecting the date, show Time Picker
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.input,
                        );

                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime = pickedTime;
                            _startTimeController.text = _formattedDateTimeStart(
                                format: 'dd-MM-yyyy – HH:mm');
                            // String formattedDateString = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").format(pickedDate.toUtc());
                            //  formattedStartDateString = formattedDateString;
                            //String inputDate = '2024-08-04 - 15:59'; // Input string

                            // Step 1: Parse the input date
                            DateTime parsedDate =
                                DateFormat('yyyy-MM-dd – HH:mm')
                                    .parse(_formattedDateTimeStart());

                            // Step 2: Format it to ISO 8601 (yyyy-MM-ddTHH:mm:ss.SSS'Z')
                            String isoFormattedDate =
                                DateFormat("yyyy-MM-dd HH:mm:ss")
                                    .format(parsedDate);
                            formattedStartDateString = isoFormattedDate;
                            print(isoFormattedDate);
                            print(_startTimeController.text);
                          });
                        }
                      }
                      // _selectDateAndTime(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _endTimeController,
                    labelText: 'Select End Time:',
                    hintText: 'Enter your Out Time',
                    maxLines: 1,
                    readOnly: true,
                    onTap: () async {
                      // Show date picker when the TextField is tapped
                      // DateTime? pickedDate = await showDatePicker(
                      //   context: context,
                      //   initialDate: DateTime.now(), // Set the initial date
                      //   firstDate: DateTime(2000),   // Set the start date
                      //   lastDate: DateTime(2101),    // Set the end date
                      // );

                      // if (pickedDate != null) {
                      //   // If a date is picked, format it and update the controller
                      //   String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      //  //String formattedDateString = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").format(pickedDate.toUtc());
                      //   //formattedEndDateString = formattedDateString;
                      //   //print(formattedDateString);
                      //   setState(() {
                      //     _endTimeController.text = formattedDate; // Update the TextField
                      //   });
                      // }
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate2 = pickedDate;
                        });

                        // After selecting the date, show Time Picker
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.input,
                        );

                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime2 = pickedTime;
                            _endTimeController.text = _formattedDateTimeStart2(
                                format: 'dd-MM-yyyy – HH:mm');
                            DateTime parsedDate =
                                DateFormat('yyyy-MM-dd – HH:mm')
                                    .parse(_formattedDateTimeStart2());

                            // Step 2: Format it to ISO 8601 (yyyy-MM-ddTHH:mm:ss.SSS'Z')
                            String isoFormattedDate =
                                DateFormat("yyyy-MM-dd HH:mm:ss")
                                    .format(parsedDate);
                            formattedEndDateString = isoFormattedDate;
                            print(isoFormattedDate);
                            print(_endTimeController.text);
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Duration of hunt selection:',
                    style: TextStyle(
                      color: Color(0xFF153792), // Custom label color
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hours/ Minutes/Days/or when host ends',
                    style: TextStyle(
                      color: Color(0xFF6C6A6A), // Custom label color
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Container(
                  //     height: 156,
                  //     decoration: ShapeDecoration(
                  //     color: Colors.white,
                  //     shape: RoundedRectangleBorder(
                  //     side: BorderSide(color: Color(0xFFE5E5E5)),
                  //     borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     shadows: [
                  //     BoxShadow(
                  //     color: Color(0x99EBF0FF),
                  //     blurRadius: 14,
                  //     offset: Offset(0, 4),
                  //     spreadRadius: 0,
                  //     )
                  //     ],
                  //     ),
                  //     ),
                  // const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () {
                            // if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {

                            // }
                            // else{
                            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            //     content: Text('Please enter data'),
                            //  ));
                            // }
                            _createGame4();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF153792),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ), //_login,
                          child: const Text('Next'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
