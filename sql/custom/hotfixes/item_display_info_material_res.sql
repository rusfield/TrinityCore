-- An existing table is archived (renamed), never dropped: the updater re-runs this
-- file whenever its content changes, and a DROP would take live hotfix rows with it.
SET @archive_at = DATE_FORMAT(NOW(), '%Y%m%d%H%i%s');

SET @old = (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'item_display_info_material_res');
SET @sql = IF(@old, CONCAT('RENAME TABLE `item_display_info_material_res` TO `item_display_info_material_res_deleted_', @archive_at, '`'), 'DO 0');
PREPARE archive FROM @sql; EXECUTE archive; DEALLOCATE PREPARE archive;
CREATE TABLE `item_display_info_material_res` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `ComponentSection` tinyint NOT NULL DEFAULT '0',
  `MaterialResourcesID` int NOT NULL DEFAULT '0',
  `ItemDisplayInfoID` int unsigned NOT NULL DEFAULT '0',
  `VerifiedBuild` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`VerifiedBuild`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
