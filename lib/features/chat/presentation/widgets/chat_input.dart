import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInput extends StatefulWidget {
  final bool enabled;
  final void Function(String) onSend;

  const ChatInput({super.key, required this.enabled, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  late final AnimationController _sendAnim;
  late final Animation<double> _sendScale;

  @override
  void initState() {
    super.initState();
    _sendAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sendScale = CurvedAnimation(parent: _sendAnim, curve: Curves.elasticOut);
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
        has ? _sendAnim.forward() : _sendAnim.reverse();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _sendAnim.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    _ctrl.clear();
    widget.onSend(text);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? colorScheme.primary.withAlpha(120)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    _send();
                  }
                },
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: widget.enabled
                        ? 'Escribe tu consulta...'
                        : 'Procesando...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ScaleTransition(
            scale: _sendScale,
            child: _SendButton(
              active: _hasText && widget.enabled,
              onTap: _send,
            ),
          ),
          if (!_hasText || !widget.enabled)
            _MicButton(visible: !_hasText && widget.enabled),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _SendButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!active) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool visible;
  const _MicButton({required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Icon(Icons.mic_none_rounded,
            color: colorScheme.outline, size: 22),
      ),
    );
  }
}
