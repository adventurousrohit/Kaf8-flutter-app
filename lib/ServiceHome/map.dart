import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:kaf8/ServiceHome/Statistics.dart';
import '../profile/myProfile.dart';

import 'call.dart';
import 'messege.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [

          /// 🗺️ MAP BACKGROUND (dummy)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: isDark ? Colors.black26 : Colors.grey.shade300,
            child: Center(
              child: Text(
                "MAP VIEW",
                style: TextStyle(fontSize: 20, color: isDark ? Colors.white24 : Colors.grey),
              ),
            ),
          ),

          /// 🔝 TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [

                  GestureDetector(
                    onTap: () => Get.to(() => const MyProfileScreen()),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://randomuser.me/api/portraits/men/32.jpg"),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "Map",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color),
                  ),

                  const Spacer(),

                  Icon(Icons.notifications_none, color: theme.iconTheme.color),
                  const SizedBox(width: 10),
                  Icon(Icons.menu, color: theme.iconTheme.color),
                ],
              ),
            ),
          ),

          /// 📍 PICKUP POINT
          const Positioned(
            top: 200,
            left: 140,
            child: Icon(Icons.location_on,
                color: Colors.green, size: 40),
          ),

          /// 🚴 DELIVERY POINT
          const Positioned(
            bottom: 260,
            right: 60,
            child: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.delivery_dining, color: Colors.white),
            ),
          ),

          /// ⏱️ TIME BADGE
          Positioned(
            bottom: 300,
            right: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("30 mins", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
          ),

          /// 📦 BOTTOM CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// DRIVER INFO
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/men/32.jpg"),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Cliff Rogers",
                                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15, color: theme.textTheme.bodyLarge?.color)),
                              Text("Delivery guy",
                                  style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: theme.textTheme.bodySmall?.color)),
                            ],
                          ),
                        ),

                        /// CHAT BTN
                        InkWell(
                          onTap: (){
                            Get.to(const MessageScreen());

                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              color: isDark ? Colors.white10 : Colors.grey.shade200,
                              shape: BoxShape.rectangle,
                            ),
                            child: Icon(Icons.chat_bubble_outline, color: theme.iconTheme.color),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// CALL BTN
                        InkWell(
                          onTap: (){
                            Get.to(const CallScreen());

                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              color: isDark ? Colors.white10 : Colors.grey.shade200,
                              shape: BoxShape.rectangle,
                            ),
                            child: Icon(Icons.call, color: theme.iconTheme.color),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// INFO ROWS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 18,color: Colors.grey),
                            const SizedBox(width: 5),
                            Text("Estimated time",
                                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color: theme.textTheme.bodySmall?.color)),


                          ],
                        ),
                        Text("30mins", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18,color: Colors.grey),
                            const SizedBox(width: 5),
                            Text("Deliver to",
                                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color: theme.textTheme.bodySmall?.color)),

                          ],
                        ),
                        Text("Home", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                      ],
                    ),

                    const SizedBox(height: 15),
                    Divider(color: theme.dividerColor,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: (){
                    Get.to(const StatisticsScreen());

                  },
                  child: Text("More details",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,fontSize: 15, color: theme.textTheme.bodyLarge?.color)),
                ),
              ),


                    /// MORE DETAILS BUTTON
                    // Container(
                    //   width: double.infinity,
                    //   padding: EdgeInsets.symmetric(vertical: 12),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey.shade200,
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Center(
                    //     child: Text("More details",
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.w600)),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}