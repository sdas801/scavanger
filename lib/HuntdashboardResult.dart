import 'package:flutter/material.dart';

class HuntdashboardResult extends StatefulWidget {
  const HuntdashboardResult({super.key});

  @override
  _HuntdashboardResultState createState() => _HuntdashboardResultState();
}

class _HuntdashboardResultState extends State<HuntdashboardResult> {
  final List<Item> items = [
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
         backgroundColor: const Color(0xFF0B00AB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ItemCard(item: items[index]);
        },
      ),
    );
  }
}

class Item {
  final String name;
  final String description;
  final String status;
  final Color statusColor;
  final String imageUrl;

  Item({
    required this.name,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.imageUrl,
  });
}

class ItemCard extends StatelessWidget {
  final Item item;

  ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(item.imageUrl),
              radius: 30,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: item.statusColor,
                    ),
                  ),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 12,
                    color: Color(0xFF45516E)
                    ),
                    
                  ),
                  //SizedBox(height: 8.0),
                  // Text(
                  //   item.status,
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: item.statusColor,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ),
             IconButton(
              icon: Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20.0),
          actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
              
            },
          ),
        ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/waitingImg.png', width: 197, height: 174),
              SizedBox(height: 20),
              const Text(
                'Please Wait For Result !',
                style: TextStyle(
                color: Color(0xFF153792),
                fontSize: 20,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                height: 0.04,
                ),
                ),
                SizedBox(height: 30),
                const Text(
                'It is a long established fact that a reader will be distracted by the readable content. ',
                textAlign: TextAlign.center,
                style: TextStyle(
                color: Color(0xFF46516E),
                fontSize: 14,
                
                ),
                ),
            ],
          ),
          
        );
      },
    );
}