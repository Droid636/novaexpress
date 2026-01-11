import 'package:flutter/material.dart';
import '../app_theme.dart';

class NewsSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const NewsSearchBar({
    super.key,
    required this.onSearch,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<NewsSearchBar> createState() => _NewsSearchBarState();
}

class _NewsSearchBarState extends State<NewsSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navBackground : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark
                ? AppTheme.navUnselected.withOpacity(0.4)
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Buscar noticias...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.navUnselected
                        : Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSearch,
                onChanged: widget.onChanged,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.bookmarksTitle,
                ),
              ),
            ),

            /// 🔍 BOTÓN BUSCAR
            Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: AppTheme.searchIconBg,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: AppTheme.searchIconColor),
                onPressed: () => widget.onSearch(_controller.text),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
