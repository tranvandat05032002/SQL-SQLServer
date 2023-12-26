insert into Customer(CustomerName, Email, IsLocked, MobiNumber, [Password], RegisterTime)
	select CustomerName, Email, IsLocked, MobiNumber, [Password], RegisterTime
	from dbo.[BaiThucHanh_03 - Customer]

select *
from CardStore

insert into CardStore (CardTypeId, Serial, PinNumber, Amount, ExpiredTime, CardStatus, InvoiceId)
select 1 as CardTypeId , Serial, PinNumber, Amount, CAST(SUBSTRING(ExpiredTime, 0, 11) as datetime), 1, NULL
from dbo.[BaiThucHanh_03 - MOBILE Cards]

insert into CardStore (CardTypeId, Serial, PinNumber, Amount, ExpiredTime, CardStatus, InvoiceId)
select 2 as CardTypeId , Serial, PinNumber, Amount, CAST(SUBSTRING(ExpiredTime, 0, 11) as datetime), 1, NULL
from dbo.[BaiThucHanh_03 - VINA Cards]

insert into CardStore (CardTypeId, Serial, PinNumber, Amount, ExpiredTime, CardStatus, InvoiceId)
select 3 as CardTypeId , Serial, PinNumber, Amount, CAST(SUBSTRING(ExpiredTime, 0, 11) as datetime), 1, NULL
from dbo.[BaiThucHanh_03 - VIETTEL Cards]

select *
from CardStore

---------------------------------------------------------------------------------------------------------------------


/*1. Hàm fn_IsValidMobiNumber(@MobiNumber nvarchar(50) trả về giá trị kiểu bit nhằm
kiểm tra @MobiNumber có phải là số di động hợp lệ hay không. Trong đó qui định số di động
được xem là hợp lệ nếu là chuỗi có độ dài từ 9 đến 12 ký tự và chỉ chứa các con số (NOT LIKE
'%[^0-9]%'). */

if exists (select * from sys.objects where name = 'fn_IsValidMobiNumber')
	drop function fn_IsValidMobiNumber
GO
create function fn_IsValidMobiNumber(@MobiNumber nvarchar(50))
returns bit
as
begin
	declare @flag bit
	if((LEN(@MobiNumber) between 9 and 12) and (@MobiNumber NOT LIKE '%[^0-9]%'))
		set @flag = 1
	else
		set @flag = 0
	return @flag
end
go

select dbo.fn_IsValidMobiNumber('0912787834') as flag
--2.

if exists (select * from sys.objects where name = 'proc_Customer_Register')
	drop procedure proc_Customer_Register
GO
create procedure proc_Customer_Register (
				@CustomerName nvarchar(100),
				@Email nvarchar(100),
				@Password nvarchar(100),
				@MobiNumber nvarchar(50),
				@CustomerId int OUTPUT 
)
as
begin
	declare @checkPhone bit
	set @checkPhone = dbo.fn_IsValidMobiNumber(@MobiNumber)
	if LEN(@Email) = 0
		begin 
			set @CustomerId = -1
			insert into Customer(CustomerName, Email, [Password], MobiNumber, IsLocked, RegisterTime, CustomerId)
			values (@CustomerName, @Email, @Password, @MobiNumber, 0, GETDATE(), @CustomerId)
		end
	else 
		if exists (select Email from Customer where Customer.Email = @Email)
			begin 
				set @CustomerId = -2
				insert into Customer(CustomerName, Email, [Password], MobiNumber, IsLocked, RegisterTime, CustomerId)
				values (@CustomerName, @Email, @Password, @MobiNumber, 0, GETDATE(), @CustomerId)
			end
		else
			if (LEN(@Password) = 0 or LEN(@Password) < 6)
				begin
					set @CustomerId = -3
					insert into Customer(CustomerName, Email, [Password], MobiNumber, IsLocked, RegisterTime, CustomerId)
					values (@CustomerName, @Email, @Password, @MobiNumber, 0, GETDATE(), @CustomerId)
				end
			else
				if(LEN(@CustomerName) = 0)
					begin
						set @CustomerId = -4
						insert into Customer(CustomerName, Email, [Password], MobiNumber, IsLocked, RegisterTime, CustomerId)
						values (@CustomerName, @Email, @Password, @MobiNumber, 0, GETDATE(), @CustomerId)
					end
				else
					if(@checkPhone = 0)
						begin
							set @CustomerId = -5
							insert into Customer(CustomerName, Email, [Password], MobiNumber, IsLocked, RegisterTime, CustomerId)
							values (@CustomerName, @Email, @Password, @MobiNumber, 0, GETDATE(), @CustomerId)
						end
					else
						
						insert into Customer(CustomerName, Email, [Password], MobiNumber, IsLocked, RegisterTime, CustomerId)
						values (@CustomerName, @Email, @Password, @MobiNumber, 0, GETDATE(), @CustomerId)
						
end
GO

exec proc_Customer_Register 'tranvandat6', 'tranvandat6@gmail.com', 'abcdscss123', '0768523264', 1111112
GO


--3.
if exists (select * from sys.objects where name = 'proc_Customer_ChangePassword')
	drop procedure proc_Customer_ChangePassword
GO
create procedure proc_Customer_ChangePassword (
				@Email nvarchar(100),
				@OldPassword nvarchar(100),
				@NewPassword nvarchar(100),
				@Result int = 0 OUTPUT
)
as
begin
	if (LEN(@Email) > 0 and ( LEN(@OldPassword) <> 0 and LEN(@OldPassword) >= 6 ) and ( LEN(@NewPassword) <> 0 and LEN(@NewPassword) >= 6 ) and exists (select * from Customer where Email = @Email))
		begin
			update Customer
			set [Password] = @NewPassword
			where Email = @Email
			and [Password] = @OldPassword
			set @Result = 1;
			print @Result
		end
	else
		begin
			set @Result = 0
			print @Result
		end
end
GO

exec proc_Customer_ChangePassword 'hmouton1@ebay.com', '35701537Scss', '35701537Nextjs'

select *
from Customer


--4
if exists (select * from sys.objects where name = 'proc_Customer_Authenticate')
	drop procedure proc_Customer_Authenticate
GO
create procedure proc_Customer_Authenticate (
				@Email nvarchar(100),
				@Password nvarchar(100)
)
as
begin
	set nocount on;
	if(exists(select * from Customer where Email = @Email) and exists(select * from Customer where [Password] = @Password))
		select CustomerId, CustomerName, Email, MobiNumber, IsLocked
		from Customer
		where Email = @Email
		and [Password] = @Password
end
GO

exec proc_Customer_Authenticate 'tranvandat6@gmail.com', 'abcdscss123'

select *
from Customer

-- 5
if exists (select * from sys.objects where name = 'proc_Customer_Update')
	drop procedure proc_Customer_Update
GO
create procedure proc_Customer_Update (
				@CustomerId int,
				@CustomerName nvarchar(100),
				@Email nvarchar(100),
				@MobiNumber nvarchar(50),
				@Result int = 0 OUTPUT
)
as
begin
	if not exists (select * from Customer where CustomerId = @CustomerId)
		begin
			set @Result = 0
			return @Result
		end
	if LEN(@Email) = 0
		begin
			set @Result = -1
			return @Result
		end
	if exists (select * from Customer where Email = @Email)
		begin
			set @Result = -2
			return @Result
		end
	if LEN(@CustomerName) = 0
		begin
			set @Result = -4
			return @Result
		end 
	if dbo.fn_IsValidMobiNumber(@MobiNumber) = 0
		begin
			set @Result = -5
			return @Result
		end

	update Customer
	 set CustomerName = @CustomerName,
         Email = @Email,
         MobiNumber = @MobiNumber
	where CustomerId = @CustomerId
	set @Result = 1
	return @Result
end
GO
exec proc_Customer_Update 1111112, 'tranvandatHUSC', 'tranvandatHUSC@gmail.com', '0914567123'
GO

select CEILING(5.111) as TotalPage
from Customer
-- test pagination
select CustomerId, CustomerName
from Customer
order by CustomerId
OFFSET 4*(4-1) ROWS FETCH NEXT 0 ROWS ONLY


-- 6
if exists (select * from sys.objects where name = 'proc_Customer_Select')
	drop procedure proc_Customer_Select
GO
create procedure proc_Customer_Select (
				@Page int = 0,
				@SearchValue nvarchar(255) = N'',
				@PageSize int = 0,
				@RowCount int = 0 OUTPUT,
				@PageCount int = 0 OUTPUT
)
as 
begin
	if(@PageSize <= 0)
		begin
			select *, 0 as total, 1 as totalPage
			from Customer
			return
		end
	else
		begin
			select @RowCount = COUNT(*)
			from Customer
			where CustomerName = @SearchValue 
			or MobiNumber = @SearchValue  

			select @PageCount = CEILING( CAST(@RowCount as float) / CAST(@PageSize as float))

			select *, @RowCount as total,  @PageCount as totalPage
			from Customer
			where CustomerName = @SearchValue 
			or MobiNumber = @SearchValue  
			order by CustomerId
			OFFSET @PageSize * (@Page - 1) ROWS FETCH NEXT @PageSize ROWS ONLY -- use row_number()
		end
end
GO

exec proc_Customer_Select 1, '0911117778', 3



-- 7
if exists (select * from sys.objects where name = 'proc_Invoice_Select')
	drop procedure proc_Invoice_Select
GO
create procedure proc_Invoice_Select (
				@Page int = 1,
				@PageSize int = 0,
				@CustomerId int = 0,
				@FromTime datetime = null,
				@ToTime datetime = null,
				@RowCount int OUTPUT,
				@PageCount int OUTPUT
)
as
begin
	set nocount on;

	/*select @RowCount = count(*)
	from Invoice as i
			where (@CustomerId = 0 or i.CustomerId = @CustomerId)
			and	(@FromTime is null or i.CreatedTime >= @FromTime)
			and (@ToTime is null or i.CreatedTime <= @ToTime)
	*/
	select *
	into #Temp
	from Invoice as i
			where (@CustomerId = 0 or i.CustomerId = @CustomerId)
			and	(@FromTime is null or i.CreatedTime >= @FromTime)
			and (@ToTime is null or i.CreatedTime <= @ToTime)
	set @RowCount = @@ROWCOUNT
	if(@PageSize = 0)
		set @PageCount = 1
	else
		begin
			set @PageCount = @RowCount / @PageSize
			if(@RowCount % @PageSize > 0)
				set @PageCount += 1
		end

	with cte1 as
	(
			select *, ROW_NUMBER() over(order by CreatedTime desc) as RowNumber
			/*from Invoice as i
			where (@CustomerId = 0 or i.CustomerId = @CustomerId)
			and	(@FromTime is null or i.CreatedTime >= @FromTime)
			and (@ToTime is null or i.CreatedTime <= @ToTime) */
			from #Temp
	),
	cte2 as 
	(
		select *
		from cte1 as i
		where (@PageSize = 0) 
		or i.RowNumber between @Page *  @PageSize - @PageSize + 1 and @Page * @PageSize -- optimal this line
	)
	select i.InvoiceId, i.CustomerId, c.CustomerName, i.CreatedTime, i.InvoiceStatus, i.FinishedTime,
			SUM(s.Amount) as SumOfAmount
	from cte2 as i
	join Customer as c 
	on i.CustomerId = c.CustomerId
	left join CardStore as s 
	on i.InvoiceId = s.InvoiceId
	group by i.InvoiceId, i.CustomerId, c.CustomerName, i.CreatedTime, i.InvoiceStatus, i.FinishedTime
	order by i.RowNumber;
end
GO

--8
select *
from CardStore

if exists (select * from sys.objects where name = 'fn_GetInventories')
	drop function fn_GetInventories
GO
create function fn_GetInventories(@CardTypeId int, @Amount money)
returns INT
as
begin
	declare @totalCard int;
	select @totalCard = COUNT(*)
	from CardStore as c
	where c.CardTypeId = @CardTypeId
	and c.Amount = @Amount
	return @totalcard
end
GO
select dbo.fn_GetInventories(1, 50000) as totalCard

--10
if exists (select * from sys.objects where name = 'fn_GetRevenueByDate')
	drop function fn_GetRevenueByDate
GO

create function fn_GetRevenueByDate
(
	@CardTypeId int,
	@FromTime datetime,
	@ToTime datetime
) returns table
as
	return 
	(
		with cte_Ngay as
		(
			select cast(@fromTime as date) as Ngay
				union all
				select dateadd(day, 1, Ngay)	
				from cte_Ngay
				where Ngay < cast(@ToTime as date)
		)
		,cte_DoanhThu as
		(
				select cast(i.CreatedTime as date) as Ngay,
						sum(c.Amount ) as TongDoanhThu
				from Invoice as i join 
					CardStore as c on i.InvoiceId = c.InvoiceId
				where (i.InvoiceStatus = 1)
					and (i.CreatedTime between @fromTime and @toTime)
					and (@CardTypeId = 0 or c.CardTypeId = @CardTypeId)
				group by cast(i.CreatedTime as date)
		)
		select t1.Ngay,
			isnull(t2.TongDoanhThu, 0) as 'TongDoanhThu'
		from cte_Ngay as t1 left join cte_DoanhThu as t2 on t1.Ngay = t2.Ngay
	)
GO
select * from dbo.fn_GetRevenueByDate(0, '2023/10/01', '2023/10/31 23:59:59:997')
--11
if exists (select * from sys.objects where name = 'fn_GetRevenueByDateAndAmount')
	drop function fn_GetRevenueByDateAndAmount;
go

create function fn_GetRevenueByDateAndAmount
(
			@CardTypeId int,
			@FromTime datetime,
			@ToTime datetime
)
returns table
as
return
(
	with cte_Ngay as
	(
		select cast(@fromTime as date) as Ngay
		union all
		select dateadd(day, 1, Ngay)	
		from cte_Ngay
		where Ngay < cast(@toTime as date)
	)
	,cte_DoanhThu as
	(
		select cast(i.CreatedTime as date) as Ngay,
				sum(case when c.Amount = 50000 then c.Amount else 0 end) as Tong50K,
				sum(case when c.Amount = 100000 then c.Amount else 0 end) as Tong100K,
				sum(case when c.Amount = 200000 then c.Amount else 0 end) as Tong200K,
				sum(case when c.Amount = 500000 then c.Amount else 0 end) as Tong500K,
				sum(c.Amount ) as TongDoanhThu
		from Invoice as i join 
			CardStore as c on i.InvoiceId = c.InvoiceId
		where (i.InvoiceStatus = 1)
			and (i.CreatedTime between @fromTime and @toTime)
			and (@CardTypeId = 0 or c.CardTypeId = @CardTypeId)
		group by cast(i.CreatedTime as date)
	)

	select t1.Ngay,
			isnull(t2.Tong50K, 0) as '50K',
			isnull(t2.Tong100K, 0) as '100K',
			isnull(t2.Tong200K, 0) as '200K',
			isnull(t2.Tong500K, 0) as '500K',
			isnull(t2.TongDoanhThu, 0) as 'TongDoanhThu'

	from cte_Ngay as t1 left join cte_DoanhThu as t2 on t1.Ngay = t2.Ngay
)
go
--Test 
select * from dbo.fn_GetRevenueByDateAndAmount(0, '2023/10/01', '2023/10/31 23:59:59:997')