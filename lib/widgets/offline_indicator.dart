import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bookmark_controller.dart';

/// Widget to display offline mode status and toggle it
class OfflineIndicator extends StatelessWidget {
  /// Creates a new OfflineIndicator
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookmarkController>();

    return Obx(
      () => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: controller.isOfflineMode.value
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        child: InkWell(
          onTap: controller.toggleOfflineMode,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  controller.isOfflineMode.value ? Icons.cloud_off : Icons.cloud_done,
                  color: controller.isOfflineMode.value
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.isOfflineMode.value ? 'Offline Mode' : 'Online Mode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: controller.isOfflineMode.value
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        controller.isOfflineMode.value
                            ? 'Only showing bookmarks available offline'
                            : 'All bookmarks available',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.isOfflineMode.value,
                  onChanged: (_) => controller.toggleOfflineMode(),
                  activeColor: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
