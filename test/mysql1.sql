SET NAMES 'utf8' COLLATE 'utf8_general_ci';
SET CHARACTER SET 'utf8';
DROP DATABASE IF EXISTS batchertestdb;
CREATE DATABASE IF NOT EXISTS batchertestdb CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';
USE batchertestdb;
CREATE TABLE IF NOT EXISTS serialtest (pk SERIAL NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));
CREATE TABLE IF NOT EXISTS compositetest (pk1 INT NOT NULL, pk2 VARCHAR(10) NOT NULL, intcol INT, strcol VARCHAR(20), PRIMARY KEY(pk1, pk2));
DROP USER IF EXISTS 'btest'@'%';
CREATE USER IF NOT EXISTS 'btest'@'%' IDENTIFIED BY 'btest';
GRANT ALL PRIVILEGES ON *.* TO 'btest'@'%';
FLUSH PRIVILEGES;
