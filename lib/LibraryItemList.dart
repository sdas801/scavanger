class LibraryItemGroup {
  final int groupId;
  final String groupName;
  final String groupDescription;
  final String groupImageUrl;
  final String bannerImageUrl;
  final dynamic price;
  final dynamic paymentAmount;
  final String paymentOrderId;
  final List<HuntItemList> items;

  LibraryItemGroup({
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    required this.groupImageUrl,
    required this.bannerImageUrl,
    required this.price,
    required this.paymentAmount,
    required this.paymentOrderId,
    required this.items,
  });

  factory LibraryItemGroup.fromJson(Map<String, dynamic> json) =>
      LibraryItemGroup(
        groupId: json["group_id"],
        groupName: json["group_name"],
        groupDescription: json["group_description"],
        groupImageUrl: json["group_image_url"],
        bannerImageUrl: json["banner_img_url"],
        price: json["price"],
        paymentAmount: json["payment_amount"],
        paymentOrderId: json["payment_orderId"],
        items: List<HuntItemList>.from(
            json["items"].map((x) => HuntItemList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "group_description": groupDescription,
        "group_image_url": groupImageUrl,
        "banner_img_url": bannerImageUrl,
        "price": price,
        "payment_amount": paymentAmount,
        "payment_orderId": paymentOrderId,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class HuntItemList {
  final int itemId;
  final String itemName;
  final String itemDescription;
  final String itemImageUrl;
  late bool checkItem;

  HuntItemList({
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.itemImageUrl,
    this.checkItem = false,
  });

  factory HuntItemList.fromJson(Map<String, dynamic> json) => HuntItemList(
        itemId: json["item_id"],
        itemName: json["item_name"],
        itemDescription: json["item_description"],
        itemImageUrl: json["item_iamge_url"],
        checkItem: false,
      );

  Map<String, dynamic> toJson() => {
        "item_id": itemId,
        "item_name": itemName,
        "item_description": itemDescription,
        "item_iamge_url": itemImageUrl,
        "checkItem": true,
      };
}

class SearchItemList {
  final int item_id;
  final String item_name;
  final String item_description;
  final String item_iamge_url;
  final String type;
  late bool checkItem;

  SearchItemList({
    required this.item_id,
    required this.item_name,
    required this.item_description,
    required this.item_iamge_url,
    required this.type,
    this.checkItem = false,
  });

  factory SearchItemList.fromJson(Map<String, dynamic> json) => SearchItemList(
        item_id: json["item_id"],
        item_name: json["item_name"],
        item_description: json["item_description"],
        item_iamge_url: json["item_iamge_url"],
        type: json["type"],
        checkItem: false,
      );

  Map<String, dynamic> toJson() => {
        "item_id": item_id,
        "item_name": item_name,
        "item_description": item_description,
        "item_iamge_url": item_iamge_url,
        "type": type,
        "checkItem": true,
      };
}
