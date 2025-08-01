import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nativechat/services/image_generation_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'dart:io';

class ImageGenerationDialog extends StatefulWidget {
  final String? initialPrompt;
  
  const ImageGenerationDialog({
    Key? key,
    this.initialPrompt,
  }) : super(key: key);

  @override
  State<ImageGenerationDialog> createState() => _ImageGenerationDialogState();
}

class _ImageGenerationDialogState extends State<ImageGenerationDialog> 
    with TickerProviderStateMixin {
  
  final TextEditingController _promptController = TextEditingController();
  final ImageGenerationService _imageService = ImageGenerationService.instance;
  
  String _selectedProvider = 'huggingface';
  bool _isGenerating = false;
  Uint8List? _generatedImage;
  String? _error;
  Map<String, dynamic>? _lastResult;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialPrompt != null) {
      _promptController.text = widget.initialPrompt!;
    }
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) return;
    
    setState(() {
      _isGenerating = true;
      _error = null;
      _generatedImage = null;
    });

    final result = await _imageService.generateImage(
      prompt: _promptController.text.trim(),
      provider: _selectedProvider,
      options: {
        'size': 'square_hd',
        'steps': 28,
        'guidance': 3.5,
      },
    );

    setState(() {
      _isGenerating = false;
      _lastResult = result;
      
      if (result['success']) {
        _generatedImage = result['imageBytes'];
        _fadeController.reset();
        _scaleController.reset();
        _fadeController.forward();
        _scaleController.forward();
      } else {
        _error = result['error'];
      }
    });
  }

  Future<void> _saveImage() async {
    if (_generatedImage == null) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/generated_image_$timestamp.png');
      await file.writeAsBytes(_generatedImage!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareImage() async {
    if (_generatedImage == null) return;
    
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/temp_generated_image.png');
      await file.writeAsBytes(_generatedImage!);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Generated with NativeChat: ${_promptController.text}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  void _showFullScreenImage() {
    if (_generatedImage == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _saveImage,
                icon: Icon(Icons.download, color: Colors.white),
              ),
              IconButton(
                onPressed: _shareImage,
                icon: Icon(Icons.share, color: Colors.white),
              ),
            ],
          ),
          body: PhotoView(
            imageProvider: MemoryImage(_generatedImage!),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSelector() {
    final providers = _imageService.getProviders();
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Model',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: providers.map((provider) {
              final isSelected = _selectedProvider == provider['id'];
              final isFree = provider['free'] == 'true';
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProvider = provider['id']!;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.blue.withOpacity(0.2)
                        : (isDark ? Color(0xff1a1a1a) : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.blue 
                          : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected 
                              ? Colors.blue 
                              : (isDark ? Colors.white : Colors.black87),
                          fontSize: 12,
                        ),
                      ),
                      if (isFree) ...[
                        SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'FREE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? Color(0xff0a0a0a) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Color(0xff1a1a1a) : Colors.grey[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome, color: Colors.blue, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Image Generator',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Create amazing images with AI',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider selector
                    _buildProviderSelector(),
                    
                    // Prompt input
                    Text(
                      'Describe your image',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _promptController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'A beautiful sunset over mountains, digital art style...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? Color(0xff1a1a1a) : Colors.grey[50],
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isGenerating
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Generating...'),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome),
                                  SizedBox(width: 8),
                                  Text('Generate Image'),
                                ],
                              ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Result area
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff1a1a1a) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        child: _buildResultArea(),
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

  Widget _buildResultArea() {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.waveDots(
              color: Colors.blue,
              size: 50,
            ),
            SizedBox(height: 16),
            Text(
              'Creating your masterpiece...',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Generation Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generateImage,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_generatedImage != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showFullScreenImage,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _generatedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveImage,
                        icon: Icon(Icons.download),
                        label: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareImage,
                        icon: Icon(Icons.share),
                        label: Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_lastResult?['provider'] != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Generated with ${_lastResult!['provider']} • ${_lastResult!['model'] ?? 'AI'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Your generated image will appear here',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enter a prompt and tap Generate to start',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}