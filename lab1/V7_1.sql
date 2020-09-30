-- Creating database
CREATE DATABASE Andrei_Chuduk;
-- Setting this database as current
USE Andrei_Chuduk;
GO
-- Creating schema sales
CREATE SCHEMA sales;
GO
-- Creating schema persons
CREATE SCHEMA persons;
GO
-- Creating table sales
CREATE TABLE sales.Orders (OrderNum INT NULL);
go
-- Making backup of database 
BACKUP DATABASE Andrei_Chuduk
TO DISK = 'C:\Users\Andrei_Chuduk\Desktop\db_4_course\Andrei_Chuduk.bak';
GO
-- Deleting database
DROP DATABASE Andrei_Chuduk;
GO
-- Restoring database
RESTORE DATABASE Andrei_Chuduk
FROM DISK = 'C:\Users\Andrei_Chuduk\Desktop\db_4_course\Andrei_Chuduk.bak';
GO
