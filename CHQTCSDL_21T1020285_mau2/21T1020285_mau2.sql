create table SinhVien(
			MaSinhVien nvarchar(50),
			HoTen nvarchar(50),
			NgaySinh date,
			NoiSinh nvarchar(50),
			TenLop nvarchar(50),

			constraint pk_SinhVien primary key(MaSinhVien)
)
GO
create table LopHocPhan(
			MaLopHocPhan nvarchar(50),
			TenLopHocPhan nvarchar(255),
			SoTinChi int,
			NgayBatDauHoc date,
			SoSinhVienDangKy int

			constraint pk_LopHocPhan primary key(MaLopHocPhan)
)
GO
create table LopHocPhan_SinhVien(
			MaLopHocPhan nvarchar(50),
			MaSinhVien nvarchar(50),
			NgayDangKy date
			
			constraint fk_LopHocPhanSinhVien_LopHocPhan foreign key(MaLopHocPhan) references LopHocPhan(MaLopHocPhan),
			constraint fk_LopHocPhanSinhVien_SinhVien foreign key(MaSinhVien) references SinhVien(MaSinhVien)
) 
GO
--

-- Cau 2
if exists(select * from sys.objects where name = 'trg_LopHocPhan_SinhVien_Insert')
	drop trigger trg_LopHocPhan_SinhVien_Insert
GO
create trigger trg_LopHocPhan_SinhVien_Insert
on LopHocPhan_SinhVien
after insert
as
begin
	if exists(
		select 1 
		from inserted as i 
		where (i.MaSinhVien 
		not in (select sv.MaSinhVien from SinhVien as sv))
		or (i.MaLopHocPhan not in (select lp.MaLopHocPhan from LopHocPhan as lp))
	)
		begin
			rollback tran
		end
	update lp
	set lp.SoSinhVienDangKy += 1
	from LopHocPhan as lp
	join inserted as i
	on lp.MaLopHocPhan = i.MaLopHocPhan
	where lp.MaLopHocPhan = i.MaLopHocPhan
end
GO
-- test

insert into LopHocPhan_SinhVien(MaLopHocPhan, MaSinhVien, NgayDangKy)
values('L0001', 'SV006', '2023-12-25')

select *
from LopHocPhan_SinhVien
-- cau 3
-- a
if exists(select * from sys.objects where name = 'proc_LopHocPhan_SinhVien_Insert')
	drop procedure proc_LopHocPhan_SinhVien_Insert
GO
create procedure proc_LopHocPhan_SinhVien_Insert (
					@MaLopHocPhan nvarchar(50),
					@MaSinhVien nvarchar(50),
					@KetQua nvarchar(255) output
				)
as
begin
	if not exists(select 1 from SinhVien as sv where sv.MaSinhVien = @MaSinhVien)
		begin
			set @KetQua = N'Không tồn tại mã sinh viên'
			raiserror(@KetQua, 16, 1)
			return;
		end
	if not exists(select 1 from LopHocPhan as lp where lp.MaLopHocPhan = @MaLopHocPhan)
		begin
			set @KetQua = N'Không tồn tại mã lớp học phần'
			raiserror(@KetQua, 16, 1)
			return;
		end
	insert into LopHocPhan_SinhVien(MaLopHocPhan, MaSinhVien, NgayDangKy)
	values(@MaLopHocPhan, @MaSinhVien, GETDATE())
end
GO
-- test
declare @text nvarchar(255)
exec proc_LopHocPhan_SinhVien_Insert @MaLopHocPhan = 'L0002', @MaSinhVien = N'SV003', @KetQua = @text output

--b
if exists(select * from sys.objects where name = 'proc_LopHocPhan_SinhVien_SelectByLop')
	drop procedure proc_LopHocPhan_SinhVien_SelectByLop
GO
create procedure proc_LopHocPhan_SinhVien_SelectByLop(
					@MaLopHocPhan nvarchar(50),
					@TenLop nvarchar(50)
				)
as
begin
	if not exists(select 1 from LopHocPhan as lp where lp.MaLopHocPhan = @MaLopHocPhan)
		begin
			raiserror(N'Không tồn tại mã sinh viên', 16, 1)
			return;
		end
	select sv.MaSinhVien, sv.HoTen, sv.NgaySinh, sv.NoiSinh
	from SinhVien as sv
	join LopHocPhan_SinhVien as ln
	on sv.MaSinhVien = ln.MaSinhVien
	where sv.TenLop like '%' + @TenLop + '%'
	and ln.MaLopHocPhan = @MaLopHocPhan
	order by sv.HoTen asc
end
GO

-- text
exec proc_LopHocPhan_SinhVien_SelectByLop @MaLopHocPhan = 'L0001', @TenLop = 'Tin K44A'
GO

-- c
-- function datediff
if exists(select * from sys.objects where name = 'fnc_DateDiff')
	drop function fnc_DateDiff
GO
create function fnc_DateDiff (
					@BirthDate date,
					@CurrentDate date	
				)
returns int as
begin
	declare @age int
	select @age = 
		case
			when (month(@BirthDate) > month(@CurrentDate)) or (month(@BirthDate) = month(@CurrentDate) and day(@BirthDate) > day(@CurrentDate))
			then datediff(YEAR, @BirthDate, @CurrentDate) - 1
			else datediff(YEAR, @BirthDate, @CurrentDate)
		end
	return @age
end
GO

if exists(select * from sys.objects where name = 'proc_SinhVien_TimKiem')
	drop procedure proc_SinhVien_TimKiem
GO
create procedure proc_SinhVien_TimKiem (
					@Trang int = 1,
					@SoDongMoiTrang int = 20,
					@HoTen nvarchar(50) = N'',
					@Tuoi int,
					@SoLuong int output
				)
as
begin
		select sv.MaSinhVien, sv.HoTen, sv.NgaySinh, sv.NoiSinh, sv.TenLop
		into #tmp_sinhvien
		from SinhVien as sv
		where (@HoTen = N'' or sv.HoTen like '%' + @HoTen + '%') 
		and dbo.fnc_DateDiff(sv.NgaySinh, GETDATE()) >= @Tuoi

		declare @row_count int = @@ROWCOUNT

		set @SoLuong = @row_count
		select @SoLuong as SoLuong

		;with cte_1 as(
			select *, ROW_NUMBER() over(order by MaSinhVien asc) as RowNumber
			from #tmp_sinhvien
		), cte_2 as (
			select *
			from cte_1 as t1
			where t1.RowNumber between @Trang * @SoDongMoiTrang - @SoDongMoiTrang + 1 and @Trang * @SoDongMoiTrang
		)
		select t2.MaSinhVien, t2.HoTen, t2.NgaySinh, t2.NoiSinh, t2.TenLop
		from cte_2 as t2
		join SinhVien as sv
		on t2.MaSinhVien = sv.MaSinhVien
end
GO

--test
declare	@Trang int = 1,
		@SoDongMoiTrang int = 2,
		@HoTen nvarchar(50) = N'h',
		@Tuoi int = 1,
		@SoLuong int
exec proc_SinhVien_TimKiem @Trang = @Trang, @SoDongMoiTrang = @SoDongMoiTrang, @HoTen = @HoTen, @Tuoi = @Tuoi, @SoLuong = @SoLuong output
GO
-- d
if exists (select * from sys.objects where name = 'proc_ThongKeDangKyHoc')
	drop procedure proc_ThongKeDangKyHoc
GO
create procedure proc_ThongKeDangKyHoc (
					@MaLopHocPhan nvarchar(50),
					@TuNgay date,
					@DenNgay date
				)
as
begin
		set nocount on;
		;with cte_ngay as(
			select @TuNgay as Ngay
			union all
			select DATEADD(day, 1, t1.Ngay) as Ngay
			from cte_ngay as t1
			where t1.Ngay < @DenNgay
		),
		cte_r_hp as (
			select ls.NgayDangKy, count(*) as Sl_DangKyHP
			from LopHocPhan_SinhVien as ls
			where ls.MaLopHocPhan = @MaLopHocPhan
			group by ls.NgayDangKy
		)
		select t1.Ngay, ISNULL(t2.Sl_DangKyHP, 0) as SL_DangKyHP
		from cte_ngay as t1
		left join cte_r_hp as t2
		on t1.Ngay = t2.NgayDangKy
end
GO
-- test
exec proc_ThongKeDangKyHoc @MaLopHocPhan = 'L0001', @TuNgay = '2023-11-12', @DenNgay = '2023-12-26'
GO

-- Cau 4
if exists(select * from sys.objects where name = 'func_TkeKhoiLuongDangKyHoc')
	drop function func_TkeKhoiLuongDangKyHoc
GO
create function func_TkeKhoiLuongDangKyHoc(
					@MaSinhVien nvarchar(50),
					@TuNam int,
					@DenNam int
				)
returns table 
as
	return(
		select year(ls.NgayDangKy) as NgayDangKy, sum(lp.SoTinChi) as TongTinChi
		from LopHocPhan_SinhVien as ls
		join  LopHocPhan as lp
		on ls.MaLopHocPhan = lp.MaLopHocPhan

		where ls.MaSinhVien = @MaSinhVien 
		and year(ls.NgayDangKy) between @TuNam and @DenNam
		group by year(ls.NgayDangKy)
	)
GO
--test
select *
from dbo.func_TkeKhoiLuongDangKyHoc ('SV006', 2014, 2023)
GO
-- b
if exists(select * from sys.objects where name = 'func_TkeKhoiLuongDangKyHoc_DayDuNam')
	drop function func_TkeKhoiLuongDangKyHoc_DayDuNam
GO
create function func_TkeKhoiLuongDangKyHoc_DayDuNam(
					@MaSinhVien nvarchar(50),
					@TuNam int,
					@DenNam int
				)
returns @tbl_dky table (
					Nam int primary key,
					SoLuong int
				)
as
begin
		insert into @tbl_dky(Nam,SoLuong)
		select year(ls.NgayDangKy) as NgayDangKy, sum(lp.SoTinChi) as TongTinChi
		from LopHocPhan_SinhVien as ls
		join  LopHocPhan as lp
		on ls.MaLopHocPhan = lp.MaLopHocPhan
		where ls.MaSinhVien = @MaSinhVien 
		and year(ls.NgayDangKy) between @TuNam and @DenNam
		group by year(ls.NgayDangKy)

		declare @currentYear int = @TuNam
		while @currentYear <= @DenNam
			begin
				if not exists(select * from @tbl_dky as t1 where t1.Nam = @currentYear)
				insert into @tbl_dky(Nam, SoLuong) values(@currentYear, 0)
				set @currentYear += 1
			end
		return;
end
GO
--test
select *
from dbo.func_TkeKhoiLuongDangKyHoc_DayDuNam ('SV006', 2014, 2023)
GO

-- cau5
use master
create login user_21T1020285_mau2 with password = '35701537scss'
GO

use [21T1020285_mau2]
GO
create user user_21T1020285_mau2 for login user_21T1020285_mau2

-- table
grant select, update on SinhVien to user_21T1020285_mau2

-- procedure
grant exec on proc_LopHocPhan_SinhVien_Insert to user_21T1020285_mau2
grant exec on proc_LopHocPhan_SinhVien_SelectByLop to user_21T1020285_mau2
grant exec on proc_SinhVien_TimKiem to user_21T1020285_mau2
grant exec on proc_ThongKeDangKyHoc to user_21T1020285_mau2

-- function
grant select on func_TkeKhoiLuongDangKyHoc to user_21T1020285_mau2
grant select on func_TkeKhoiLuongDangKyHoc_DayDuNam to user_21T1020285_mau2

backup database [21T1020285_mau2]
to disk = 'C:\CHQTCSDL_21T1020285_mau2'
