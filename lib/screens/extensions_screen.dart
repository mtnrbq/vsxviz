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
  bool _isLoading = true;
  String? _error;
  bool _isCompactLayout = false;

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
            icon: Icon(_isCompactLayout ? Icons.view_module : Icons.view_list),
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _isCompactLayout ? 6 : 4,
                          childAspectRatio: _isCompactLayout ? 1.0 : 1.2,
                          crossAxisSpacing: _isCompactLayout ? 8 : 16,
                          mainAxisSpacing: _isCompactLayout ? 8 : 16,
                        ),
                        itemCount: _extensions!.length,
                        itemBuilder: (context, index) {
                          final extension = _extensions![index];
                          return ExtensionCard(
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
}

