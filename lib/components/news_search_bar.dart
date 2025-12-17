import 'package:flutter/material.dart';
import '../helpers/app_theme.dart';

class NewsSearchBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.searchBackground,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.searchBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Buscar noticias...',
                  hintStyle: TextStyle(color: AppTheme.searchHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: onSearch,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 16),
              ),
            ),
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
                onPressed: () => onSearch(controller.text),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
