
import 'dart:ui';

import 'package:bitewise/utils/app_theme.dart';
import 'package:bitewise/viewmodel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/chatmessages_model.dart';
import 'package:bitewise/utils/app_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(ChatViewModel vm) async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    controller.clear();

    await vm.send(text);

    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradientColors(isDark),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              child: _blurCircle(
                color: theme.colorScheme.primary.withOpacity(0.30),
                size: 200,
              ),
            ),
            Positioned(
              top: 190,
              right: -70,
              child: _blurCircle(
                color: Colors.purple.withOpacity(isDark ? 0.22 : 0.18),
                size: 190,
              ),
            ),
            Positioned(
              bottom: -90,
              left: 30,
              child: _blurCircle(
                color: Colors.cyan.withOpacity(isDark ? 0.16 : 0.22),
                size: 190,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: _topTitle(context),
                  ),

                  Expanded(
                    child: StreamBuilder<List<ChatMessage>>(
                      stream: vm.getMessages(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: _glassBox(
                              context: context,
                              padding: const EdgeInsets.all(22),
                              borderRadius: BorderRadius.circular(26),
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          );
                        }

                        final messages = snapshot.data!;

                        scrollToBottom();

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          itemCount: messages.length + (vm.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (vm.isLoading && index == messages.length) {
                              return typingIndicator(context);
                            }

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: bubble(context, messages[index]),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      6,
                      16,
                      isKeyboardOpen ? 8 : 10,
                    ),
                    child: _inputBar(context, vm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _glassIconButton(
          context: context,
          icon: Icons.arrow_back_rounded,
          color: theme.colorScheme.primary,
          onTap: () {
            Navigator.pop(context);
          },
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _glassBox(
            context: context,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                Icon(
                  Icons.smart_toy_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  AppText.get(context, 'aiAssistant'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputBar(BuildContext context, ChatViewModel vm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.16 : 0.60),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.09),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: theme.colorScheme.primary,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: AppText.get(context, 'typeMessage'),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.48),
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(
                      isDark ? 0.055 : 0.28,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) {
                    _sendMessage(vm);
                  },
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: vm.isLoading ? null : () => _sendMessage(vm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(
                      isDark ? 0.28 : 0.20,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.65),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: theme.colorScheme.primary,
                    size: 23,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bubble(BuildContext context, ChatMessage msg) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(22),
          topRight: const Radius.circular(22),
          bottomLeft: Radius.circular(isUser ? 22 : 6),
          bottomRight: Radius.circular(isUser ? 6 : 22),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 292),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primary.withOpacity(
                      isDark ? 0.32 : 0.22,
                    )
                  : Colors.white.withOpacity(isDark ? 0.075 : 0.40),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(isUser ? 22 : 6),
                bottomRight: Radius.circular(isUser ? 6 : 22),
              ),
              border: Border.all(
                color: isUser
                    ? theme.colorScheme.primary.withOpacity(0.65)
                    : Colors.white.withOpacity(isDark ? 0.14 : 0.55),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: isUser
                        ? theme.colorScheme.primary.withOpacity(0.65)
                        : theme.colorScheme.onSurface.withOpacity(0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget typingIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: _glassBox(
          context: context,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppText.get(context, 'aiTyping'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.42),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.16 : 0.55),
                width: 1.1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _blurCircle({
    required Color color,
    required double size,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 45,
        sigmaY: 45,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _glassBox({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    BorderRadius? borderRadius,
    double? width,
    double? height,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final radius = borderRadius ?? BorderRadius.circular(18);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.42),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.16 : 0.60),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}