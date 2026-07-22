import 'package:flutter/material.dart';

import '../magnifier_state.dart';

class ZoomSlider extends StatelessWidget {
  const ZoomSlider({super.key, required this.state});

  final MagnifierState state;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: state.zoom,
      builder: (context, zoom, _) => SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 18),
          trackHeight: 8,
        ),
        child: Slider(
          value: zoom,
          min: state.minZoom,
          max: state.maxZoom,
          onChanged: state.setZoom,
        ),
      ),
    );
  }
}
