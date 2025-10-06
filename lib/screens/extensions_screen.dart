import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Extensions Screen - Browse and manage extensions
class ExtensionsScreen extends StatefulWidget {
  const ExtensionsScreen({super.key});

  @override
  State<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends State<ExtensionsScreen> {
  List<VsCodeExtension>? _extensions;
  List<VsCodeExtension>? _sortedExtensions;
  bool _isLoading = true;
  String? _error;
  bool _isCompactLayout = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _letterIndices = {};

  @override
  void initState() {
    super.initState();
    _loadExtensions();
  }

  Future<void> _loadExtensions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load extensions from the CSV file (symlinked Data folder)
      const csvPath = 'Data/vscode-extensions.csv';
      final extensions = await CsvParserService.parseDefaultProfileExtensions(csvPath);
      
      // Sort extensions alphabetically by display name
      final sortedExtensions = List<VsCodeExtension>.from(extensions)
        ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
      
      // Calculate letter indices for A-Z navigation
      final letterIndices = <String, int>{};
      for (int i = 0; i < sortedExtensions.length; i++) {
        final firstLetter = sortedExtensions[i].displayName[0].toUpperCase();
        if (!letterIndices.containsKey(firstLetter)) {
          letterIndices[firstLetter] = i;
        }
      }
      
      setState(() {
        _extensions = extensions;
        _sortedExtensions = sortedExtensions;
        _letterIndices.clear();
        _letterIndices.addAll(letterIndices);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extensions'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isCompactLayout ? Icons.view_list : Icons.view_module),
            tooltip: _isCompactLayout ? 'Regular View' : 'Compact View',
            onPressed: () {
              setState(() {
                _isCompactLayout = !_isCompactLayout;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExtensions,
            tooltip: 'Refresh extensions',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading extensions',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadExtensions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_extensions == null || _extensions!.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.extension_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No extensions found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A-Z Navigation Bar
                    _buildAlphabetNavigation(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        // Performance optimizations
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                        addSemanticIndexes: false,
                        cacheExtent: 1000,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _isCompactLayout ? 6 : 4,
                          childAspectRatio: _isCompactLayout ? 1.8 : 1.2,
                          crossAxisSpacing: _isCompactLayout ? 8 : 16,
                          mainAxisSpacing: _isCompactLayout ? 8 : 16,
                        ),
                        itemCount: _sortedExtensions!.length,
                        itemBuilder: (context, index) {
                          final extension = _sortedExtensions![index];
                          return ExtensionCard(
                            key: ValueKey('${extension.id}-${_isCompactLayout ? 'compact' : 'regular'}'),
                            extension: extension,
                            isCompact: _isCompactLayout,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetNavigation() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final letter = letters[index];
          final hasExtensions = _letterIndices.containsKey(letter);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: hasExtensions ? () => _scrollToLetter(letter) : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasExtensions 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasExtensions 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasExtensions 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollToLetter(String letter) {
    final index = _letterIndices[letter];
    if (index == null) return;
    
    // Get the current grid delegate properties
    final crossAxisCount = _isCompactLayout ? 6 : 4;
    final childAspectRatio = _isCompactLayout ? 1.8 : 1.2;
    final crossAxisSpacing = _isCompactLayout ? 8.0 : 16.0;
    final mainAxisSpacing = _isCompactLayout ? 8.0 : 16.0;
    
    // Calculate which row the item is in
    final row = index ~/ crossAxisCount;
    
    // Calculate item dimensions based on the available width
    // We need to account for padding (12px on each side) and cross axis spacing
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (12.0 * 2); // Account for padding
    final totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
    final itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
    final itemHeight = itemWidth / childAspectRatio;
    
    // Calculate the scroll position accounting for fixed header elements
    final baseScrollPosition = row * (itemHeight + mainAxisSpacing);
    
    // Account for the space taken by:
    // - A-Z navigation bar (40px height + 8px bottom margin = 48px)
    // Total offset: 48px
    final headerOffset = 48.0; // navigation bar only
    
    final scrollPosition = (baseScrollPosition - headerOffset).clamp(0.0, double.infinity);

    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

