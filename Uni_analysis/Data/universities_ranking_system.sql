--
-- Table structure for table `ranking_system`
--

DROP TABLE IF EXISTS `ranking_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ranking_system` (
  `id` int NOT NULL AUTO_INCREMENT,
  `system_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `ranking_system` WRITE;
INSERT INTO `ranking_system` VALUES (1,'Times Higher Education World University Ranking'),(2,'Shanghai Ranking'),(3,'Center for World University Rankings');
UNLOCK TABLES;
