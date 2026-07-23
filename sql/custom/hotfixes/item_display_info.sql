-- An existing table is archived (renamed), never dropped: the updater re-runs this
-- file whenever its content changes, and a DROP would take live hotfix rows with it.
SET @archive_at = DATE_FORMAT(NOW(), '%Y%m%d%H%i%s');

SET @old = (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'item_display_info');
SET @sql = IF(@old, CONCAT('RENAME TABLE `item_display_info` TO `item_display_info_deleted_', @archive_at, '`'), 'DO 0');
PREPARE archive FROM @sql; EXECUTE archive; DEALLOCATE PREPARE archive;
CREATE TABLE `item_display_info` (
  `ID` int unsigned NOT NULL DEFAULT '0',
  `GeosetGroupOverride` int NOT NULL DEFAULT '0',
  `ItemVisual` int NOT NULL DEFAULT '0',
  `ParticleColorID` int NOT NULL DEFAULT '0',
  `ItemRangedDisplayInfoID` int unsigned NOT NULL DEFAULT '0',
  `OverrideSwooshSoundKitID` int unsigned NOT NULL DEFAULT '0',
  `SheatheTransformMatrixID` int NOT NULL DEFAULT '0',
  `StateSpellVisualKitID` int NOT NULL DEFAULT '0',
  `SheathedSpellVisualKitID` int NOT NULL DEFAULT '0',
  `UnsheathedSpellVisualKitID` int unsigned NOT NULL DEFAULT '0',
  `Flags` int NOT NULL DEFAULT '0',
  `ModelResourcesID1` int unsigned NOT NULL DEFAULT '0',
  `ModelResourcesID2` int unsigned NOT NULL DEFAULT '0',
  `ModelMaterialResourcesID1` int NOT NULL DEFAULT '0',
  `ModelMaterialResourcesID2` int NOT NULL DEFAULT '0',
  `ModelType1` int NOT NULL DEFAULT '0',
  `ModelType2` int NOT NULL DEFAULT '0',
  `GeosetGroup1` int NOT NULL DEFAULT '0',
  `GeosetGroup2` int NOT NULL DEFAULT '0',
  `GeosetGroup3` int NOT NULL DEFAULT '0',
  `GeosetGroup4` int NOT NULL DEFAULT '0',
  `GeosetGroup5` int NOT NULL DEFAULT '0',
  `GeosetGroup6` int NOT NULL DEFAULT '0',
  `AttachmentGeosetGroup1` int NOT NULL DEFAULT '0',
  `AttachmentGeosetGroup2` int NOT NULL DEFAULT '0',
  `AttachmentGeosetGroup3` int NOT NULL DEFAULT '0',
  `AttachmentGeosetGroup4` int NOT NULL DEFAULT '0',
  `AttachmentGeosetGroup5` int NOT NULL DEFAULT '0',
  `AttachmentGeosetGroup6` int NOT NULL DEFAULT '0',
  `HelmetGeosetVis1` int NOT NULL DEFAULT '0',
  `HelmetGeosetVis2` int NOT NULL DEFAULT '0',
  `VerifiedBuild` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`VerifiedBuild`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
