-- An existing table is archived (renamed), never dropped: the updater re-runs this
-- file whenever its content changes, and a DROP would take live hotfix rows with it.
SET @archive_at = DATE_FORMAT(NOW(), '%Y%m%d%H%i%s');

SET @old = (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'creature_display_info_geoset_data');
SET @sql = IF(@old, CONCAT('RENAME TABLE `creature_display_info_geoset_data` TO `creature_display_info_geoset_data_deleted_', @archive_at, '`'), 'DO 0');
PREPARE archive FROM @sql; EXECUTE archive; DEALLOCATE PREPARE archive;
CREATE TABLE `creature_display_info_geoset_data` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `GeosetIndex` tinyint unsigned NOT NULL DEFAULT '0',
  `GeosetValue` tinyint unsigned NOT NULL DEFAULT '0',
  `CreatureDisplayInfoID` int unsigned NOT NULL DEFAULT '0',
  `VerifiedBuild` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`VerifiedBuild`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
