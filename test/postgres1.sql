CREATE USER btest PASSWORD 'btest';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE IF NOT EXISTS serialtest (pk SERIAL NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));
CREATE TABLE IF NOT EXISTS uuidtest (pk UUID DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));
CREATE TABLE IF NOT EXISTS compositetest (pk1 INT NOT NULL, pk2 VARCHAR(10) NOT NULL, intcol INT, strcol VARCHAR(20), PRIMARY KEY(pk1, pk2));
GRANT ALL ON batchertestdb.* TO btest;
