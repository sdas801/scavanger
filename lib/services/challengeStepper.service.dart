import 'dart:async';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:scavenger_app/GameTeamListResponse.dart';
import 'package:scavenger_app/model/gameUpdate.model.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengeStepperTabPage extends StatelessWidget {
  final int activeStep;
  final int totalStep;

  bool isTimeCheck = false;
  bool isPrizeCheck = false;

  ChallengeStepperTabPage({
    super.key,
    required this.activeStep,
    required this.totalStep,
  });

  @override
  Widget build(BuildContext context) {
    return EasyStepper(
        activeStep: activeStep,
        lineStyle: LineStyle(
          lineLength: (MediaQuery.of(context).size.width * 0.03),
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
        steps: [
          EasyStep(
            customStep: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Opacity(
                opacity: activeStep >= 0 ? 1 : 0.3,
                child: const Text(
                  "1",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          EasyStep(
            customStep: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Opacity(
                opacity: activeStep >= 0 ? 1 : 0.3,
                child: const Text(
                  "2",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
        onStepReached: (index) => {});
  }
}
