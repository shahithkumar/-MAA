import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SOSButtonWidget extends StatefulWidget {
  final Function(String) onTriggered;

  const SOSButtonWidget({super.key, required this.onTriggered});

  @override
  _SOSButtonWidgetState createState() => _SOSButtonWidgetState();
}

class _SOSButtonWidgetState extends State<SOSButtonWidget> with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  late AnimationController _controller;
  Timer? _holdTimer;
  bool _isHolding = false;
  bool _isTriggered = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _controller.addListener(() {
      setState(() {});
      if (_controller.isCompleted && !_isTriggered) {
        _triggerSOS();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    setState(() {
      _isTriggered = true;
    });
    try {
      String? location;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          location = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
        }
      }

      final response = await _apiService.triggerSOS(location: location);
      HapticFeedback.heavyImpact();
      // if (!kIsWeb) {
      //   _vibrate(FeedbackType.success);
      // }
      widget.onTriggered(response['guardian_name']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS sent to ${response['guardian_name']}', style: GoogleFonts.outfit())),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to send SOS: $e';
          _isTriggered = false;
        });
        HapticFeedback.vibrate();
        // if (!kIsWeb) {
        //   _vibrate(FeedbackType.error);
        // }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!, style: GoogleFonts.outfit()), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  // Future<void> _vibrate(FeedbackType type) async {
  //   if (await Vibrate.canVibrate) {
  //     Vibrate.feedback(type);
  //   }
  // }

  Future<void> _startHold() async {
    setState(() {
      _isHolding = true;
      _errorMessage = null;
    });
    _controller.reset();
    _controller.forward();
    _holdTimer = Timer(const Duration(seconds: 5), () {});
    HapticFeedback.selectionClick();
    // if (!kIsWeb) {
    //   await _vibrate(FeedbackType.light);
    // }
  }

  Future<void> _cancelHold() async {
    if (_isHolding && !_isTriggered) {
      _controller.stop();
      _controller.reset();
      setState(() {
        _isHolding = false;
      });
      HapticFeedback.mediumImpact();
      // if (!kIsWeb) {
      //   await _vibrate(FeedbackType.warning);
      // }
      if (mounted && _controller.value < 0.95) { // Only show if not almost done
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hold cancelled', style: GoogleFonts.outfit())),
        );
      }
    } else if (_isTriggered) {
       setState(() {
        _isHolding = false;
        _isTriggered = false; // Reset for next time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) async => await _startHold(),
      onLongPressEnd: (_) async => await _cancelHold(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: _isHolding ? 110 : 90,
            height: _isHolding ? 110 : 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.25),
                  blurRadius: 25,
                  spreadRadius: _isHolding ? 15 : 5,
                )
              ],
            ),
          ),
          
          // Main Button
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFEF5350), Color(0xFFC62828)], // Soft butALERT red
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                 BoxShadow(
                   color: Colors.red.withOpacity(0.4),
                   blurRadius: 15,
                   offset: const Offset(0, 6),
                 ),
                 // Glass highlight
                 BoxShadow(
                   color: Colors.white.withOpacity(0.25),
                   blurRadius: 4,
                   offset: const Offset(-2, -2),
                 )
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SOS',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Progress Ring
          if (_isHolding)
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: _controller.value,
                strokeWidth: 5,
                color: Colors.white.withOpacity(0.9),
                strokeCap: StrokeCap.round,
              ),
            ),
            
          // Countdown Text
          if (_isHolding)
            Positioned(
              bottom: -35,
              child: Text(
                'Hold for ${5 - (_controller.value * 5).floor()}s',
                style: GoogleFonts.outfit(
                  color: AppTheme.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}