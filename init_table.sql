-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.1.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             9.5.0.5196
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table drp.turfs
CREATE TABLE IF NOT EXISTS `turfs` (
  `id` varchar(8) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `gang` varchar(50) DEFAULT NULL,
  `time_open` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table drp.turfs: ~17 rows (approximately)
DELETE FROM `turfs`;
/*!40000 ALTER TABLE `turfs` DISABLE KEYS */;
INSERT INTO `turfs` (`id`, `description`, `gang`, `time_open`) VALUES
	('BHAMCA', 'barbareno', NULL, '0'),
	('CHAMH', 'forum', NULL, '0'),
	('CHIL', 'casino', NULL, '0'),
	('DAVIS', 'grove', NULL, '0'),
	('DESRT', 'yellowjack', NULL, '0'),
	('EAST_V', 'citybikes', NULL, '0'),
	('KOREAT', 'seoul', NULL, '0'),
	('MTCHIL', 'weed', NULL, '0'),
	('NCHU', 'hookies', NULL, '0'),
	('PALETO', 'paleto', NULL, '0'),
	('PBLUFF', 'bluffs', NULL, '0'),
	('RANCHO', 'jamestown', NULL, '0'),
	('SANDY', 'sandyshores', NULL, '0'),
	('SLAB', 'stab', NULL, '0'),
	('STRAW', 'strawberry', NULL, '0'),
	('TONGVAH', 'vineyard', NULL, '0'),
	('WINDF', 'shitterpark', NULL, '0');
/*!40000 ALTER TABLE `turfs` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
