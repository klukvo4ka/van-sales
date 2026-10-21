class SyncPolicy {
  SyncPolicy._();

  static bool shouldApplyServerRow({
    required bool localExists,
    bool localDirty = false,
    DateTime? localUpdatedAt,
    DateTime? serverUpdatedAt,
  }) {
    if (!localExists) return true;
    if (localDirty) return false;
    if (serverUpdatedAt == null || localUpdatedAt == null) return true;
    return !serverUpdatedAt.toUtc().isBefore(localUpdatedAt.toUtc());
  }

  static bool shouldPushLocalRow({
    DateTime? localUpdatedAt,
    DateTime? serverUpdatedAt,
  }) {
    if (serverUpdatedAt == null || localUpdatedAt == null) return true;
    return !serverUpdatedAt.toUtc().isAfter(localUpdatedAt.toUtc());
  }
}
