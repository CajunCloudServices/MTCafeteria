part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _DiningMapReferenceFlow on _ReferenceSheetsViewState {
  Widget _buildDiningMapPanel(BuildContext context) {
    // InteractiveViewer provides zoom/pan without introducing a separate map
    // library for what is ultimately a static floorplan image.
    return _buildReferencePanel(
      title: widget.useOuterCard ? 'Dining Map' : '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pinch to zoom and drag to move.',
                  style: TextStyle(
                    color: Color(0xFF355678),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    _mapTransformationController.value = Matrix4.identity(),
                icon: const Icon(Icons.center_focus_strong, size: 18),
                label: const Text('Reset View'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = MediaQuery.of(context).size.width < 760;
              final mapHeight = isMobile ? 430.0 : 640.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.white,
                  constraints: BoxConstraints(
                    minHeight: mapHeight,
                    maxHeight: mapHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: InteractiveViewer(
                    transformationController: _mapTransformationController,
                    minScale: 1.0,
                    maxScale: 6.0,
                    boundaryMargin: const EdgeInsets.all(120),
                    panEnabled: true,
                    child: Image.asset(
                      'assets/reference/MTC Dining Map (1).png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topLeft,
                      errorBuilder: (_, _, _) => const Center(
                        child: Text('Could not load dining map image.'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
