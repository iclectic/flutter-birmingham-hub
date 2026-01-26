import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/speakers/providers/speaker_providers.dart';
import 'package:flutter_birmingham_hub/features/speakers/widgets/speaker_card.dart';
import 'package:flutter_birmingham_hub/shared/models/speaker_model.dart';

class SpeakersListScreen extends ConsumerStatefulWidget {
  const SpeakersListScreen({super.key});

  @override
  ConsumerState<SpeakersListScreen> createState() => _SpeakersListScreenState();
}

class _SpeakersListScreenState extends ConsumerState<SpeakersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _speakersLimit = 10; // Initial limit for pagination
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMoreSpeakers();
    }
  }

  Future<void> _loadMoreSpeakers() async {
    setState(() {
      _isLoadingMore = true;
      _speakersLimit += 10; // Load 10 more speakers
    });
    
    // This will trigger a rebuild with more speakers
    await ref.refresh(paginatedSpeakersProvider(_speakersLimit).future);
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String query) {
    ref.read(speakersSearchProvider.notifier).state = query;
  }

  void _onTagSelected(String tag) {
    final currentTag = ref.read(speakersTagFilterProvider);
    
    // Toggle tag filter
    if (currentTag == tag) {
      ref.read(speakersTagFilterProvider.notifier).state = null;
    } else {
      ref.read(speakersTagFilterProvider.notifier).state = tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final speakersAsync = ref.watch(filteredSpeakersProvider);
    final searchQuery = ref.watch(speakersSearchProvider);
    final tagFilter = ref.watch(speakersTagFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speakers'),
      ),
      body: Column(
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.people,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Our Speakers',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Meet the amazing speakers from our community',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search speakers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                
                // Tag filter chips will be shown here when we have speakers loaded
                speakersAsync.when(
                  data: (speakers) {
                    // Extract unique tags from all speakers
                    final allTags = <String>{};
                    for (final speaker in speakers) {
                      allTags.addAll(speaker.topics);
                    }
                    
                    if (allTags.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: allTags.map((tag) {
                          final isSelected = tag == tagFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (_) => _onTagSelected(tag),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          
          // Speakers grid
          Expanded(
            child: speakersAsync.when(
              data: (speakers) {
                if (speakers.isEmpty) {
                  return const Center(
                    child: Text('No speakers found'),
                  );
                }
                
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: speakers.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == speakers.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      return SpeakerCard(speaker: speakers[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error loading speakers: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
