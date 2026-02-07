import 'enums.dart';

class MapZone {
  final String id;
  final String name;
  final World world;
  final Region region;
  final String tier;
  final String description;
  final List<String> neighbors; // 连接的 zone id
  final List<String> pointsOfInterest;

  const MapZone({
    required this.id,
    required this.name,
    required this.world,
    required this.region,
    required this.tier,
    required this.description,
    this.neighbors = const [],
    this.pointsOfInterest = const [],
  });

  factory MapZone.fromJson(Map<String, dynamic> json) => MapZone(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        world: World.values.firstWhere(
          (w) => w.name == json['world'],
          orElse: () => World.mortal,
        ),
        region: Region.values.firstWhere(
          (r) => r.name == json['region'],
          orElse: () => Region.ren,
        ),
        tier: json['tier'] ?? '',
        description: json['description'] ?? '',
        neighbors: List<String>.from(json['neighbors'] ?? const []),
        pointsOfInterest: List<String>.from(json['pointsOfInterest'] ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'world': world.name,
        'region': region.name,
        'tier': tier,
        'description': description,
        'neighbors': neighbors,
        'pointsOfInterest': pointsOfInterest,
      };
}
