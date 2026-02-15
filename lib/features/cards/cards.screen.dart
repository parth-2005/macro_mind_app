import 'package:flutter/material.dart';
import 'package:macro_mind_app/features/cards/cards.widget.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:macro_mind_app/features/cards/card.provider.dart';
import 'package:provider/provider.dart';
import 'package:macro_mind_app/core/widgets/card_skeleton.dart';
import 'package:macro_mind_app/core/widgets/fallback_widgets.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    // Defer the getCards call to after the build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardProvider>(context, listen: false).getCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CardProvider>(context);
    final cards = provider.cards;

    if (provider.isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: List.generate(
                      3,
                      (index) => Positioned(
                        top: index * 8.0,
                        left: index * 8.0,
                        right:
                            MediaQuery.of(context).size.width -
                            (index * 8.0) -
                            32,
                        bottom:
                            MediaQuery.of(context).size.height -
                            (index * 8.0) -
                            300,
                        child: const CardSkeleton(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: SafeArea(
          child: ErrorRetryWidget(
            message: 'Unable to load cards.\n${provider.error}',
            onRetry: () => provider.getCards(),
            icon: Icons.card_giftcard_outlined,
          ),
        ),
      );
    }

    if (cards.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: EmptyStateWidget(
            message: 'No cards available at the moment.\nCheck back later!',
            icon: Icons.inbox_outlined,
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: CardSwiper(
          cardsCount: cards.length,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) =>
              CardWidget(card: cards[index]),
        ),
      ),
    );
  }
}
