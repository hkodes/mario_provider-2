
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FunkyOverlay extends StatefulWidget {
  final String qrCodeUrl;

  FunkyOverlay(this.qrCodeUrl);

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade200,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.qrCodeUrl ?? "",
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  size: 75,
                ),
                width: 200,
                height: 200,
              ),
            ),
          ),
        ),
      ),
    );
  }
}