import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class PaymentScreen extends StatelessWidget {

 final  List payments ;


    PaymentScreen({required this.payments});

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  
  String calculateTotalPayment(){
    int value =0;
    for(var item in payments){
      value +=  int.parse(item['paidSum']);
    }
    final format = NumberFormat("#,###", "en_US");

    return format.format(value).replaceAll(",", " ");
    

    
  }
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Payments"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔹 Total Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Jami to'lovlar",
                  style: TextStyle(
                      fontSize: 16, color: Colors.white70, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  "${calculateTotalPayment()}  UZS",
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          // 🔹 Animated List
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: payments.length,
              itemBuilder: (context, index, animation) {
                 return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0), // from right
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                        parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                        title: Text(
                          "${payments[index]['name']} ${payments[index]['surname']}" ,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        // ✅ Subtitle (Group + Paid Sum)
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Guruh: ${payments[index]['group']}",
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${NumberFormat("#,###", "en_US").format(int.parse(payments[index]['paidSum'])).replaceAll(",", " ")} UZS",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        // ✅ Trailing (Paid Date)
                        trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                          payments[index]['paidDate'],
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        ]
                      ),
                    ),
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
