class VehicleTypeModel {
  final String id;
  final String name;
  final String icon;
  final double baseCost;
  final String description;

  const VehicleTypeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseCost,
    required this.description,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      icon: '${json['icon'] ?? ''}',
      baseCost: double.tryParse('${json['baseCost'] ?? 0}') ?? 0,
      description: '${json['description'] ?? ''}',
    );
  }
}
