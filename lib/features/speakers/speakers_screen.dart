import 'package:flutter/material.dart';
import 'package:flutter_birmingham_hub/features/speakers/screens/speakers_list_screen.dart';

/// This class is kept for backward compatibility
/// It now redirects to the new SpeakersListScreen implementation
class SpeakersScreen extends StatelessWidget {
  const SpeakersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpeakersListScreen();
  }
}
