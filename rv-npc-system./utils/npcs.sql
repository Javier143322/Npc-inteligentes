-- TABLA 1: Memoria individual de NPCs (Rencor, CK, Nombres)
CREATE TABLE IF NOT EXISTS `rv_npcs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `npc_id` VARCHAR(100) NOT NULL,
  `name` VARCHAR(50) DEFAULT 'Ciudadano Desconocido',
  `reputation` INT(11) DEFAULT 50,
  `job` VARCHAR(50) DEFAULT 'unemployed',
  `is_dead` TINYINT(1) DEFAULT 0,
  `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `npc_id` (`npc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- TABLA 2: Reputación Global del Jugador con las Bandas
CREATE TABLE IF NOT EXISTS `player_gangs` (
  `identifier` VARCHAR(100) NOT NULL, -- Licencia o CitizenID
  `gang_name` VARCHAR(50) NOT NULL,   -- Ejemplo: 'Ballas', 'Families'
  `reputation` INT DEFAULT 50,       -- 0 Hostil, 50 Neutral, 100 Aliado
  PRIMARY KEY (`identifier`, `gang_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
