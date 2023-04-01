class Wallet {
  final int id;
  String name;
  final String address;
  final int height;

  Wallet(this.id, this.name, this.address, this.height);

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      json["id"],
      json["name"],
      json["address"],
      json["height"],
    );
  }

  Map toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "height": height,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallet &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          address == other.address &&
          height == other.height;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ address.hashCode ^ height.hashCode;
}
