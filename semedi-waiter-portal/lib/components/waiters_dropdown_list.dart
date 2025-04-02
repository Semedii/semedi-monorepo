import 'package:flutter/material.dart';

class WaitersDropdownList extends StatelessWidget {
  const WaitersDropdownList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.person_outline),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
        items: const [
          DropdownMenuItem(value: "ali", child: Text("Ali Mohamed")),
          DropdownMenuItem(value: "aisha", child: Text("Aisha Hassan")),
          DropdownMenuItem(value: "omar", child: Text("Omar Ahmed")),
        ],
        onChanged: (value) {},
        hint: const Text("Select your name"),
      ),
    );
  }
}
