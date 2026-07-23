-- An existing table is archived (renamed), never dropped: the updater re-runs this
-- file whenever its content changes, and a DROP would take live hotfix rows with it.
SET @archive_at = DATE_FORMAT(NOW(), '%Y%m%d%H%i%s');

SET @old = (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_model_item_slot_display_info');
SET @sql = IF(@old, CONCAT('RENAME TABLE `npc_model_item_slot_display_info` TO `npc_model_item_slot_display_info_deleted_', @archive_at, '`'), 'DO 0');
PREPARE archive FROM @sql; EXECUTE archive; DEALLOCATE PREPARE archive;
CREATE TABLE `npc_model_item_slot_display_info` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `ItemDisplayInfoID` int NOT NULL DEFAULT '0',
  `ItemSlot` tinyint NOT NULL DEFAULT '0',
  `NpcModelID` int unsigned NOT NULL DEFAULT '0',
  `VerifiedBuild` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`VerifiedBuild`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
