import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import 'drawing_reflection_screen.dart';
import '../../widgets/glass_card.dart';

class DrawingCanvasScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final bool isFreeDraw;

  const DrawingCanvasScreen({
    super.key,
    required this.session,
    required this.isFreeDraw,
  });

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  final DrawingController _drawingController = DrawingController();
  
  Color _selectedColor = Colors.black;
  double _brushSize = 4.0;
  bool _showTools = true;

  final List<Color> _zenColors = [
    Colors.black,
    const Color(0xFF4A4A4A), // Charcoal
    const Color(0xFF7D7D7D), // Grey
    const Color(0xFFD4A5A5), // Dusty Rose
    const Color(0xFF9FB1BC), // Slate Blue
    const Color(0xFF708D81), // Sage Green
    const Color(0xFFC49991), // Terracotta
    const Color(0xFFE2E2E2), // Off-white
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
  ];

  @override
  void initState() {
    super.initState();
    // Set initial paint content
    _updatePaintContent();
  }

  void _updatePaintContent() {
    _drawingController.setStyle(
      style: PaintingStyle.stroke,
      strokeWidth: _brushSize,
      color: _selectedColor,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    );
  }

  void _finishDrawing() async {
    final byteData = await _drawingController.getImageData();
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrawingReflectionScreen(
            session: widget.session,
            drawingBytes: bytes,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7), // Soft cream "paper" feel
      appBar: AppBar(
        title: Text(
          widget.isFreeDraw ? 'Free Expression' : widget.session['title'],
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, color: AppTheme.textDark),
            onPressed: () => _drawingController.undo(),
            tooltip: 'Undo',
          ),
          TextButton(
            onPressed: _finishDrawing,
            child: Text(
              'Done',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Texture/Feel
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/paper.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          Column(
            children: [
              if (!widget.isFreeDraw)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.session['description'] ?? 'Express your feelings through art.',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textDark,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: DrawingBoard(
                      controller: _drawingController,
                      background: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for floating toolbar
            ],
          ),

          // Floating Toolbar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _showTools ? 30 : -200,
            left: 20,
            right: 20,
            child: SafeArea(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color Palette
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _zenColors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                                _updatePaintContent();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: isSelected ? 36 : 28,
                              height: isSelected ? 36 : 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Brush Size & Actions
                    Row(
                      children: [
                        const Icon(Icons.brush_rounded, size: 20, color: AppTheme.textLight),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.primaryColor,
                              inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.1),
                              thumbColor: AppTheme.primaryColor,
                              overlayColor: AppTheme.primaryColor.withOpacity(0.1),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _brushSize,
                              min: 1.0,
                              max: 20.0,
                              onChanged: (value) {
                                setState(() {
                                  _brushSize = value;
                                  _updatePaintContent();
                                });
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Clear Canvas?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                content: Text('This will permanently delete your current work.', style: GoogleFonts.outfit()),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.outfit())),
                                  TextButton(
                                    onPressed: () {
                                      _drawingController.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Clear', style: GoogleFonts.outfit(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Clear All',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Toggle Tools Button
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton.small(
              onPressed: () => setState(() => _showTools = !_showTools),
              backgroundColor: Colors.white.withOpacity(0.9),
              elevation: 4,
              child: Icon(
                _showTools ? Icons.visibility_off_outlined : Icons.edit_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
