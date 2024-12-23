--
-- Table structure for table `ranking_criteria`
--

DROP TABLE IF EXISTS `ranking_criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ranking_criteria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ranking_system_id` int DEFAULT NULL,
  `criteria_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rc_rs` (`ranking_system_id`),
  CONSTRAINT `fk_rc_rs` FOREIGN KEY (`ranking_system_id`) REFERENCES `ranking_system` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `ranking_criteria` WRITE;
INSERT INTO `ranking_criteria` VALUES (1,1,'Teaching'),(2,1,'International'),(3,1,'Research'),(4,1,'Citations'),(5,1,'Income'),(6,1,'Total Times'),(7,2,'Alumni'),(8,2,'Award'),(9,2,'HiCi'),(10,2,'N and S'),(11,2,'Pub'),(12,2,'PCP'),(13,2,'Total Shanghai'),(14,3,'Quality of Education Rank'),(15,3,'Alumni Employment Rank'),(16,3,'Quality of Faculty Rank'),(17,3,'Publications Rank'),(18,3,'Influence Rank'),(19,3,'Citations Rank'),(20,3,'Patents Rank'),(21,3,'Total CWUR');
UNLOCK TABLES;
