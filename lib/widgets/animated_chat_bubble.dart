import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nativechat/utils/app_theme.dart';

class AnimatedChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isSystem;
  final bool isError;
  final int index;
  final VoidCallback? onTap;
  final Widget? child;

  const AnimatedChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    this.isSystem = false,
    this.isError = false,
    required this.index,
    this.onTap,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: isUser 
                    ? MainAxisAlignment.end 
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser && !isSystem) ...[
                    _buildAvatar(isDark),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: _buildBubble(context, isDark),
                  ),
                  if (isUser) ...[
                    const SizedBox(width: 8),
                    _buildUserAvatar(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, bool isDark) {
    Color bubbleColor;
    Color textColor;
    
    if (isSystem) {
      bubbleColor = isError 
          ? AppTheme.accentRed.withOpacity(0.1)
          : Colors.blue.withOpacity(0.1);
      textColor = isError 
          ? AppTheme.accentRed 
          : Colors.blue;
    } else if (isUser) {
      bubbleColor = AppTheme.primaryBlue;
      textColor = Colors.white;
    } else {
      bubbleColor = isDark 
          ? const Color(0xff1a1a1a) 
          : Colors.grey[100]!;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: isSystem ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: child ?? _buildMessageContent(textColor),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    if (isSystem) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      message,
      style: TextStyle(
        color: textColor,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.psychology,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey[600],
        size: 18,
      ),
    );
  }
}