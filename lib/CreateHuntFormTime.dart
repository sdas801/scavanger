import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/CreateHuntFormLastPage.dart';
import 'package:scavenger_app/CreateHuntPictureForm.dart';
import 'package:scavenger_app/services/stepper.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_textfield.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/gameUpdate.model.dart';

class CreateHuntFormTime extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const CreateHuntFormTime(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _CreateHuntFormTimeState createState() => _CreateHuntFormTimeState();
}

class _CreateHuntFormTimeState extends State<CreateHuntFormTime> {
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String timeDifferance = "";
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool isPrized = false;
  String startTime = '';
  String endTime = '';

  DateTime? _selectedDate2;
  TimeOfDay? _selectedTime2;
  bool isCheckedStartTime = false;
  bool isCheckedEndTime = false;

  @override
  void initState() {
    super.initState();
    _gameDetails();
  }

  void _gameDetails() {
    ApiService.gameDetails(widget.gameId).then((value) {
      if (value.success) {
        var result = GameTimePage.fromJson(value.response);
        isPrized = result.isPrized ?? false;
        if (result.inTime != null && result.outTime != null) {
          setState(() {
            formattedStartDateString = result.inTime.toString();
            formattedEndDateString = result.outTime.toString();
            _selectedDate = DateTime.parse(formattedStartDateString);
            _selectedTime = TimeOfDay.fromDateTime(
                DateTime.parse(formattedStartDateString));
            _selectedDate2 = DateTime.parse(formattedEndDateString);
            _selectedTime2 =
                TimeOfDay.fromDateTime(DateTime.parse(formattedEndDateString));
            // convert date time to string
            _startTimeController.text =
                _formatDate(_selectedDate!, _selectedTime!);
            startTime = _formatDateTime(_selectedDate!, _selectedTime!);
            _endTimeController.text =
                _formatDate(_selectedDate2!, _selectedTime2!);
            endTime = _formatDateTime(_selectedDate2!, _selectedTime2!);
            var _ = timeDiff();
          });
        }
      }
    });
  }

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
      );

      if (pickedTime != null) {
        setState(() {
          _selectedTime = pickedTime;
        });
      }
    }
  }

  bool _isLoading = false;
  Future<void> _createGame4() async {
    setState(() {
      _isLoading = true;
    });
    final String startTime = _startTimeController.text;
    final String endTime = _endTimeController.text;
    String authToken = "";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('auth_token')) {
      authToken = (prefs.getString('auth_token') ?? "");
    }
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

    if (dateTime1.isAfter(dateTime2)) {
      Fluttertoast.showToast(
        msg: "End time must be greater than start time.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFF0B00AB),
        textColor: Colors.white,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var reqData = {
      "id": widget.gameId,
      "start_time": formattedStartDateString,
      "end_time": formattedEndDateString,
      "duration": timeDiff(),
      "is_auto_start": isCheckedEndTime,
      "is_auto_end": isCheckedStartTime
    };

    ApiService.setGameTime(reqData).then((res) async {
      try {
        if (res.success) {
          // final jsonResponseData = HuntTimeResponse.fromJson(res.response);
          if (isPrized) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateHuntPictureForm(
                        gameId: widget.gameId,
                        gameuniqueId: widget.gameuniqueId)));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateHuntFormLastPage(
                        gameId: widget.gameId,
                        gameuniqueId: widget.gameuniqueId)));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('data add failed: ${res.message}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String formattedStartDateString = "";
  String formattedEndDateString = "";
  String _formattedDateTimeStart() {
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
      return DateFormat('yyyy-MM-dd – HH:mm').format(combinedDateTime);
      // return formattedStartDateString;
    }
    return 'No Date/Time Selected';
  }

  String _formattedDateTimeStart2() {
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
      return DateFormat('yyyy-MM-dd – kk:mm').format(combinedDateTime);
      // return formattedStartDateString;
    }
    return 'No Date/Time Selected';
  }

  String _formatDateTime(DateTime selectedDate, TimeOfDay selectedTime) {
    final DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    return DateFormat('MM/dd/yyyy – hh:mm aaa').format(combinedDateTime);
  }

  String _formatDate(DateTime selectedDate, TimeOfDay selectedTime) {
    final DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    return DateFormat('MMM dd, yyyy – hh:mm aaa').format(combinedDateTime);
  }

  String timeDiff() {
    // Define the two DateTime objects
    // Calculate the difference
    DateTime startTime = DateTime.parse(formattedStartDateString);
    DateTime endTime = DateTime.parse(formattedEndDateString);
    Duration difference = endTime.difference(startTime);
    if (difference.isNegative) {
      timeDifferance = '';
      return '0';
    } else {
      var d = "";
      if (difference.inDays > 0) {
        d += '${difference.inDays} day ';
      }
      if (difference.inHours % 24 > 0) {
        d += '${difference.inHours % 24} hr ';
      }
      if (difference.inMinutes % 60 > 0) {
        d += '${difference.inMinutes % 60} min ';
      }
      if (difference.inSeconds % 60 > 0) {
        d += '${difference.inSeconds % 60} sec';
      }

      setState(() {
        timeDifferance = d;
      });
      return '${difference.inSeconds}';
    }
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
        title: const Text("Create Hunt"),
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: const Color(0xFF0B00AB),
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications),
        //     onPressed: () {},
        //   ),
        // ],
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
                  Image.asset(
                    'assets/images/1 1.png', // Update the image asset accordingly
                    height: 117,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Create a Hunt                                     ',
                          style: TextStyle(
                            color: Color(0xFF153792),
                            fontSize: 30,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0),
                  // const Text(
                  //   "Lorem Ipsum is simply dummy",
                  //   textAlign: TextAlign.left,
                  //   style: TextStyle(fontSize: 15, color: Color(0xFF82929D)),
                  // ),
                  const SizedBox(height: 20),
                  // Image.asset(
                  //   'assets/images/hunt4.png', // Update the image asset accordingly
                  //   height: 30,
                  //   fit: BoxFit.fill,
                  // ),
                  // const SizedBox(height: 20),
                  StepperTabPage(
                      activeStep: 3, totalStep: 5, gameId: widget.gameId),

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
                        firstDate: DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day),
                        lastDate: DateTime(DateTime.now().year + 10),
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
                            _startTimeController.text =
                                _formatDate(_selectedDate!, _selectedTime!);
                            startTime =
                                _formatDateTime(_selectedDate!, _selectedTime!);
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
                            if (_endTimeController.text.isNotEmpty) {
                              timeDiff();
                            }
                          });
                        }
                      }
                      // _selectDateAndTime(context);
                    },
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: isCheckedStartTime,
                        activeColor: Colors.blue, // Blue check mark color
                        checkColor: Colors.white, // Color of the tick (✔)
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckedStartTime = value!;
                          });
                        },
                      ),
                      Text(
                        "Auto Start",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _endTimeController,
                    labelText: 'Select End Time:',
                    hintText: 'Enter your Out Time',
                    maxLines: 1,
                    readOnly: true,
                    onTap: () async {
                      if (_selectedDate == null) {
                        // Ensure the user has selected a start date first
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Please select a start date first.")),
                        );
                        return;
                      }

                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate!,
                        firstDate:
                            _selectedDate!, // Set the start date as the minimum date
                        lastDate: DateTime(DateTime.now().year + 10),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate2 = pickedDate;
                        });

                        // After selecting the date, show Time Picker
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            DateTime.now().add(const Duration(minutes: 5)),
                          ),
                          initialEntryMode: TimePickerEntryMode.input,
                        );

                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime2 = pickedTime;
                            _endTimeController.text =
                                _formatDate(_selectedDate2!, _selectedTime2!);
                            endTime = _formatDateTime(
                                _selectedDate2!, _selectedTime2!);

                            // Format the date and time to the desired ISO format
                            DateTime parsedDate =
                                DateFormat('yyyy-MM-dd – HH:mm')
                                    .parse(_formattedDateTimeStart2());

                            String isoFormattedDate =
                                DateFormat("yyyy-MM-dd HH:mm:ss")
                                    .format(parsedDate);
                            formattedEndDateString = isoFormattedDate;

                            // Calculate the time difference
                            timeDiff();
                          });
                        }
                      }
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isCheckedEndTime,
                        activeColor: Colors.blue, // Blue check mark color
                        checkColor: Colors.white, // Color of the tick (✔)
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckedEndTime = value!;
                          });
                        },
                      ),
                      Text(
                        "Auto End",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
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
                  timeDifferance != ""
                      ? Text(
                          timeDifferance,
                          style: const TextStyle(
                            color: Color(0xFF6C6A6A), // Custom label color
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          "Start time should be less than the end time",
                          style: TextStyle(
                            color: Color.fromARGB(
                                255, 223, 19, 19), // Custom label color
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () {
                            if (timeDifferance != "") {
                              _createGame4();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF153792),
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
