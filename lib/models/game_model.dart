class GamepassItem {
  final String id;
  final String name;
  final int robux;
  final String icon;
  final String desc;
  final bool popular;

  const GamepassItem({
    required this.id,
    required this.name,
    required this.robux,
    required this.icon,
    required this.desc,
    this.popular = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'robux': robux,
    'icon': icon,
    'desc': desc,
    'popular': popular,
  };

  factory GamepassItem.fromJson(Map<String, dynamic> json) => GamepassItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    robux: json['robux'] ?? 0,
    icon: json['icon'] ?? '',
    desc: json['desc'] ?? '',
    popular: json['popular'] ?? false,
  );
}

class RobloxGame {
  final String id;
  final String name;
  final String thumbnail;
  final String tag;
  final String desc;
  final List<GamepassItem> gamepasses;

  const RobloxGame({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.tag,
    required this.desc,
    required this.gamepasses,
  });
}

class CartItem {
  final String gameId;
  final String gameName;
  final String passId;
  final String passName;
  final int passRobux;
  final String passIcon;
  int quantity;

  CartItem({
    required this.gameId,
    required this.gameName,
    required this.passId,
    required this.passName,
    required this.passRobux,
    required this.passIcon,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'gameName': gameName,
    'passId': passId,
    'passName': passName,
    'passRobux': passRobux,
    'passIcon': passIcon,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    gameId: json['gameId'] ?? '',
    gameName: json['gameName'] ?? '',
    passId: json['passId'] ?? '',
    passName: json['passName'] ?? '',
    passRobux: json['passRobux'] ?? 0,
    passIcon: json['passIcon'] ?? '',
    quantity: json['quantity'] ?? 1,
  );
}
