import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    this.onBookmarkChange,
    this.isBookmarked = false,
    this.size = 40,
    Key? key,
  }) : super(key: key);

  final ValueChanged<bool>? onBookmarkChange;
  final bool isBookmarked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => onBookmarkChange?.call(!isBookmarked),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: size / 2,
          color: isBookmarked ? Colors.red : Colors.white,
        ),
      ),
    );
  }
}
