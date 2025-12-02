class ItemGroup {
  final int id;
  final String name;
  final String image;
  final dynamic price;
  final double discount;

  ItemGroup(
      {required this.id,
      required this.name,
      required this.image,
      this.price = 0,
      this.discount = 0});

  factory ItemGroup.fromJson(Map<String, dynamic> json) {
    return ItemGroup(
      id: json['id'],
      name: json['group_name'],
      image: json['group_image_url'],
      price: json['price'],
      discount: 0,
    );
  }
}

class itemCatagory {
  final int id;
  final String name;

  itemCatagory({
    required this.id,
    required this.name,
  });

  factory itemCatagory.fromJson(Map<String, dynamic> json) {
    return itemCatagory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ItemGroupDetails {
  final int id;
  final String name;
  final String description;
  final String image;
  final String bannerImg;
  final dynamic price;
  final double? discount;
  final int? itemcount;
  List<Item> items = [];

  ItemGroupDetails(
      {required this.id,
      required this.name,
      required this.description,
      required this.image,
      required this.bannerImg,
      this.price = 0,
      this.discount = 0,
      required this.itemcount,
      this.items = const []});

  factory ItemGroupDetails.fromJson(Map<String, dynamic> json) {
    return ItemGroupDetails(
      id: json['id'],
      name: json['group_name'],
      description: json['group_description'],
      image: json['group_image_url'],
      bannerImg: json['banner_img_url'],
      price: json['price'],
      discount: 0,
      itemcount: json['item_count'],
      items: (json['items'] as List).map((i) => Item.fromJson(i)).toList(),
    );
  }
}

class Item {
  final int id;
  final int groupId;
  final String name;
  final String description;
  final String image;

  Item(
      {required this.id,
      required this.name,
      required this.image,
      required this.groupId,
      required this.description});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      groupId: json['group_id'],
      name: json['item_name'],
      description: json['item_description'],
      image: json['item_iamge_url'],
    );
  }
}
