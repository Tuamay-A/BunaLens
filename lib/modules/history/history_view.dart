import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/grade_result.dart';
import '../../data/models/coffee_class.dart';
import 'history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          // View mode toggle
          Obx(() => IconButton(
                icon: Icon(
                  controller.viewMode.value == ViewMode.list
                      ? Icons.grid_view
                      : Icons.view_list,
                ),
                onPressed: controller.toggleViewMode,
                tooltip: controller.viewMode.value == ViewMode.list
                    ? 'Grid view'
                    : 'List view',
              )),
          // Clear history
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(context),
            tooltip: 'Clear history',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildFilterChips(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: Obx(() {
                if (controller.isLoading.value && controller.allScans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredScans.isEmpty) {
                  return _buildEmptyState(context);
                }

                return controller.viewMode.value == ViewMode.list
                    ? _buildListView(context)
                    : _buildGridView(context);
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Search bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: 'Search by class or notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.search('');
                },
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Filter chips
  Widget _buildFilterChips(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: controller.selectedFilter.value == null,
                onTap: () => controller.filterByClass(null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Premium',
                isSelected: controller.selectedFilter.value == CoffeeClass.premium,
                onTap: () => controller.filterByClass(CoffeeClass.premium),
                color: AppColors.premium,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Longberry',
                isSelected: controller.selectedFilter.value == CoffeeClass.longberry,
                onTap: () => controller.filterByClass(CoffeeClass.longberry),
                color: AppColors.longberry,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Peaberry',
                isSelected: controller.selectedFilter.value == CoffeeClass.peaberry,
                onTap: () => controller.filterByClass(CoffeeClass.peaberry),
                color: AppColors.peaberry,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Defect',
                isSelected: controller.selectedFilter.value == CoffeeClass.defect,
                onTap: () => controller.filterByClass(CoffeeClass.defect),
                color: AppColors.defect,
              ),
            ],
          )),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: color?.withOpacity(0.1),
      selectedColor: color ?? AppColors.coffeeBrown,
      checkmarkColor: isSelected ? AppColors.white : null,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : (color ?? AppColors.coffeeBrown),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  /// List view
  Widget _buildListView(BuildContext context) {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredScans.length,
          itemBuilder: (context, index) {
            final scan = controller.filteredScans[index];
            return _buildListCard(context, scan);
          },
        ));
  }

  Widget _buildListCard(BuildContext context, GradeResult scan) {
    final theme = Theme.of(context);
    final topPrediction = scan.predictions.first;
    final confidence = (topPrediction.probability * 100).toStringAsFixed(1);
    final classColor = AppColors.getClassColor(topPrediction.label.name);
    final confidenceColor = AppColors.getConfidenceColor(topPrediction.probability);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.openScanDetail(scan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Class icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: classColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  topPrediction.label.icon,
                  color: classColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topPrediction.label.display,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy • HH:mm').format(scan.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (scan.isOod) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ood.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OOD',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.ood,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Confidence badge
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$confidence%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: confidenceColor,
                      ),
                    ),
                  ),
                  if (!scan.isSynced) ...[
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.cloud_off,
                      size: 16,
                      color: AppColors.gray,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Grid view
  Widget _buildGridView(BuildContext context) {
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: controller.filteredScans.length,
          itemBuilder: (context, index) {
            final scan = controller.filteredScans[index];
            return _buildGridCard(context, scan);
          },
        ));
  }

  Widget _buildGridCard(BuildContext context, GradeResult scan) {
    final theme = Theme.of(context);
    final topPrediction = scan.predictions.first;
    final confidence = (topPrediction.probability * 100).toStringAsFixed(1);
    final classColor = AppColors.getClassColor(topPrediction.label.name);
    final confidenceColor = AppColors.getConfidenceColor(topPrediction.probability);

    return Card(
      child: InkWell(
        onTap: () => controller.openScanDetail(scan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section
              Column(
                children: [
                  // Class icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: classColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      topPrediction.label.icon,
                      color: classColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Class name
                  Text(
                    topPrediction.label.display,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  // Confidence
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$confidence%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: confidenceColor,
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom section
              Column(
                children: [
                  if (scan.isOod) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ood.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OOD',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.ood,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    DateFormat('MMM d, HH:mm').format(scan.createdAt),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  if (!scan.isSynced) ...[
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.cloud_off,
                      size: 14,
                      color: AppColors.gray,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = controller.selectedFilter.value != null || 
                       controller.searchQuery.value.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.history,
              size: 64,
              color: AppColors.gray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No results found' : 'No history yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Your scan history will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: controller.clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show clear history confirmation dialog
  Future<void> _showClearDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all scan history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (result == true) {
      await controller.clearHistory();
    }
  }
}
