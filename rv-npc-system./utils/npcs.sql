CREATE TABLE IF NOT EXISTS `rv_npcs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `npc_id` VARCHAR(100) NOT NULL, -- ID único basado en Red e Instancia
  `name` VARCHAR(50) DEFAULT 'Ciudadano Desconocido',
  `reputation` INT(11) DEFAULT 50, -- 0 (Odio máximo) a 100 (Amigo)
  `job` VARCHAR(50) DEFAULT 'unemployed',
  `is_dead` TINYINT(1) DEFAULT 0, -- Para el sistema de CK
  `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `npc_id` (`npc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

