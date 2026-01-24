import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brahmakosh/common/models/sponsor_model.dart';

class SponsorLogoTicker extends StatefulWidget {
  final List<Sponsor> sponsors;
  final double height;

  const SponsorLogoTicker({
    super.key,
    required this.sponsors,
    this.height = 80,
  });

  @override
  State<SponsorLogoTicker> createState() => _SponsorLogoTickerState();
}

class _SponsorLogoTickerState extends State<SponsorLogoTicker> {
  late final ScrollController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    /// 🔥 smooth auto scroll
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_controller.hasClients) return;

      _controller.jumpTo(
        _controller.offset + 1.8, // 👈 speed control (0.4 = slower)
      );

      if (_controller.offset >= _controller.position.maxScrollExtent) {
        _controller.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launch(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.sponsors.length * 2, // 🔁 infinite feel
        itemBuilder: (context, index) {
          final sponsor = widget.sponsors[index % widget.sponsors.length];

          return InkWell(
            onTap: () => _launch(sponsor.website),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  sponsor.logo?.isNotEmpty == true
                      ? Image.network(
                          sponsor.logo!,
                          height: 44,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.handshake, color: Colors.white),
                  if (sponsor.name?.isNotEmpty == true) ...[
                    const SizedBox(width: 12),
                    Text(
                      sponsor.name!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
