/*
		Create script for hybrid database on mysql
*/
SET NAMES utf8;
SET SQL_MODE='';
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';

CREATE TABLE IF NOT EXISTS `hybrid_indexes` (
  `property_name` varchar(50) NOT NULL,
  `property_value` varchar(255) NOT NULL,
  `class_name` varchar(255) NOT NULL,
  `id` int(11) NOT NULL,
  KEY `NewIndex1` (`class_name`,`property_name`,`property_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  IF NOT EXISTS `hybrid_objects` (
  `id` int(11) NOT NULL auto_increment,
  `version` int(11) NOT NULL default '0',
  `data` text,
  `changes` text,
  `updated_at` datetime default NULL,
  `class_name` varchar(255) NOT NULL,
  `size` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `class_name` (`class_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE  IF NOT EXISTS  `hybrid_references` (
  `class_name` varchar(255) NOT NULL,
  `class_id` int(11) NOT NULL,
  `property` varchar(255) NOT NULL,
  `reference_class` varchar(255) NOT NULL,
  `reference_id` int(11) NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`id`),
  KEY `class_index` (`class_name`,`class_id`),
  KEY `ref_index` (`reference_class`,`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
