import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepperTabPage extends StatefulWidget {
  final int activeStep;
  final int totalStep;
  final int gameId;

  const StepperTabPage({
    Key? key,
    required this.activeStep,
    required this.totalStep,
    required this.gameId,
  }) : super(key: key);

  @override
  _StepperTabPageState createState() => _StepperTabPageState();
}

class _StepperTabPageState extends State<StepperTabPage> {
  bool isTimeCheck = false;
  bool isPrizeCheck = false;

  @override
  void initState() {
    super.initState();
    _gameDetails();
  }

  Future<void> _gameDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTimeCheck = prefs.getBool('isTimedHunt') ?? false;
      isPrizeCheck = prefs.getBool('willOfferPrizes') ?? false;
    });
    print("isTimeCheck: $isTimeCheck, isPrizeCheck: $isPrizeCheck");
  }

  @override
  Widget build(BuildContext context) {
    return EasyStepper(
      activeStep: widget.activeStep,
      lineStyle: LineStyle(
        lineLength: MediaQuery.of(context).size.width * 0.03,
        lineType: LineType.normal,
        lineThickness: 3,
        lineSpace: 1,
        lineWidth: 5,
        unreachedLineType: LineType.dashed,
      ),
      stepShape: StepShape.circle,
      stepBorderRadius: 15,
      borderThickness: 2,
      internalPadding: 10,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      stepRadius: 18,
      finishedStepBorderColor: Colors.green,
      finishedStepTextColor: Colors.white,
      finishedStepBackgroundColor: Colors.green,
      activeStepIconColor: Colors.deepOrange,
      activeStepBackgroundColor: Colors.green,
      activeStepBorderColor: Colors.green,
      unreachedStepBackgroundColor: Colors.grey,
      showLoadingAnimation: false,
      steps: _buildSteps(),
      onStepReached: (index) => {},
    );
  }

  List<EasyStep> _buildSteps() {
    List<EasyStep> steps = [
    for (int i = 1; i <= (isPrizeCheck || isTimeCheck ? 5 : 4); i++)
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: widget.activeStep >= i - 1 ? 1 : 0.3,
              child: Text(
                "$i",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
    ];

    // Add the 6th step conditionally
    if (isTimeCheck && isPrizeCheck) {
      steps.add(
        EasyStep(
          customStep: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Opacity(
              opacity: widget.activeStep >= 5 ? 1 : 0.3,
              child: const Text(
                "6",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return steps;
  }
}
