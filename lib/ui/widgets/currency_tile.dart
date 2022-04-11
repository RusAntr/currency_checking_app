import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/consts/app_text_styles.dart';
import '../../data/models/currency_model.dart';

class CurrencyTile extends StatefulWidget {
  const CurrencyTile({
    Key? key,
    required this.currency,
    required this.isHint,
  }) : super(key: key);
  final Currency currency;
  final bool isHint;

  @override
  State<CurrencyTile> createState() => _CurrencyTileState();
}

class _CurrencyTileState extends State<CurrencyTile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          widget.isHint ? BorderRadius.circular(50) : BorderRadius.circular(10),
      child: _hoveringFunc(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: isHovering
              ? const EdgeInsets.fromLTRB(7, 7, 30, 7)
              : const EdgeInsets.fromLTRB(7, 7, 15, 7),
          color: Colors.black.withOpacity(isHovering ? 0.4 : 0.1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              currencyEmojiCircle(emoji: widget.currency.emoji),
              const SizedBox(width: 10.0),
              widget.isHint == true
                  ? Text(
                      widget.currency.currencyCode,
                      style: AppTextStyles.titleWhiteMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currency.currencyCode,
                          style: AppTextStyles.titleWhiteMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.currency.currencyName,
                          style: AppTextStyles.titleWhiteMedium.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles hovering. Returns [MouseRegion] if the platform is web otherwise returns [Listener]
  Widget _hoveringFunc({required Widget child}) {
    return kIsWeb
        ? MouseRegion(
            child: child,
            cursor: MouseCursor.defer,
            onExit: (event) {
              setState(() {
                isHovering = false;
              });
            },
            onEnter: (event) {
              setState(() {
                isHovering = true;
              });
            },
          )
        : Listener(
            child: child,
            onPointerUp: (event) {
              setState(() {
                isHovering = false;
              });
            },
            onPointerDown: (event) {
              setState(() {
                isHovering = true;
              });
            });
  }

  Widget currencyEmojiCircle({
    required String emoji,
  }) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.black.withOpacity(isHovering ? 0.5 : 0.2),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          emoji,
          style: AppTextStyles.titleWhiteBig,
        ),
      ),
    );
  }
}
