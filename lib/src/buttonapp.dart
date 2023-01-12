import 'package:flutter/material.dart';

enum ButtonType { mic, switchCamera, close }

// ignore: must_be_immutable
class ProjectRawMaterialButton extends StatefulWidget {
  ProjectRawMaterialButton({
    Key? key,
    this.muted,
    required this.type,
    this.onPressed,
    this.icon,
    this.fillColor,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  bool? muted;
  final ButtonType type;
  VoidCallback? onPressed;
  IconData? icon;
  Color? fillColor;
  Color? iconColor;
  double? iconSize;

  @override
  State<ProjectRawMaterialButton> createState() =>
      _ProjectRawMaterialButtonState();
}

class _ProjectRawMaterialButtonState extends State<ProjectRawMaterialButton> {
  late bool? _muted;
  ButtonType? _type;

  @override
  void didUpdateWidget(covariant ProjectRawMaterialButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.muted != widget.muted) {
      _muted = widget.muted;
    }
  }

  @override
  void initState() {
    super.initState();
    _muted = widget.muted;
    _type = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case ButtonType.mic:
        widget.fillColor = _muted! ? Colors.blueAccent : Colors.white;
        widget.icon = _muted! ? Icons.mic_off : Icons.mic;
        widget.iconColor = _muted! ? Colors.white : Colors.blueAccent;
        widget.iconSize = 30;
        break;

      case ButtonType.close:
        widget.icon = Icons.call_end;
        widget.iconColor = Colors.white;
        widget.iconSize = 56;
        widget.fillColor = Colors.redAccent;
        break;

      default:
    }

    return RawMaterialButton(
      onPressed: widget.onPressed,
      shape: const CircleBorder(),
      elevation: 2.0,
      fillColor: widget.fillColor,
      padding: const EdgeInsets.all(7),
      child: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
    );
  }
}
