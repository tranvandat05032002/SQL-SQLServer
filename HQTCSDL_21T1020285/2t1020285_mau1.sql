-- cau2
if exists(select * from sys.objects where name = 'trg_NhanVien_DuAn_Insert')
	drop trigger trg_NhanVien_DuAn_Insert
GO

DECLARE @NgayBatDau DATE = '2003-12-20';
DECLARE @NgayKetThuc DATE = '2023-12-19';

create trigger trg_NhanVien_DuAn_Insert
on NhanVien_DuAn
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
--Test
insert NhanVien_DuAn(MaDuAn, MaNhanVien, MoTaCongViec, NgayGiaoViec)
values('DA003', 'NV005', 'Ngay mai DA001', '2023-12-24')
GO

-- Cau 3
-- a
if exists(select * from sys.objects where name = 'proc_NhanVien_DuAn_Insert')
	drop procedure proc_NhanVien_DuAn_Insert
GO
create procedure proc_NhanVien_DuAn_Insert (
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
--test
declare @test_kq nvarchar(255)
exec proc_NhanVien_DuAn_Insert @MaNhanVien = 'NV001', @MaDuAn = 'DA003', @MoTaCongViec = N'Mua Dong Khong Lanh', @KetQua = @test_kq output
GO

-- b
if exists(select * from sys.objects where name = 'proc_DuAn_DanhSachNhanVien')
	drop procedure proc_DuAn_DanhSachNhanVien
GO
create procedure proc_DuAn_DanhSachNhanVien (
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
-- test
exec proc_DuAn_DanhSachNhanVien @TenDuAn = 'E-Shop', @NgayGiaoViec = '2023-12-25'

-- c
-- get age
-- fix datediff
if exists(select * from sys.objects where name = 'func_DateDiff')
	drop procedure func_DateDiff
GO
create function func_DateDiff(
					@BirthDate date,
					@CurrentDate date
				)
returns int 
as
begin
	declare @tuoi int
	select @tuoi = 
		case 
			when (month(@BirthDate) > month(@CurrentDate)) 
				or (month(@BirthDate) = month(@CurrentDate) and day(@BirthDate) > day(@CurrentDate))
			then DATEDIFF(YEAR, @BirthDate, @CurrentDate) - 1
			else DATEDIFF(YEAR, @BirthDate, @CurrentDate)
		end
	return @tuoi
end
GO

if exists(select * from sys.objects where name = 'proc_NhanVien_TimKiem')
	drop procedure proc_NhanVien_TimKiem
GO
create procedure proc_NhanVien_TimKiem (
					@Trang int = 1,
					@SoDongMoiTrang int = 20,
					@HoTen nvarchar(50) = N'',
					@Tuoi int,
					@SoLuong int output
				)
as
begin
	set nocount on;

	select n.MaNhanVien, n.HoTen, n.NgaySinh, dbo.func_DateDiff(n.NgaySinh, GETDATE()) as Tuoi, n.Email, n.DiDong
	into #temp_nhanvien
	from NhanVien as n
	where ( @HoTen = N'' or n.HoTen like '%' + @HoTen + '%') 
	and dbo.func_DateDiff(n.NgaySinh, GETDATE()) >= @Tuoi

	declare @row_count int = @@ROWCOUNT
	declare @pageCount int;

	--fix
	select @SoLuong = @row_count
	select @SoLuong as SoLuong

	set @pageCount = @row_count / @SoDongMoiTrang
	if(@row_count % @SoDongMoiTrang > 0)
		set @pageCount += 1

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
-- test
declare @TotalPage int;
exec proc_NhanVien_TimKiem @Trang = 1, @SoDongMoiTrang = 10, @HoTen = N'h', @Tuoi = 10, @SoLuong = @TotalPage output
GO
-- d
if exists(select * from sys.objects where name = 'proc_ThongKeGiaoViec')
	drop procedure proc_ThongKeGiaoViec
GO
create procedure proc_ThongKeGiaoViec (
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
		-- fix
		from NhanVien_DuAn as nd
		where nd.MaDuAn = @MaDuAn
		group by nd.NgayGiaoViec
	)
	select cte_1.ngay, isnull(cte_2.soluong_duan, 0) as SoLuong_DuAn
	from cte_ngay as cte_1
	left join cte_duAn as cte_2
	on cte_1.ngay = cte_2.NgayGiaoViec
	OPTION(maxrecursion 0)
end
GO
-- test
exec proc_ThongKeGiaoViec @MaDuAn = 'DA003', @TuNgay = '2023-02-27', @DenNgay = '2023-03-02'
GO
-- Cau 4
-- a
if exists(select * from sys.objects where name = 'func_TKeDuAn')
	drop function func_TKeDuAn
GO
create function func_TKeDuAn (
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
-- test
select *
from dbo.func_TKeDuAn(2022, 2023)
GO
-- b
if exists(select * from sys.objects where name = 'func_TKeDuAn_DayDuCacNam')
	drop function func_TKeDuAn_DayDuCacNam
GO
create function func_TKeDuAn_DayDuCacNam (
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
-- test

select *
from func_TKeDuAn_DayDuCacNam(2014, 2023)
GO
-- Cau 5
use master
create login user_21T1020285 with password = '35701537scss'

USE master;
SELECT * FROM sys.sql_logins WHERE name = 'user_21T1020285';

use [21T1020285_mau1];
GO
create user user_21T1020285 for login user_21T1020285

-- cấp quyền:
-- table
grant select, insert on NhanVien to user_21T1020285

-- procedure 

--select *
--from sys.objects
--where name like 'func%' 

grant exec on proc_DuAn_DanhSachNhanVien to user_21T1020285
grant exec on proc_NhanVien_DuAn_Insert to user_21T1020285
grant exec on proc_NhanVien_TimKiem to user_21T1020285
grant exec on proc_ThongKeGiaoViec to user_21T1020285
-- function
grant select on func_TKeDuAn to user_21T1020285
grant select on func_TKeDuAn_DayDuCacNam to user_21T1020285


-- backup

backup database [21T1020285_mau1]
to disk = 'C:\Backup_SQL\21T1020285_mau1.bak'
