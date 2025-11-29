/* init-db.sql */

-- สร้างฐานข้อมูลพร้อมตั้งค่า recovery model เป็น SIMPLE เพื่อประหยัด log space
CREATE DATABASE [my-db];
GO

ALTER DATABASE [my-db] SET RECOVERY SIMPLE;
GO

USE [my-db];
GO

-- ปรับแต่ง Auto Shrink และ Auto Close สำหรับประหยัดทรัพยากร (ใช้เฉพาะ dev/test)
ALTER DATABASE [my-db] SET AUTO_SHRINK OFF;  -- ปิดเพื่อลดการใช้ CPU
ALTER DATABASE [my-db] SET AUTO_CLOSE OFF;   -- ปิดเพื่อไม่ให้ปิด-เปิดบ่อย
GO

-- ตั้งค่า Auto Growth ให้เหมาะสม
ALTER DATABASE [my-db] MODIFY FILE (
    NAME = N'my-db',
    FILEGROWTH = 64MB  -- เพิ่มทีละ 64MB แทนการเพิ่มแบบ percentage
);
GO

ALTER DATABASE [my-db] MODIFY FILE (
    NAME = N'my-db_log',
    FILEGROWTH = 32MB  -- เพิ่ม log ทีละ 32MB
);
GO

CREATE TABLE [User] (
  Id INT NOT NULL IDENTITY(1,1),
  FirstName VARCHAR(50) NOT null,
  LastName VARCHAR(50) NOT NULL,
  DateOfBirth DATETIME NOT NULL
  CONSTRAINT PK_User_Id PRIMARY KEY (Id ASC)
);
GO

INSERT INTO [User] VALUES ('Jose', 'Realman', '2018-01-01');
GO

-- ทำ statistics update และ index maintenance เบื้องต้น
UPDATE STATISTICS [User];
GO
