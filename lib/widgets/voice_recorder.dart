import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nativechat/utils/app_theme.dart';

class VoiceRecorder extends StatefulWidget {
  final bool isListening;
  final bool isInVoiceMode;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final VoidCallback onToggleVoiceMode;
  final String? recognizedText;

  const VoiceRecorder({
    Key? key,
    required this.isListening,
    required this.isInVoiceMode,
    required this.onStartListening,
    required this.onStopListening,
    required this.onToggleVoiceMode,
    this.recognizedText,
  }) : super(key: key);

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVoiceModeToggle(isDark),
          if (widget.isInVoiceMode) ...[
            const SizedBox(height: 16),
            _buildVoiceRecorder(isDark),
            if (widget.recognizedText?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _buildRecognizedText(isDark),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceModeToggle(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.mic,
          color: widget.isInVoiceMode ? AppTheme.accentGreen : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Voice Mode',
          style: AppTheme.bodyMedium.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Switch(
          value: widget.isInVoiceMode,
          onChanged: (_) => widget.onToggleVoiceMode(),
          activeColor: AppTheme.accentGreen,
        ),
      ],
    );
  }

  Widget _buildVoiceRecorder(bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: widget.isListening 
              ? widget.onStopListening 
              : widget.onStartListening,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.isListening
                            ? const LinearGradient(
                                colors: [AppTheme.accentRed, Color(0xffff5722)],
                              )
                            : const LinearGradient(
                                colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                              ),
                        boxShadow: widget.isListening
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentRed.withOpacity(0.3),
                                  blurRadius: 20 * _pulseAnimation.value,
                                  spreadRadius: 5 * _pulseAnimation.value,
                                ),
                              ]
                            : AppTheme.elevatedShadow,
                      ),
                      child: Icon(
                        widget.isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.isListening ? 'Listening...' : 'Tap to speak',
          style: AppTheme.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.isListening) ...[
          const SizedBox(height: 8),
          LoadingAnimationWidget.waveDots(
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ],
      ],
    );
  }

  Widget _buildRecognizedText(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[900] : Colors.grey[100])?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Recognized:',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.recognizedText!,
            style: AppTheme.bodyMedium.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}