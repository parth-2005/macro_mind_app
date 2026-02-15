class CardModel {
  final String data;
  final String image;
  final String isLiked;
  final String isSkipped;
  CardModel({required this.image, required this.data, required this.isLiked, required this.isSkipped});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      image: json['image'],
      data: json['data'],
      isLiked: json['isLiked'],
      isSkipped: json['isSkipped'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'data': data,
      'isLiked': isLiked,
      'isSkipped': isSkipped,
    };
  }
}