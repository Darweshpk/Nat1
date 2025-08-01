// File: lib/components/input_box.dart
import 'package:flutter/material.dart';
import 'package:nativechat/components/input_box/input_mic_button.dart';
import 'package:nativechat/components/input_box/main_text_field.dart';
import 'package:nativechat/components/input_box/send_input_button.dart';
import 'package:nativechat/components/input_box/voice_mode_button.dart';
import 'package:nativechat/components/image_generation_dialog.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:nativechat/components/attach_file_popup_menu/attach_file_popup_menu.dart';
import 'package:theme_provider/theme_provider.dart';

class InputBox extends StatefulWidget {
  const InputBox({
    super.key,
    required this.summarizeText,
    required this.chatWithAI,
    required this.onPickFile,
    required this.onPickImage,
    required this.onPickAudio,
    required this.onPickCamera,
    required this.isSummarizeInContext,
    required this.userMessageController,
    required this.toggleVoiceMode,
    required this.isInVoiceMode,
    required this.speechToText,
    required this.startListening,
    required this.stopListening,
  });

  final Function summarizeText;
  final Function chatWithAI;
  final VoidCallback onPickFile;
  final VoidCallback onPickImage;
  final VoidCallback onPickAudio;
  final VoidCallback onPickCamera;
  final bool isSummarizeInContext;
  final TextEditingController userMessageController;
  final Function toggleVoiceMode;
  final SpeechToText speechToText;
  final Function startListening;
  final Function stopListening;
  final bool isInVoiceMode;

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  void _showImageGenerator() {
    showDialog(
      context: context,
      builder: (context) => ImageGenerationDialog(
        initialPrompt: widget.userMessageController.text.trim().isNotEmpty 
            ? widget.userMessageController.text.trim() 
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.themeOf(context).id == "dark_theme";
    
    return Container(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 8.0,
        top: 2.0,
        bottom: 10.0,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        color: isDark ? Color(0xff1a1a1a) : Color(0xfff2f2f2),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainTextField(
            userMessageController: widget.userMessageController,
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side buttons
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Attach Files
                      AttachFilePopupMenu(
                        onPickFile: widget.onPickFile,
                        onPickImage: widget.onPickImage,
                        onPickAudio: widget.onPickAudio,
                        onPickCamera: widget.onPickCamera,
                      ),
                      SizedBox(width: 8),
                      // Image Generation
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _showImageGenerator,
                          icon: Icon(
                            Icons.auto_awesome,
                            color: Colors.purple,
                            size: 20,
                          ),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                          tooltip: 'Generate Image',
                        ),
                      ),
                      SizedBox(width: 8),
                      // Voice Mode
                      VoiceModeButton(
                        toggleVoiceMode: widget.toggleVoiceMode,
                        isInVoiceMode: widget.isInVoiceMode,
                      ),
                    ],
                  ),
                ),
              ),
              // Right side buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.isInVoiceMode
                      ? InputMicButton(
                          speechToText: widget.speechToText,
                          startListening: widget.startListening,
                          stopListening: widget.stopListening,
                        )
                      : Container(),
                  SendInputButton(
                    isSummarizeInContext: widget.isSummarizeInContext,
                    summarizeText: widget.summarizeText,
                    chatWithAI: widget.chatWithAI,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
