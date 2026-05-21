import 'package:flutter/material.dart';
import '../../domain/entities/query_result.dart';

class ResultTableWidget extends StatefulWidget {
  final QueryResult result;
  const ResultTableWidget({super.key, required this.result});

  @override
  State<ResultTableWidget> createState() => _ResultTableWidgetState();
}

class _ResultTableWidgetState extends State<ResultTableWidget> {
  static const _pageSize = 8;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final result = widget.result;

    if (result.columns.isEmpty) return const SizedBox.shrink();

    final visibleRows =
        _expanded ? result.rows : result.rows.take(_pageSize).toList();
    final hasMore = result.rows.length > _pageSize;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TableHeader(result: result),
          const Divider(height: 1),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTable(
                  context, colorScheme, theme, result, visibleRows),
            ),
          ),
          if (hasMore) _ExpandButton(expanded: _expanded, result: result, onTap: () => setState(() => _expanded = !_expanded)),
        ],
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    QueryResult result,
    List<List<dynamic>> rows,
  ) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder(
        verticalInside: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(80),
          width: 0.5,
        ),
        horizontalInside: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(80),
          width: 0.5,
        ),
      ),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(60),
          ),
          children: result.columns.map((col) => _HeaderCell(text: col)).toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final isEven = entry.key.isEven;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven
                  ? Colors.transparent
                  : colorScheme.surfaceContainerHighest.withAlpha(60),
            ),
            children: entry.value
                .map((cell) => _DataCell(text: cell?.toString() ?? '—'))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final QueryResult result;
  const _TableHeader({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.table_chart_outlined,
              size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Resultados',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${result.rowCount} ${result.rowCount == 1 ? 'fila' : 'filas'}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  final bool expanded;
  final QueryResult result;
  final VoidCallback onTap;
  const _ExpandButton({required this.expanded, required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              expanded
                  ? 'Mostrar menos'
                  : 'Ver ${result.rows.length - 8} filas más',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
