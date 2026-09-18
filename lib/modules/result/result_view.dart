
import 'dart:io';
import 'package:buna_lens/data/models/prediction.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import 'result_controller.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResultController>();
    final result = controller.result;
    final topPrediction = result.predictions.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareScan,
            tooltip: 'Share',
          ),
          Obx(() => IconButton(
                icon: controller.isDeleting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_outline),
                onPressed:
                    controller.isDeleting.value ? null : controller.deleteScan,
                tooltip: 'Delete',
              )),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImageSection(context, result),
          const SizedBox(height: 24),
          _buildResultCard(context, topPrediction, result),
          const SizedBox(height: 24),
          _buildProbabilitiesSection(context, result.predictions),
          const SizedBox(height: 24),
          _buildMetadataSection(context, result),
          const SizedBox(height: 24),
          _buildNotesSection(context, controller),
        ],
      ),
    );
  }

  // Image section with full preview
  Widget _buildImageSection(BuildContext context, dynamic result) {
    return Hero(
      tag: 'scan_image_${result.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 1,
          child: result.imagePath.isNotEmpty && !kIsWeb
              ? Image.file(
                  File(result.imagePath),
                  fit: BoxFit.cover,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.beige,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: AppColors.gray,
                  ),
                ),
        ),
      ),
    );
  }

  // Main result card with grade and confidence
  Widget _buildResultCard(
    BuildContext context,
    Prediction topPrediction,
    dynamic result,
  ) {
    final theme = Theme.of(context);
    final classColor = AppColors.getClassColor(topPrediction.label.name);
    final confidence = (topPrediction.probability * 100).toStringAsFixed(1);
    final confidenceColor =
        AppColors.getConfidenceColor(topPrediction.probability);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            classColor.withOpacity(0.15),
            classColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: classColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: classColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: classColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              topPrediction.label.icon,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: classColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.letterGrade,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            topPrediction.label.display,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: classColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topPrediction.label.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: confidenceColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: confidenceColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: confidenceColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$confidence% Confidence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: confidenceColor,
                  ),
                ),
              ],
            ),
          ),
          if (result.isOod) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Out of Distribution',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Probabilities section with bars
  Widget _buildProbabilitiesSection(
    BuildContext context,
    List<Prediction> predictions,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class Probabilities',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: predictions
                  .map((prediction) => _buildProbabilityBar(
                        context,
                        prediction,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilityBar(BuildContext context, Prediction prediction) {
    final theme = Theme.of(context);
    final classColor = AppColors.getClassColor(prediction.label.name);
    final percentage = (prediction.probability * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    prediction.label.icon,
                    color: classColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    prediction.label.display,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: classColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: prediction.probability,
              minHeight: 12,
              backgroundColor: classColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(classColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Metadata section
  Widget _buildMetadataSection(BuildContext context, dynamic result) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMetadataRow(
                  icon: Icons.access_time,
                  label: 'Scanned',
                  value: DateFormat('MMM d, yyyy • HH:mm')
                      .format(result.createdAt),
                ),
                const Divider(height: 24),
                _buildMetadataRow(
                  icon: Icons.fingerprint,
                  label: 'Scan ID',
                  value: result.id.substring(0, 8),
                ),
                if (result.syncedAt != null) ...[
                  const Divider(height: 24),
                  _buildMetadataRow(
                    icon: Icons.cloud_done,
                    label: 'Synced',
                    value: DateFormat('MMM d, yyyy • HH:mm')
                        .format(result.syncedAt!),
                  ),
                ],
                if (!result.isSynced) ...[
                  const Divider(height: 24),
                  _buildMetadataRow(
                    icon: Icons.cloud_off,
                    label: 'Status',
                    value: 'Not synced',
                    valueColor: AppColors.warning,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.coffeeBrown, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.espresso,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Notes section with editing capability — now strongly typed.
  Widget _buildNotesSection(BuildContext context, ResultController controller) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Obx(() => controller.isEditingNotes.value
                ? Row(
                    children: [
                      TextButton(
                        onPressed: controller.toggleEditNotes,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.saveNotes,
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save'),
                          )),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: controller.toggleEditNotes,
                    tooltip: 'Edit notes',
                  )),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => controller.isEditingNotes.value
                ? TextField(
                    controller: controller.notesController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Add notes about this scan...',
                      border: InputBorder.none,
                    ),
                  )
                : controller.notes.value.isEmpty
                    ? const Text(
                        'No notes added yet. Tap edit to add notes.',
                        style: TextStyle(
                          color: AppColors.gray,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(controller.notes.value)),
          ),
        ),
      ],
    );
  }
}
