import 'package:flutter/material.dart';
import 'package:macro_mind_app/features/cards/card.model.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  const CardWidget({super.key, required this.card});

  bool _isValidImageUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isValidImageUrl(card.image) ? null : Colors.grey[300],
          image: _isValidImageUrl(card.image)
              ? DecorationImage(
                  image: NetworkImage(card.image),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_back, size: 20, color: Colors.red[300]),
                Text(
                  card.isSkipped,
                  style: TextStyle(fontSize: 20, color: Colors.red[300]),
                ),
              ],
            ),
            Expanded(
              child: Text(
                card.data,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            Row(
              children: [
                Text(
                  card.isLiked,
                  style: TextStyle(fontSize: 20, color: Colors.green[300]),
                ),
                Icon(Icons.arrow_forward, size: 20, color: Colors.green[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
