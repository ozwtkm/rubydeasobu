-- MySQL dump 10.13  Distrib 5.6.36, for Linux (x86_64)
--
-- Host: localhost    Database: master
-- ------------------------------------------------------
-- Server version	5.6.44-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `master`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `master` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `master`;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  `passwd` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unko` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `appearance_place`
--

DROP TABLE IF EXISTS `appearance_place`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `appearance_place` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dangeon_id` int(10) unsigned NOT NULL,
  `x` int(5) unsigned NOT NULL,
  `y` int(5) unsigned NOT NULL,
  `z` int(5) unsigned NOT NULL,
  `type` int(5) unsigned NOT NULL,
  `appearance_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dangeon_id` (`dangeon_id`,`x`,`y`,`z`),
  CONSTRAINT `appearance_place_ibfk_1` FOREIGN KEY (`dangeon_id`) REFERENCES `dangeons` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dangeons`
--

DROP TABLE IF EXISTS `dangeons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dangeons` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gacha_probability`
--

DROP TABLE IF EXISTS `gacha_probability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gacha_probability` (
  `gacha_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `monster_id` int(11) unsigned NOT NULL,
  `probability` int(11) unsigned NOT NULL,
  KEY `gacha_id` (`gacha_id`),
  CONSTRAINT `gacha_probability_ibfk_1` FOREIGN KEY (`gacha_id`) REFERENCES `gachas` (`gacha_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gachas`
--

DROP TABLE IF EXISTS `gachas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gachas` (
  `gacha_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `gacha_name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`gacha_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gradeup_recipes`
--

DROP TABLE IF EXISTS `gradeup_recipes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gradeup_recipes` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `material_id` int(11) unsigned NOT NULL,
  `required_number` int(11) unsigned NOT NULL,
  `obtain_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `material_id` (`material_id`),
  KEY `obtain_id` (`obtain_id`),
  CONSTRAINT `gradeup_recipes_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `monsters` (`id`),
  CONSTRAINT `gradeup_recipes_ibfk_2` FOREIGN KEY (`obtain_id`) REFERENCES `monsters` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `imgs`
--

DROP TABLE IF EXISTS `imgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imgs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `maps`
--

DROP TABLE IF EXISTS `maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `maps` (
  `dangeon_id` int(10) unsigned NOT NULL,
  `x` int(5) unsigned NOT NULL,
  `y` int(5) unsigned NOT NULL,
  `z` int(5) unsigned NOT NULL,
  `aisle` int(5) unsigned NOT NULL,
  UNIQUE KEY `dangeon_id` (`dangeon_id`,`x`,`y`,`z`),
  CONSTRAINT `maps_ibfk_1` FOREIGN KEY (`dangeon_id`) REFERENCES `dangeons` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `monsters`
--

DROP TABLE IF EXISTS `monsters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monsters` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `hp` int(10) unsigned DEFAULT NULL,
  `atk` int(10) unsigned DEFAULT NULL,
  `def` int(10) unsigned DEFAULT NULL,
  `exp` int(10) unsigned DEFAULT NULL,
  `money` int(10) unsigned DEFAULT NULL,
  `img_id` int(10) unsigned DEFAULT NULL,
  `rarity` int(5) unsigned NOT NULL,
  `speed` int(10) unsigned DEFAULT NULL,
  `mp` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Current Database: `transaction`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `transaction` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `transaction`;

--
-- Table structure for table `battle`
--

DROP TABLE IF EXISTS `battle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `battle` (
  `user_id` int(10) unsigned NOT NULL,
  `scene` int(10) unsigned NOT NULL,
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `battle_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `party`
--

DROP TABLE IF EXISTS `party`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `party` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `possession_monster_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id_2` (`user_id`,`possession_monster_id`),
  KEY `user_id` (`user_id`),
  KEY `monster_id` (`possession_monster_id`),
  CONSTRAINT `party_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `party_ibfk_2` FOREIGN KEY (`possession_monster_id`) REFERENCES `user_monster` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quest`
--

DROP TABLE IF EXISTS `quest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quest` (
  `user_id` int(11) unsigned NOT NULL,
  `dangeon_id` int(10) unsigned NOT NULL,
  `current_x` int(5) unsigned NOT NULL,
  `current_y` int(5) unsigned NOT NULL,
  `current_z` int(5) unsigned NOT NULL,
  `party_id` int(5) unsigned NOT NULL,
  `partner_monster` int(11) unsigned NOT NULL,
  `obtain_money` int(10) unsigned NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `party_id` (`party_id`),
  CONSTRAINT `quest_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `quest_ibfk_3` FOREIGN KEY (`party_id`) REFERENCES `party` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quest_acquisition`
--

DROP TABLE IF EXISTS `quest_acquisition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quest_acquisition` (
  `user_id` int(11) unsigned NOT NULL,
  `appearance_id` int(10) unsigned NOT NULL,
  `status` int(1) unsigned NOT NULL,
  KEY `user_id` (`user_id`),
  CONSTRAINT `quest_acquisition_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_monster`
--

DROP TABLE IF EXISTS `user_monster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_monster` (
  `user_id` int(11) unsigned NOT NULL,
  `monster_id` int(10) unsigned NOT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `monster_id` (`monster_id`),
  CONSTRAINT `user_monster_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=526 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  `passwd` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unko` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wallets` (
  `user_id` int(11) unsigned NOT NULL,
  `money` int(10) unsigned DEFAULT NULL,
  `gem` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `wallets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-07-05 17:50:26
