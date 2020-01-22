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
-- Dumping data for table `admin_users`
--

LOCK TABLES `admin_users` WRITE;
/*!40000 ALTER TABLE `admin_users` DISABLE KEYS */;
INSERT INTO `admin_users` VALUES (1,'admin','43e5241686c134792fa4ieeeeeeeeei','fa86e1f7f588a034947faf69f7fe8a95cc1c95c4');
/*!40000 ALTER TABLE `admin_users` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appearance_place`
--

LOCK TABLES `appearance_place` WRITE;
/*!40000 ALTER TABLE `appearance_place` DISABLE KEYS */;
INSERT INTO `appearance_place` VALUES (1,1,1,1,1,1,14),(2,1,2,2,1,2,1),(3,1,0,2,1,3,1);
/*!40000 ALTER TABLE `appearance_place` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `dangeons`
--

LOCK TABLES `dangeons` WRITE;
/*!40000 ALTER TABLE `dangeons` DISABLE KEYS */;
INSERT INTO `dangeons` VALUES (1,'井上の洞窟');
/*!40000 ALTER TABLE `dangeons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `kind` int(5) unsigned NOT NULL,
  `value` int(10) DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
INSERT INTO `equipment` VALUES (1,'ダンジョン出口',2,NULL);
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `gacha_probability`
--

LOCK TABLES `gacha_probability` WRITE;
/*!40000 ALTER TABLE `gacha_probability` DISABLE KEYS */;
INSERT INTO `gacha_probability` VALUES (2,5,70000),(2,12,20000),(2,11,9000),(2,10,1000);
/*!40000 ALTER TABLE `gacha_probability` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `gachas`
--

LOCK TABLES `gachas` WRITE;
/*!40000 ALTER TABLE `gachas` DISABLE KEYS */;
INSERT INTO `gachas` VALUES (1,'monster'),(2,'当てろ！りょうやん！ガチャ');
/*!40000 ALTER TABLE `gachas` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `gradeup_recipes`
--

LOCK TABLES `gradeup_recipes` WRITE;
/*!40000 ALTER TABLE `gradeup_recipes` DISABLE KEYS */;
INSERT INTO `gradeup_recipes` VALUES (1,'井上2でなみえる1',5,2,14),(2,'井上2でうんこ1',5,2,12);
/*!40000 ALTER TABLE `gradeup_recipes` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `imgs`
--

LOCK TABLES `imgs` WRITE;
/*!40000 ALTER TABLE `imgs` DISABLE KEYS */;
/*!40000 ALTER TABLE `imgs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `kind` int(5) unsigned NOT NULL,
  `value` int(10) unsigned NOT NULL,
  `img_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES (1,'薬草',2,10,100),(2,'100money',1,100,101);
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `maps`
--

LOCK TABLES `maps` WRITE;
/*!40000 ALTER TABLE `maps` DISABLE KEYS */;
INSERT INTO `maps` VALUES (1,0,0,1,4),(1,0,0,19,12),(1,0,1,1,13),(1,0,1,19,1),(1,0,2,1,9),(1,1,0,19,10),(1,1,1,1,14),(1,1,2,1,11),(1,2,0,19,10),(1,2,1,1,6),(1,2,2,1,3),(1,3,0,19,2);
/*!40000 ALTER TABLE `maps` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `monsters`
--

LOCK TABLES `monsters` WRITE;
/*!40000 ALTER TABLE `monsters` DISABLE KEYS */;
INSERT INTO `monsters` VALUES (5,'inoue',2,1,2,0,3,1,0,1,700),(10,'りょうやん',75442,84325,66431,64323,24124,4,3,4,7),(11,'dragon',1000,1000,1000,1000,1000,3,2,4,7),(12,'aaaaaaaaaaa',100,100,100,100,100,2,1,4,7),(13,'ドノバン',1,1,1,1,999999,5,3,4,7),(14,'なみえる',50,6,4,1,33,6,1,4,7);
/*!40000 ALTER TABLE `monsters` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-12-07  4:10:08
