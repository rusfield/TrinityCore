-- An existing table is archived (renamed), never dropped: the updater re-runs this
-- file whenever its content changes, and a DROP would take live hotfix rows with it.
SET @archive_at = DATE_FORMAT(NOW(), '%Y%m%d%H%i%s');

SET @old = (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'anim_kit_segment');
SET @sql = IF(@old, CONCAT('RENAME TABLE `anim_kit_segment` TO `anim_kit_segment_deleted_', @archive_at, '`'), 'DO 0');
PREPARE archive FROM @sql; EXECUTE archive; DEALLOCATE PREPARE archive;
CREATE TABLE `anim_kit_segment` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `ParentAnimKitID` smallint unsigned NOT NULL DEFAULT '0',
  `OrderIndex` tinyint unsigned NOT NULL DEFAULT '0',
  `AnimID` smallint NOT NULL DEFAULT '0',
  `AnimStartTime` int unsigned NOT NULL DEFAULT '0',
  `AnimKitConfigID` smallint unsigned NOT NULL DEFAULT '0',
  `StartCondition` tinyint unsigned NOT NULL DEFAULT '0',
  `StartConditionParam` tinyint unsigned NOT NULL DEFAULT '0',
  `StartConditionDelay` int unsigned NOT NULL DEFAULT '0',
  `EndCondition` tinyint unsigned NOT NULL DEFAULT '0',
  `EndConditionParam` int unsigned NOT NULL DEFAULT '0',
  `EndConditionDelay` int unsigned NOT NULL DEFAULT '0',
  `Speed` float NOT NULL DEFAULT '0',
  `SegmentFlags` int NOT NULL DEFAULT '0',
  `ForcedVariation` tinyint unsigned NOT NULL DEFAULT '0',
  `OverrideConfigFlags` int NOT NULL DEFAULT '0',
  `LoopToSegmentIndex` tinyint NOT NULL DEFAULT '0',
  `BlendInTimeMs` smallint unsigned NOT NULL DEFAULT '0',
  `BlendOutTimeMs` smallint unsigned NOT NULL DEFAULT '0',
  `Field_9_0_1_34278_018` float NOT NULL DEFAULT '0',
  `VerifiedBuild` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`VerifiedBuild`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
