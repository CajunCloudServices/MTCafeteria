part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _ReferenceHelpers on _ReferenceSheetsViewState {
  String _toTitle(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }

  String _toDayTitle(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  Widget _buildReadableLines(List<String> lines) {
    // Convert plain text lines into a readable hierarchy so the source JSON can
    // stay simple while the UI still looks intentional.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) ...[
          if (line.isEmpty)
            const SizedBox(height: 8)
          else if (line.endsWith(':'))
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Text(
                line,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123A65),
                ),
              ),
            )
          else if (line.startsWith('- '))
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '- ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(child: Text(line.substring(2))),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(line),
            ),
        ],
      ],
    );
  }

  Widget _buildReferencePanel({required String title, required Widget child}) {
    final hasTitle = title.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildReferenceTaskCard({
    required String title,
    required List<String> items,
    IconData icon = Icons.task_alt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1A4E8A)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123A65),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 7,
                    width: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A4E8A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF244668),
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceSummaryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A4E8A),
        ),
      ),
    );
  }
}
