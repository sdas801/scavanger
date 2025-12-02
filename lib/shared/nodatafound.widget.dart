import 'package:flutter/material.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 6,
      decoration: const BoxDecoration(
        // borderRadius: BorderRadius.circular(12),
        // color: Colors.white,
        shape: BoxShape.rectangle,
        // border: Border.all(
        //     // color: Color(0xFF153792),
        //     // width: 1,
        //     ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Image.asset(
            'assets/images/empty.png',
            width: 100,
            height: 100,
          ),

          const Text(
            'No Data Found',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF153792)),
          )
        ],
      ),
    ));
  }
}
