import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/model/parchesedHistory.modal.dart';
import 'package:scavenger_app/services/api.service.dart';

class SubscriptionHistoryPage extends StatefulWidget {
  const SubscriptionHistoryPage({super.key});

  @override
  _SubscriptionHistoryPageState createState() =>
      _SubscriptionHistoryPageState();
}

class _SubscriptionHistoryPageState extends State<SubscriptionHistoryPage> {
  List<historyItem> items = [];

  @override
  void initState() {
    parchesedHistoryList();
    print(">>>>");
  }

  Future<void> parchesedHistoryList() async {
    print(">>>>");
    ApiService.parchesedHistoryList({}).then((res) {
      try {
        if (res.success) {
          var huntList = List<historyItem>.from(
              res.response.map((x) => historyItem.fromJson(x)));
          setState(() {
            items = huntList;
          });

          // if (jsonResponseData.items.isNotEmpty) {
          //   // items1 = jsonResponseData.items;
          //   // print(">>>>>>>>>>>>>>>${items1}");
          // }
        } else {}
      } catch (e) {}
    });
    // print(">>>>111$items1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscription History"),
        backgroundColor: const Color(0xFF0B00AB),
        foregroundColor: Colors.white,
      ),
      body: items.length == 0
          ? const Center(
              child: Text(
              "No purchase history",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                print("object$items");
                return SubscriptionItemCard(items[index]);
              },
            ),
    );
  }
}

class SubscriptionItem {
  final String name;
  final String purchaseDate;
  final String expiryDate;
  final String details;
  final String price;
  final bool isActive;

  SubscriptionItem(this.name, this.purchaseDate, this.expiryDate, this.details,
      this.price, this.isActive);
}

class SubscriptionItemCard extends StatelessWidget {
  final historyItem item;

  const SubscriptionItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    String? formatDate1(String? dateStr) {
      if (dateStr == null) return null;
      try {
        DateTime date = DateTime.parse(dateStr);
        return DateFormat("MMM d, yyyy").format(date);
      } catch (e) {
        return null; // Return null for invalid date formats
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.subscription_name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(21, 55, 146, 1),
              ),
            ),
            const SizedBox(height: 5),
            Text("Purchase Date: ${formatDate1(item.start_date)}",
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Text("Expiry Date: ${formatDate1(item.end_date)}",
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Text("Price: \$ ${item.amount}",
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 5),
            // Text(subscription.details,
            //     style: const TextStyle(fontSize: 14, color: Colors.black87)),
            // const SizedBox(height: 5),
            Text(
              item.is_expire == 0 ? "Status: Active" : "Status: Expired",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: item.is_expire == 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
