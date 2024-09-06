/* -------------------------------------------------------------- */
/* Host     : localhost                                           */
/* Port     : 3306                                                */
/* Database : wk                                                  */

SET FOREIGN_KEY_CHECKS=0;

DROP DATABASE IF EXISTS `wk`;

CREATE DATABASE `wk`
    CHARACTER SET 'utf8mb4'
    COLLATE 'utf8mb4_general_ci';

USE `wk`;

/* Dropping database objects */

DROP TABLE IF EXISTS `pedidos_produtos`;
DROP TABLE IF EXISTS `produtos`;
DROP TABLE IF EXISTS `pedidos`;
DROP TABLE IF EXISTS `clientes`;

/* Structure for the `clientes` table : */

CREATE TABLE `clientes` (
  `codigo` INTEGER NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `cidade` VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uf` CHAR(2) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY USING BTREE (`codigo`)
) ENGINE=InnoDB
AUTO_INCREMENT=21 ROW_FORMAT=DYNAMIC CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci'
;

/* Structure for the `pedidos` table : */

CREATE TABLE `pedidos` (
  `numeropedido` INTEGER NOT NULL,
  `dataemissao` DATETIME DEFAULT NULL,
  `codigocliente` INTEGER DEFAULT NULL,
  `valortotal` DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY USING BTREE (`numeropedido`),
  KEY `pedidos_fk_cdcli` USING BTREE (`codigocliente`),
  CONSTRAINT `pedidos_fk_cdcli` FOREIGN KEY (`codigocliente`) REFERENCES `clientes` (`codigo`)
) ENGINE=InnoDB
ROW_FORMAT=DYNAMIC CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci'
;

/* Structure for the `produtos` table : */

CREATE TABLE `produtos` (
  `codigo` INTEGER NOT NULL,
  `descricao` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `precovenda` DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY USING BTREE (`codigo`)
) ENGINE=InnoDB
AUTO_INCREMENT=1 ROW_FORMAT=DYNAMIC CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci'
;

/* Structure for the `pedidos_produtos` table : */

CREATE TABLE `pedidos_produtos` (
  `autoincrem` INTEGER NOT NULL AUTO_INCREMENT,
  `numeropedido` INTEGER NOT NULL,
  `codigoproduto` INTEGER NOT NULL,
  `quantidade` INTEGER DEFAULT NULL,
  `valorunitario` DECIMAL(10,2) DEFAULT NULL,
  `valortotal` DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY USING BTREE (`autoincrem`),
  KEY `pedidos_produtos_fk_numped` USING BTREE (`numeropedido`),
  KEY `pedidos_produtos_fk_cdprod` USING BTREE (`codigoproduto`),
  CONSTRAINT `pedidos_produtos_fk_cdprod` FOREIGN KEY (`codigoproduto`) REFERENCES `produtos` (`codigo`),
  CONSTRAINT `pedidos_produtos_fk_numped` FOREIGN KEY (`numeropedido`) REFERENCES `pedidos` (`numeropedido`)
) ENGINE=InnoDB
AUTO_INCREMENT=1 ROW_FORMAT=DYNAMIC CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci'
;

/* Data for the `clientes` table  (LIMIT 0,500) */

INSERT INTO `clientes` (`codigo`, `nome`, `cidade`, `uf`) VALUES
  (1,'JULIA','SÃO PAULO','SP'),
  (2,'AUGUSTO','GUARULHOS','SP'),
  (3,'SERGIO','RIO DE JANEIRO','RJ'),
  (4,'RICARDO','MINAS GERAIS','MG'),
  (5,'TANIA','MATRO GROSSO','MT'),
  (6,'AUGUSTO','GOIAS','GO'),
  (7,'JOSE','MATO GROSSO DO SUL','MS'),
  (8,'JAMILA','PARA','PA'),
  (9,'ESTELA','CEARA','CE'),
  (10,'BRUNA','ALAGOAS','AL'),
  (11,'PEDRO','BAHIA','BA'),
  (12,'ROSANA','DISTRITO FEDERAL','DF'),
  (13,'CARLOS','PARAÍBA','PB'),
  (14,'FERNANDA','MARANHAO','MA'),
  (15,'ALINE','SÃO PAULO','SP'),
  (16,'REGINALDO','GOIAS','GO'),
  (17,'ALICE','GUARULHOS','SP'),
  (18,'PAULO','BAHIA','BA'),
  (19,'ALVARO','MARANHÃO','MA'),
  (20,'DANILO','RIO DE JANEIRO','RJ');
COMMIT;

INSERT INTO `produtos` (`codigo`, `descricao`, `precovenda`) VALUES
  (1,'BICICLETA',10.50),
  (2,'TELEVISÃO',1000.22),
  (3,'MONITOR',257.25),
  (4,'NOTEBOOK',2500.78),
  (5,'RADIO',100.75),
  (6,'CADEIRA',225.85),
  (7,'COPO',10.50),
  (8,'COLHER',2.75),
  (9,'PRATO',7.84),
  (10,'FACA',2.57),
  (11,'MESA JANTAR',700.89),
  (12,'COMPUTADOR DESKTOP',1250.34),
  (13,'GELADEIRA',857.24),
  (14,'LAPIS',3.50),
  (15,'BORRACHA',2.50),
  (16,'CANECA',5.84),
  (17,'FRIGIDEIRA',150.72),
  (18,'FERRO DE PASSAR',50.00),
  (19,'LAPISEIRA',12.50),
  (20,'SOFÁ',500.77);
COMMIT;

