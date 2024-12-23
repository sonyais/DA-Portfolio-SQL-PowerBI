--
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `country` (
  `id` int NOT NULL AUTO_INCREMENT,
  `country_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `country` WRITE;
INSERT INTO `country` VALUES (1,'Argentina'),(2,'Australia'),(3,'Austria'),(4,'Bangladesh'),(5,'Belarus'),(6,'Belgium'),(7,'Brazil'),(8,'Bulgaria'),(9,'Canada'),(10,'Chile'),(11,'China'),(12,'Colombia'),(13,'Croatia'),(14,'Cyprus'),(15,'Czech Republic'),(16,'Denmark'),(17,'Egypt'),(18,'Estonia'),(19,'Finland'),(20,'France'),(21,'Germany'),(22,'Ghana'),(23,'Greece'),(24,'Hong Kong'),(25,'Hungary'),(26,'Iceland'),(27,'India'),(28,'Indonesia'),(29,'Iran'),(30,'Ireland'),(31,'Israel'),(32,'Italy'),(33,'Japan'),(34,'Jordan'),(35,'Kenya'),(36,'Latvia'),(37,'Lebanon'),(38,'Lithuania'),(39,'Luxembourg'),(40,'Macau'),(41,'Malaysia'),(42,'Mexico'),(43,'Morocco'),(44,'Netherlands'),(45,'New Zealand'),(46,'Nigeria'),(47,'Norway'),(48,'Oman'),(49,'Pakistan'),(50,'Poland'),(51,'Portugal'),(52,'Puerto Rico'),(53,'Qatar'),(54,'Romania'),(55,'Russia'),(56,'Saudi Arabia'),(57,'Serbia'),(58,'Singapore'),(59,'Slovakia'),(60,'Slovenia'),(61,'South Africa'),(62,'South Korea'),(63,'Spain'),(64,'Sweden'),(65,'Switzerland'),(66,'Taiwan'),(67,'Thailand'),(68,'Turkey'),(69,'Uganda'),(70,'Ukraine'),(71,'United Arab Emirates'),(72,'United Kingdom'),(73,'United States of America'),(74,'Uruguay');
UNLOCK TABLES;
