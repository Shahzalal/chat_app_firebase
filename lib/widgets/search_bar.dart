import 'package:flutter/material.dart';
import '../config/size_config.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;

  const CustomSearchBar({super.key, required this.onSearchChanged});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.ws(12)),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(SizeConfig.ws(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: SizeConfig.fs(20),
            color: Colors.grey.shade600,
          ),
          SizedBox(width: SizeConfig.ws(8)),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: SizeConfig.fs(14),
                  color: Colors.grey.shade600,
                ),
              ),
              style: TextStyle(
                fontSize: SizeConfig.fs(14),
                color: Colors.black87,
              ),
              onChanged: (value) {
                widget.onSearchChanged(value);
                setState(() {
                  _isSearching = value.isNotEmpty;
                });
              },
            ),
          ),
          if (_isSearching)
            IconButton(
              icon: Icon(
                Icons.clear,
                size: SizeConfig.fs(18),
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                _controller.clear();
                widget.onSearchChanged('');
                setState(() {
                  _isSearching = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
