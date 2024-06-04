/*
 Navicat Premium Data Transfer

 Source Server         : [L] SQL SERVER
 Source Server Type    : SQL Server
 Source Server Version : 15002000
 Source Host           : localhost:1433
 Source Catalog        : Penjualan
 Source Schema         : dbo

 Target Server Type    : SQL Server
 Target Server Version : 15002000
 File Encoding         : 65001

 Date: 04/06/2024 18:47:51
*/


-- ----------------------------
-- Table structure for m_barang
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[m_barang]') AND type IN ('U'))
	DROP TABLE [dbo].[m_barang]
GO

CREATE TABLE [dbo].[m_barang] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [kode] varchar(10) COLLATE Latin1_General_CI_AS  NOT NULL,
  [nama] varchar(40) COLLATE Latin1_General_CI_AS  NOT NULL,
  [qty] int  NULL,
  [harga_satuan] real  NOT NULL
)
GO

ALTER TABLE [dbo].[m_barang] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for m_pelanggan
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[m_pelanggan]') AND type IN ('U'))
	DROP TABLE [dbo].[m_pelanggan]
GO

CREATE TABLE [dbo].[m_pelanggan] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [kode] varchar(10) COLLATE Latin1_General_CI_AS  NOT NULL,
  [nama] varchar(40) COLLATE Latin1_General_CI_AS  NULL
)
GO

ALTER TABLE [dbo].[m_pelanggan] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for m_supplier
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[m_supplier]') AND type IN ('U'))
	DROP TABLE [dbo].[m_supplier]
GO

CREATE TABLE [dbo].[m_supplier] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [kode] varchar(10) COLLATE Latin1_General_CI_AS  NOT NULL,
  [nama] varchar(40) COLLATE Latin1_General_CI_AS  NULL
)
GO

ALTER TABLE [dbo].[m_supplier] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for t_beli
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[t_beli]') AND type IN ('U'))
	DROP TABLE [dbo].[t_beli]
GO

CREATE TABLE [dbo].[t_beli] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [nomor] varchar(10) COLLATE Latin1_General_CI_AS  NOT NULL,
  [tgl] date  NOT NULL,
  [id_pelanggan] int  NOT NULL,
  [sub_total] real  NOT NULL,
  [diskon] real  NULL,
  [ppn] real  NOT NULL,
  [total] real  NOT NULL
)
GO

ALTER TABLE [dbo].[t_beli] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for t_item_beli
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[t_item_beli]') AND type IN ('U'))
	DROP TABLE [dbo].[t_item_beli]
GO

CREATE TABLE [dbo].[t_item_beli] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [id_beli] int  NULL,
  [id_barang] int  NULL,
  [harga] int  NULL,
  [qty] int  NULL,
  [diskon] int  NULL,
  [total] int  NULL
)
GO

ALTER TABLE [dbo].[t_item_beli] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- procedure structure for GetBarang
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[GetBarang]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[GetBarang]
GO

CREATE PROCEDURE [dbo].[GetBarang] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT id, kode, nama, qty, harga_satuan FROM m_barang;
END
GO


-- ----------------------------
-- procedure structure for GetPelanggan
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[GetPelanggan]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[GetPelanggan]
GO

CREATE PROCEDURE [dbo].[GetPelanggan] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT id, kode, nama FROM m_pelanggan;
END
GO


-- ----------------------------
-- procedure structure for FindPenjualan
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[FindPenjualan]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[FindPenjualan]
GO

CREATE PROCEDURE [dbo].[FindPenjualan] 
	@tanggal varchar, 
	@id_pelanggan int,
	@no_bon varchar,
	@id_barang int
AS
BEGIN
	DECLARE @where varchar(255);
	DECLARE @sql varchar(max);
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	if (@tanggal IS NOT NULL)
	BEGIN
		SET @where += 't_beli.tgl = '''+ @tanggal +'''';
	END;
	
	if (@id_pelanggan IS NOT NULL)
	BEGIN
		IF LEN(@where) > 0
		BEGIN
			SET @where += ' AND ';
		END;
		SET @where += 't_beli.id_pelanggan = '+ @id_pelanggan;
	END;
	
	if (@no_bon IS NOT NULL)
	BEGIN
		IF LEN(@where) > 0
		BEGIN
			SET @where += ' AND ';
		END;
		SET @where += 't_beli.nomor = '''+ @no_bon +'''';
	END;
	
	if (@id_barang IS NOT NULL)
	BEGIN
		IF LEN(@where) > 0
		BEGIN
			SET @where += ' AND ';
		END;
		SET @where += 'EXISTS(SELECT 1 FROM t_item_beli WHERE id_beli = t_beli.id AND id_barang = '+@id_barang+')';
	END;

    -- Insert statements for procedure here
	SET @sql = 'SELECT t_beli.id AS id_beli, 
		t_beli.nomor, 
		m_pelanggan.nama,
		(SELECT COUNT(id) FROM t_item_beli WHERE id_beli = t_beli.id) AS total_item,
		t_beli.sub_total,
		t_beli.diskon,
		t_beli.ppn,
		t_beli.total
	FROM t_beli 
		INNER JOIN m_pelanggan ON m_pelanggan.id = t_beli.id_pelanggan
	WHERE 1=1 ' + @where; 

	EXEC(@sql);
END
GO


-- ----------------------------
-- procedure structure for GetPenjualan
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[GetPenjualan]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[GetPenjualan]
GO

CREATE PROCEDURE [dbo].[GetPenjualan]
	@id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT id, nomor, tgl, id_pelanggan, sub_total, diskon, ppn, total 
	FROM t_beli
	WHERE id = @id;
END
GO


-- ----------------------------
-- procedure structure for GetItemPenjualan
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[GetItemPenjualan]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[GetItemPenjualan]
GO

CREATE PROCEDURE [dbo].[GetItemPenjualan]
	@id_beli int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TOP (1000) [id]
      ,[id_beli]
      ,[id_barang]
      ,[harga]
      ,[qty]
      ,[diskon]
      ,[total]
	FROM [Penjualan].[dbo].[t_item_beli]
	WHERE [id_beli] = @id_beli;
END
GO


-- ----------------------------
-- Auto increment value for m_barang
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[m_barang]', RESEED, 2)
GO


-- ----------------------------
-- Primary Key structure for table m_barang
-- ----------------------------
ALTER TABLE [dbo].[m_barang] ADD CONSTRAINT [PK__m_barang__3213E83F2EC8389E] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for m_pelanggan
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[m_pelanggan]', RESEED, 2)
GO


-- ----------------------------
-- Primary Key structure for table m_pelanggan
-- ----------------------------
ALTER TABLE [dbo].[m_pelanggan] ADD CONSTRAINT [PK__m_pelang__3213E83F1A711462] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for m_supplier
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[m_supplier]', RESEED, 2)
GO


-- ----------------------------
-- Auto increment value for t_beli
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[t_beli]', RESEED, 1)
GO


-- ----------------------------
-- Indexes structure for table t_beli
-- ----------------------------
CREATE NONCLUSTERED INDEX [id_pelanggan]
ON [dbo].[t_beli] (
  [id_pelanggan] ASC
)
GO

CREATE NONCLUSTERED INDEX [tanggal]
ON [dbo].[t_beli] (
  [tgl] ASC
)
GO


-- ----------------------------
-- Primary Key structure for table t_beli
-- ----------------------------
ALTER TABLE [dbo].[t_beli] ADD CONSTRAINT [PK__t_beli__3213E83FF5AA342D] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for t_item_beli
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[t_item_beli]', RESEED, 1)
GO


-- ----------------------------
-- Indexes structure for table t_item_beli
-- ----------------------------
CREATE NONCLUSTERED INDEX [id_beli]
ON [dbo].[t_item_beli] (
  [id_beli] ASC
)
GO

CREATE NONCLUSTERED INDEX [id_barang]
ON [dbo].[t_item_beli] (
  [id_barang] ASC
)
GO


-- ----------------------------
-- Primary Key structure for table t_item_beli
-- ----------------------------
ALTER TABLE [dbo].[t_item_beli] ADD CONSTRAINT [PK__t_item_b__3213E83F5EA90AB3] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Foreign Keys structure for table t_item_beli
-- ----------------------------
ALTER TABLE [dbo].[t_item_beli] ADD CONSTRAINT [id_beli] FOREIGN KEY ([id_beli]) REFERENCES [dbo].[t_beli] ([id]) ON DELETE NO ACTION ON UPDATE CASCADE
GO

ALTER TABLE [dbo].[t_item_beli] ADD CONSTRAINT [id_barang] FOREIGN KEY ([id_barang]) REFERENCES [dbo].[m_barang] ([id]) ON DELETE SET NULL ON UPDATE CASCADE
GO

