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
    return Scaffold(
      body: Stack(
        children: [

          /// 🗺️ MAP BACKGROUND (dummy)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade300,
            child: Center(
              child: Text(
                "MAP VIEW",
                style: TextStyle(fontSize: 20, color: Colors.grey),
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
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://randomuser.me/api/portraits/men/32.jpg"),
                    ),
                  ),

                  Spacer(),

                  Text(
                    "Map",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),

                  Spacer(),

                  Icon(Icons.notifications_none),
                  SizedBox(width: 10),
                  Icon(Icons.menu),
                ],
              ),
            ),
          ),

          /// 📍 PICKUP POINT
          Positioned(
            top: 200,
            left: 140,
            child: Icon(Icons.location_on,
                color: Colors.green, size: 40),
          ),

          /// 🚴 DELIVERY POINT
          Positioned(
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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("30 mins"),
            ),
          ),

          /// 📦 BOTTOM CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)
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
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/men/32.jpg"),
                        ),

                        SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cliff Rogers",
                                style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15)),
                            Text("Delivery guy",
                                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.grey)),
                          ],
                        ),

                        Spacer(),

                        /// CHAT BTN
                        InkWell(
                          onTap: (){
                            Get.to(MessageScreen());

                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              color: Colors.grey.shade200,
                              shape: BoxShape.rectangle,
                            ),
                            child: Icon(Icons.chat_bubble_outline),
                          ),
                        ),

                        SizedBox(width: 10),

                        /// CALL BTN
                        InkWell(
                          onTap: (){
                            Get.to(CallScreen());

                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              color: Colors.grey.shade200,
                              shape: BoxShape.rectangle,
                            ),
                            child: Icon(Icons.call),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    /// INFO ROWS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 18,color: Colors.grey),
                            SizedBox(width: 5),
                            Text("Estimated time",
                                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color: Colors.grey)),


                          ],
                        ),
                        Text("30mins"),
                      ],
                    ),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18,color: Colors.grey),
                            SizedBox(width: 5),
                            Text("Deliver to",
                                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color: Colors.grey)),

                          ],
                        ),
                        Text("Home"),
                      ],
                    ),

                    SizedBox(height: 15),
                    Divider(color: Colors.black,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: (){
                    Get.to(StatisticsScreen());

                  },
                  child: Text("More details",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,fontSize: 15)),
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