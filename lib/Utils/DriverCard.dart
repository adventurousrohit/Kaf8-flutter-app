import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DriverCard extends StatefulWidget {
  final UserModel driver;

  const DriverCard({super.key, required this.driver});

  @override
  State<DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<DriverCard> {
  bool isFavorite = false;
  VehicleType? selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final driver = widget.driver;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Top Row
          Row(
            children: [
              const Text("Delivery Driver"),
              const Spacer(),

              /// ❤️ Favorite
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              )
            ],
          ),

          const SizedBox(height: 10),

          /// Driver Info
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),

                    Text(driver.location,
                        style: const TextStyle(color: Colors.grey)),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        Text("${driver.rating} (${driver.reviews})"),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {},
              ),

              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Vehicles
          const Text("Delivery Vehicles"),

          const SizedBox(height: 8),

          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: driver.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = driver.vehicles[index];
                final isSelected = selectedVehicle == vehicle;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicle = vehicle;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(vehicle.name),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum VehicleType { bike, scooter, car, van, truck, pickup }

extension VehicleTypeExt on VehicleType {
  String get name {
    switch (this) {
      case VehicleType.bike:
        return "Bike";
      case VehicleType.scooter:
        return "Scooter";
      case VehicleType.car:
        return "Car";
      case VehicleType.van:
        return "Van";
      case VehicleType.truck:
        return "Truck";
      case VehicleType.pickup:
        return "Pickup";
    }
  }
}

class UserModel {
  final String uid;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final List<VehicleType> vehicles;

  UserModel({
    required this.uid,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.vehicles,
  });
}