
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `transaction` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gacha_probability` (
  `gacha_id` int(11) unsigned DEFAULT NULL,
  `monster_id` int(11) DEFAULT NULL,
  `probability` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gachas` (
  `gacha_id` int(11) NOT NULL AUTO_INCREMENT,
  `gacha_name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`gacha_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_monster` (
  `user_id` int(11) unsigned NOT NULL,
  `monster_id` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  `passwd` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unko` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wallets` (
  `user_id` int(11) NOT NULL,
  `money` int(10) unsigned DEFAULT NULL,
  `gem` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;




CREATE DATABASE /*!32312 IF NOT EXISTS*/ `master` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gacha_probability` (
  `gacha_id` int(11) unsigned DEFAULT NULL,
  `monster_id` int(11) DEFAULT NULL,
  `probability` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gachas` (
  `gacha_id` int(11) NOT NULL AUTO_INCREMENT,
  `gacha_name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`gacha_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imgs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monsters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `hp` int(10) unsigned DEFAULT NULL,
  `atk` int(10) unsigned DEFAULT NULL,
  `def` int(10) unsigned DEFAULT NULL,
  `exp` int(10) unsigned DEFAULT NULL,
  `money` int(10) unsigned DEFAULT NULL,
  `img_id` int(10) unsigned DEFAULT NULL,
  `rarity` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
