import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/models.dart';
import 'services/services.dart';

void main() {
  runApp(const VSXVizApp());
}

class VSXVizApp extends StatelessWidget {
  const VSXVizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSXViz - VS Code Extension Visualizer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007ACC), // VS Code blue
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007ACC), // VS Code blue
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProfilesScreen(),
    const ExtensionsScreen(),
  ];

  final List<NavigationRailDestination> _destinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.dashboard),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.person),
      selectedIcon: Icon(Icons.person),
      label: Text('Profiles'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.extension),
      selectedIcon: Icon(Icons.extension),
      label: Text('Extensions'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _destinations,
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.code,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VSXViz',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen - Overview of all data
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<VsCodeExtension>? _extensions;
  bool _isLoading = true;
  String? _error;
  int _carouselIndex = 0;

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

      const csvPath = 'Data/vscode-extensions.csv';
      final extensions = await CsvParserService.parseExtensionsFromCsv(csvPath);
      
      setState(() {
        _extensions = extensions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }



  Map<String, int> _getTopPublishers() {
    if (_extensions == null) return {};
    
    final publishers = <String, int>{};
    for (final extension in _extensions!) {
      publishers[extension.publisher] = (publishers[extension.publisher] ?? 0) + 1;
    }
    
    final sorted = publishers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(10));
  }

  List<MapEntry<String, int>> _getTopExtensions() {
    if (_extensions == null) return [];
    
    // Group extensions by ID and count unique profiles they appear in
    final extensionProfiles = <String, Set<String>>{};
    final extensionMap = <String, VsCodeExtension>{};
    
    for (final extension in _extensions!) {
      final profileName = extension.profileName ?? 'Unknown';
      
      if (!extensionProfiles.containsKey(extension.id)) {
        extensionProfiles[extension.id] = <String>{};
        extensionMap[extension.id] = extension; // Keep one instance for display
      }
      
      extensionProfiles[extension.id]!.add(profileName);
    }
    
    // Convert to counts and sort by profile count
    final extensionCounts = extensionProfiles.map(
      (id, profiles) => MapEntry(id, profiles.length),
    );
    
    final sortedExtensions = extensionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedExtensions.take(5).toList();
  }

  int _getTotalProfileCount() {
    if (_extensions == null) return 1;
    
    final profiles = _extensions!
        .map((ext) => ext.profileName ?? 'Unknown')
        .toSet();
    
    return profiles.length;
  }

  VsCodeExtension _getExtensionById(String extensionId) {
    return _extensions!.firstWhere((ext) => ext.id == extensionId);
  }

  Map<String, int> _getPublisherStats() {
    if (_extensions == null) return {};
    
    final publisherCounts = <String, int>{};
    for (final extension in _extensions!) {
      publisherCounts[extension.publisher] = (publisherCounts[extension.publisher] ?? 0) + 1;
    }
    
    // Sort by count and get top 5
    final sortedPublishers = publisherCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top5 = sortedPublishers.take(5).toList();
    final others = sortedPublishers.skip(5).fold(0, (sum, entry) => sum + entry.value);
    
    final result = Map.fromEntries(top5);
    if (others > 0) {
      result['Others'] = others;
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExtensions,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VS Code Extension Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                        'Error loading extension data',
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
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Overview Cards
                      _buildStatsOverview(),
                      const SizedBox(height: 32),
                      
                      // Analytics Carousel
                      _buildAnalyticsCarousel(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final extensionCount = _extensions?.length ?? 0;
    final publisherCount = _getTopPublishers().length;
    final extensionsWithIcons = _extensions?.where((ext) => ext.iconPath?.isNotEmpty == true).length ?? 0;
    
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Extensions', extensionCount.toString(), Icons.extension, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('With Icons', extensionsWithIcons.toString(), Icons.image, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Publishers', publisherCount.toString(), Icons.business, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildSmallExtensionIcon(VsCodeExtension extension) {
    if (extension.iconPath != null && extension.iconPath!.isNotEmpty) {
      final iconFile = File(extension.iconPath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          iconFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildSmallFallbackIcon();
          },
        ),
      );
    }
    
    return _buildSmallFallbackIcon();
  }

  Widget _buildSmallFallbackIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF007ACC),
      ),
      child: const Icon(
        Icons.extension,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Color _getExtensionColorByPercentage(double percentage) {
    if (percentage >= 0.8) return Colors.green.shade600;    // 80%+ - Dark green
    if (percentage >= 0.6) return Colors.blue.shade600;     // 60-79% - Blue  
    if (percentage >= 0.4) return Colors.orange.shade600;   // 40-59% - Orange
    if (percentage >= 0.2) return Colors.purple.shade600;   // 20-39% - Purple
    return Colors.grey.shade600;                             // <20% - Grey
  }

  Widget _buildAnalyticsCarousel() {
    final List<String> titles = [
      'Top Extensions Across ${_getTotalProfileCount()} Profile${_getTotalProfileCount() != 1 ? 's' : ''}',
      'Extensions by Publisher'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titles[_carouselIndex],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _carouselIndex > 0 ? () {
                    setState(() {
                      _carouselIndex--;
                    });
                  } : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_carouselIndex + 1} / ${titles.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _carouselIndex < titles.length - 1 ? () {
                    setState(() {
                      _carouselIndex++;
                    });
                  } : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _carouselIndex == 0 
            ? _buildTopExtensionsView()
            : _buildPublishersChartView(),
        ),
      ],
    );
  }

  Widget _buildTopExtensionsView() {
    final topExtensions = _getTopExtensions();
    final totalProfiles = _getTotalProfileCount();
    
    return Card(
      key: const ValueKey('top-extensions'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: topExtensions.map((entry) {
            final extensionId = entry.key;
            final profileCount = entry.value;
            final extension = _getExtensionById(extensionId);
            final percentage = (profileCount / totalProfiles * 100).toStringAsFixed(0);
            final normalizedValue = profileCount / totalProfiles;
            final index = topExtensions.indexOf(entry);
            
            final color = _getExtensionColorByPercentage(normalizedValue);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: _buildSmallExtensionIcon(extension),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          extension.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          extension.publisher,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[300],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: normalizedValue,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPublishersChartView() {
    final publisherStats = _getPublisherStats();
    final totalExtensions = publisherStats.values.fold(0, (sum, count) => sum + count);
    
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.grey.shade600,
    ];

    return Card(
      key: const ValueKey('publishers-chart'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Pie Chart
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: publisherStats.entries.map((entry) {
                      final index = publisherStats.keys.toList().indexOf(entry.key);
                      final percentage = (entry.value / totalExtensions * 100);
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: entry.value.toDouble(),
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Legend
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: publisherStats.entries.map((entry) {
                  final index = publisherStats.keys.toList().indexOf(entry.key);
                  final color = colors[index % colors.length];
                  final percentage = (entry.value / totalExtensions * 100).toStringAsFixed(1);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${entry.value} ($percentage%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profiles Screen - List and manage VS Code profiles
class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        backgroundColor: Colors.transparent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VS Code Profiles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Profile management coming soon',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'View and edit your VS Code profiles here',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extensions Screen - Browse and manage extensions
class ExtensionsScreen extends StatefulWidget {
  const ExtensionsScreen({super.key});

  @override
  State<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends State<ExtensionsScreen> {
  List<VsCodeExtension>? _extensions;
  bool _isLoading = true;
  String? _error;

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
      
      setState(() {
        _extensions = extensions;
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadExtensions,
            tooltip: 'Refresh extensions',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Profile Extensions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                    Text(
                      'Found ${_extensions!.length} extensions',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _extensions!.length,
                        itemBuilder: (context, index) {
                          final extension = _extensions![index];
                          return _ExtensionCard(extension: extension);
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
}

class _ExtensionCard extends StatelessWidget {
  final VsCodeExtension extension;

  const _ExtensionCard({required this.extension});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Extension Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: _buildExtensionIcon(),
            ),
            const SizedBox(height: 8),
            // Extension Name
            Text(
              extension.displayName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Publisher
            Text(
              extension.publisher,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionIcon() {
    if (extension.iconPath != null && extension.iconPath!.isNotEmpty) {
      final iconFile = File(extension.iconPath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          iconFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        ),
      );
    }
    
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF007ACC),
      ),
      child: const Icon(
        Icons.extension,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}