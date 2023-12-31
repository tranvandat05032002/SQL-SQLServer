USE [master]
GO
/****** Object:  Database [21T1020285_mau1]    Script Date: 24/12/2023 7:16:30 PM ******/
CREATE DATABASE [21T1020285_mau1]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'21T1020285', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.TRANVANDATDEV\MSSQL\DATA\21T1020285.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'21T1020285_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.TRANVANDATDEV\MSSQL\DATA\21T1020285_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [21T1020285_mau1] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [21T1020285_mau1].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [21T1020285_mau1] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET ARITHABORT OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [21T1020285_mau1] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [21T1020285_mau1] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET  DISABLE_BROKER 
GO
ALTER DATABASE [21T1020285_mau1] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [21T1020285_mau1] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [21T1020285_mau1] SET  MULTI_USER 
GO
ALTER DATABASE [21T1020285_mau1] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [21T1020285_mau1] SET DB_CHAINING OFF 
GO
ALTER DATABASE [21T1020285_mau1] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [21T1020285_mau1] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [21T1020285_mau1] SET DELAYED_DURABILITY = DISABLED 
GO
USE [21T1020285_mau1]
GO
/****** Object:  User [user_21T1020285]    Script Date: 24/12/2023 7:16:30 PM ******/
CREATE USER [user_21T1020285] FOR LOGIN [user_21T1020285] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  UserDefinedFunction [dbo].[func_TKeDuAn_DayDuCacNam]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[func_TKeDuAn_DayDuCacNam] (
					@TuNam int,
					@DenNam int
				)
returns @tbl_TK_DuAn table (
			Nam_ThucHien int primary key,
			SL_DuAn int
		)
as
begin
	-- Tinh so luong trong khoang nam do sau do insert
	insert into @tbl_TK_DuAn(Nam_ThucHien, SL_DuAn)
	select YEAR(d.NgayBatDau) as Nam_Thuc_Hien, COUNT(*) as tk_duan
	from DuAn as d
	where YEAR(d.NgayBatDau) between @TuNam and @DenNam
	group by YEAR(d.NgayBatDau)
	-- Liet ke ra het nam trong khoang nam do va sao do insert vao nhung nam khong co trong bang
	declare @currentYear int = @TuNam
	while @currentYear <= @DenNam
		begin
			if not exists(select * from @tbl_TK_DuAn as t where t.Nam_ThucHien = @currentYear)
				insert into @tbl_TK_DuAn(Nam_ThucHien, SL_DuAn) values(@currentYear, 0)

				set @currentYear += 1
		end
	return;
end

GO
/****** Object:  Table [dbo].[DuAn]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DuAn](
	[MaDuAn] [nvarchar](50) NOT NULL,
	[TenDuAn] [nvarchar](255) NOT NULL,
	[NgayBatDau] [date] NOT NULL,
	[SoNguoiThamGia] [int] NOT NULL,
 CONSTRAINT [PK_DuAn] PRIMARY KEY CLUSTERED 
(
	[MaDuAn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien](
	[MaNhanVien] [nvarchar](255) NOT NULL,
	[HoTen] [nvarchar](50) NOT NULL,
	[NgaySinh] [date] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[DiDong] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_NhanVien] PRIMARY KEY CLUSTERED 
(
	[MaNhanVien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NhanVien_DuAn]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien_DuAn](
	[MaNhanVien] [nvarchar](50) NOT NULL,
	[MaDuAn] [nvarchar](50) NOT NULL,
	[NgayGiaoViec] [date] NOT NULL,
	[MoTaCongViec] [nvarchar](50) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[func_TKeDuAn]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[func_TKeDuAn] (
					@TuNam int,
					@DenNam int
				)
returns table
as
	return (
		select YEAR(d.NgayBatDau) as Nam_Thuc_Hien, COUNT(*) as tk_duan
		from DuAn as d
		where YEAR(d.NgayBatDau) between @TuNam and @DenNam
		group by YEAR(d.NgayBatDau)
	)

GO
INSERT [dbo].[DuAn] ([MaDuAn], [TenDuAn], [NgayBatDau], [SoNguoiThamGia]) VALUES (N'DA001', N'SmartUni', CAST(N'2022-01-01' AS Date), 2)
INSERT [dbo].[DuAn] ([MaDuAn], [TenDuAn], [NgayBatDau], [SoNguoiThamGia]) VALUES (N'DA002', N'E-Shop', CAST(N'2022-05-01' AS Date), 2)
INSERT [dbo].[DuAn] ([MaDuAn], [TenDuAn], [NgayBatDau], [SoNguoiThamGia]) VALUES (N'DA003', N'LiteCMS', CAST(N'2022-09-01' AS Date), 4)
INSERT [dbo].[DuAn] ([MaDuAn], [TenDuAn], [NgayBatDau], [SoNguoiThamGia]) VALUES (N'DA004', N'TheTime-Coffee', CAST(N'2023-10-20' AS Date), 2)
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV001', N'Nguyễn Thanh An', CAST(N'1980-12-01' AS Date), N'thanhan@gmail.com', N'0914422578')
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV002', N'Trần Chí Hiếu', CAST(N'1985-05-17' AS Date), N'hieu85@gmail.com', N'0987454125')
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV003', N'Vũ Thành Chung', CAST(N'1985-11-20' AS Date), N'chungvt@gmail.com', N'0935254771')
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV005', N'Lê Thị Hải Yến', CAST(N'1986-08-14' AS Date), N'lthyen@gmail.com', N'0983120547')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV001', N'DA001', CAST(N'2023-12-24' AS Date), N'Ngay mai DA001')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV008', N'DA001', CAST(N'2023-12-24' AS Date), N'Ngay mai DA001')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV008', N'DA005', CAST(N'2023-12-24' AS Date), N'Ngay mai DA001')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV008', N'DA003', CAST(N'2023-12-24' AS Date), N'Ngay mai DA001')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV008', N'DA003', CAST(N'2023-12-24' AS Date), N'Ngay mai DA001')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV005', N'DA003', CAST(N'2023-12-24' AS Date), N'Ngay mai DA001')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV003', N'DA002', CAST(N'2023-12-24' AS Date), N'Lạnh quá nên tuyển dự án')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV001', N'DA003', CAST(N'2023-12-24' AS Date), N'Du an ngon')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV002', N'DA002', CAST(N'2023-12-23' AS Date), N'Hôm nay trời rét')
/****** Object:  StoredProcedure [dbo].[proc_DuAn_DanhSachNhanVien]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[proc_DuAn_DanhSachNhanVien] (
					@TenDuAn nvarchar(255),
					@NgayGiaoViec date
				)
as
begin
	set nocount on;
	select nv.MaNhanVien, nv.HoTen, nv.Email, nv.DiDong, nd.NgayGiaoViec, nd.MoTaCongViec
	from (DuAn as d
	join NhanVien_DuAn as nd
	on d.MaDuAn = nd.MaDuAn )
	inner join NhanVien as nv
	on nd.MaNhanVien = nv.MaNhanVien
	where d.TenDuAn like '%' + @TenDuAn + '%'
	
	and nd.NgayGiaoViec < @NgayGiaoViec
end

GO
/****** Object:  StoredProcedure [dbo].[proc_NhanVien_DuAn_Insert]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[proc_NhanVien_DuAn_Insert] (
					@MaNhanVien nvarchar(50),
					@MaDuAn nvarchar(50),
					@MoTaCongViec nvarchar(255),
					@KetQua nvarchar(255) output
				)
as
begin
	if not exists(select 1 from DuAn as d where d.MaDuAn = @MaDuAn)
		begin
			set @KetQua = N'Mã dự án không tồn tại!!!'
			raiserror(@ketQua, 16, 1)
			return;
		end
	if not exists(select 1 from NhanVien as n where n.MaNhanVien = @MaNhanVien)
		begin
			set @KetQua = N'Mã nhan vien không tồn tại!!!'
			raiserror(@ketQua, 16, 1)
			return;
		end

	insert into NhanVien_DuAn(MaDuAn, MaNhanVien, MoTaCongViec, NgayGiaoViec)
	values(@MaDuAn, @MaNhanVien, @MoTaCongViec, GETDATE());

	declare @check_status int;
	set @check_status = @@ROWCOUNT

	if @check_status is not null
		begin
			set @KetQua = N''
			return;
		end
	else
		begin
			set @KetQua = N'Đã xảy ra lỗi'
			raiserror(@KetQua, 16, 1)
			return;
		end
end

GO
/****** Object:  StoredProcedure [dbo].[proc_NhanVien_TimKiem]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[proc_NhanVien_TimKiem] (
					@Trang int = 1,
					@SoDongMoiTrang int = 20,
					@HoTen nvarchar(50) = N'',
					@Tuoi int,
					@SoLuong int output
				)
as
begin
	set nocount on;

	select n.MaNhanVien, n.HoTen, n.NgaySinh, datediff(YEAR, n.NgaySinh, getdate()) as Tuoi, n.Email, n.DiDong
	into #temp_nhanvien
	from NhanVien as n
	where ( @HoTen = N'' and DATEDIFF(YEAR, n.NgaySinh, GETDATE()) >= @Tuoi)
	or (n.HoTen like '%' + @HoTen + '%' and DATEDIFF(YEAR, n.NgaySinh, GETDATE()) >= @Tuoi)

	declare @row_count int = @@ROWCOUNT

	set @SoLuong = @row_count / @SoDongMoiTrang
	if(@row_count % @SoDongMoiTrang > 0)
		set @SoLuong += 1
	select @SoLuong as SoLuong
	;with cte_1 as (
		select *, ROW_NUMBER() over(order by MaNhanVien desc) as RowNumber
		from #temp_nhanvien
	),
	cte_2 as (
		select *
		from cte_1
		where cte_1.RowNumber between @Trang * @SoDongMoiTrang - @SoDongMoiTrang + 1 and @Trang * @SoDongMoiTrang
	)
	select cte_2.MaNhanVien, cte_2.HoTen, cte_2.NgaySinh, cte_2.Tuoi, cte_2.Email, cte_2.DiDong
	from cte_2 join NhanVien as nv
	on cte_2.MaNhanVien = nv.MaNhanVien
end

GO
/****** Object:  StoredProcedure [dbo].[proc_ThongKeGiaoViec]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[proc_ThongKeGiaoViec] (
					@MaDuAn nvarchar(50),
					@TuNgay date,
					@DenNgay date
				)
as
begin
	set nocount on;

	;with cte_ngay as (
		select @TuNgay as ngay
		union all
		select dateadd(day, 1, cte_1.ngay)
		from cte_ngay as cte_1
		where cte_1.ngay < @DenNgay
	), cte_duAn as (
		select nd.NgayGiaoViec, count(*) as soluong_duan
		from NhanVien_DuAn as nd
		group by nd.NgayGiaoViec
	)
	select cte_1.ngay, isnull(cte_2.soluong_duan, 0) as SoLuong_DuAn
	from cte_ngay as cte_1
	left join cte_duAn as cte_2
	on cte_1.ngay = cte_2.NgayGiaoViec
	OPTION(maxrecursion 0)
end

GO
/****** Object:  Trigger [dbo].[trg_NhanVien_DuAn_Insert]    Script Date: 24/12/2023 7:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create trigger [dbo].[trg_NhanVien_DuAn_Insert]
on [dbo].[NhanVien_DuAn]
for insert
as
begin
	if exists(
		select 1 
		from inserted as i 
		where i.MaDuAn not in (select d.MaDuAn from DuAn as d) 
		or i.MaNhanVien not in (select n.MaNhanVien from NhanVien as n))
	begin
		rollback transaction;
	end
	update d
	set d.SoNguoiThamGia += (
								select COUNT(*)
								from inserted as i
								join DuAn as d
								on i.MaDuAn = d.MaDuAn
							)
	from DuAn as d
	join inserted as i
	on d.MaDuAn = i.MaDuAn
end

GO
USE [master]
GO
ALTER DATABASE [21T1020285_mau1] SET  READ_WRITE 
GO
