BÀI 4: HÀM

4.1. Hàm là gì?

- Hàm là một đối tượng được tổ chức và quản lý trong CSDL. Hàm có thể thực hiện lời
  gọi với tham số đầu vào, thực hiện các phép xử lý và trả kết quả cho lời gọi hàm.
- Việc sử dụng hàm so với thủ tục có sự khác biệt:
	+ Thủ tục: Lời gọi một thủ tục được xem như là một câu lệnh, tức là có thể viết
	  và chạy độc lập. 

	  Ví dụ: sp_who là một thủ tục của SQL Server dùng để lấy danh sách các tài khoản
	  đang kết nối đến máy chủ CSDL. Để gọi thủ tục này, có thể viết:

				sp_who;
		hoặc:	execute sp_who;

	  Kết quả xử lý của thủ tục có thể trả trực tiếp về cho Client.

	+ Hàm: Lời gọi hàm không thể sử dụng một cách độc lập như thủ tục mà phải sử dụng
	  bên trong một câu lệnh khác. Kết quả của hàm được trả về cho câu lệnh sử dụng nó.
	  (Hàm không trả trực tiếp dữ liệu về cho client)

	  Ví dụ: getdate() là hàm dùng để lấy thời gian hiện tại của hệ thống.
	  Sử dụng hàm này, ta không thể viết:

				getdate();
	  
	  Có thể viết như sau:
	  - Hàm được sử dụng bởi lệnh SELECT
				SELECT getdate();
	  - Hàm được sử dụng trong phép gán
				DECLARE @d date;
				SET @d = getdate();
		
Trong SQL Server, hàm được chia thành 2 loại:
- Scalar-Valued Function: Hàm có kết quả trả về là một giá trị (một số, một chuỗi, một giá
  trị kiểu ngày, giá trị kiểu bit,...)
- Table-Valued Function: Hàm có kết quả trả về là một bảng, chia thành 2 loại:
	+ Inline Function
	+ Multi-Statement Function


4.2. Scalar-Valued Function

- Là loại hàm mà kết quả trả về là một giá trị thuộc vào các kiểu dữ liệu chuẩn của SQL Server.
- Hàm này được sử dụng tại những vị trí mà một biểu thức được cho phép.
  				
Để tạo hàm, sử dụng lệnh CREATE FUNCTION với cú pháp:

	CREATE FUNCTION Tên_hàm(Danh_sách_tham_số)
	RETURNS Kiểu_dữ_liệu_trả_về_của_hàm
	AS
	BEGIN
		-- Phần thân của hàm (các lệnh lập trình cho hàm)
	END
	GO						

Lưu ý:
- Tên hàm không được trùng với các tên đã có trong CSDL. Nên đặt tên hàm với các tiền tố
  để dễ nhận biết và phân biệt (vd: fn_, uf_, func_,...)
- Cho dù hàm có hay không có tham số đều phải có cặp dấu ()
- Các tham số của hàm phân cách nhau bởi dấu phẩy, theo cú pháp:
		@Tên_tham_số   Kiểu_dữ_liệu
  (Hàm không cho phép sử dụng tham số kiểu bảng)
- Phần thân của hàm:
	+ Sử dụng lệnh 
			RETURN Giá_trị
	  Để trả kết quả về cho hàm. Khi gặp lệnh RETURN thì sẽ kết thúc hàm.
	  Lệnh RETURN có thể xuất hiện nhiều lần trong thân hàm.
	+ Không được sử dụng lệnh có trả dữ liệu về cho Client bên trong thân hàm.
	  (Lệnh SELECT nếu dùng bên trong hàm thì chỉ dùng để thực hiện lệnh gán
	   hoặc kết hợp với các lệnh INSERT, UPDATE, DELETE. Không được sử dụng câu
	   lệnh SELECT trong thân hàm với mục đích truy vấn dữ liệu như thông thường)

Ví dụ: Viết hàm fn_CongHaiSo để thực hiện cộng hai số nguyên

	create function fn_CongHaiSo(@a int, @b int)			
	returns int 
	as
	begin
		declare @c int;
		set @c = @a + @b;
		return @c;
	end

Để sử dụng hàm do người dùng định nghĩa thì trước tên hàm phải có tên Lược đồ CSDL phân
cách với tên hàm bởi dấu chấm (thường là dbo)

	select dbo.fn_CongHaiSo(10, 20);

Ví dụ: Viết hàm fn_TotalRevenueOfMonth để tính tổng doanh thu bán hàng của tháng @month
năm @year.

if exists(select * from sys.objects where name = 'fn_TotalRevenueOfMonth')
	drop function fn_TotalRevenueOfMonth;
go

create function fn_TotalRevenueOfMonth(@month int, @year int)
returns money
as
begin
	if @month not between 1 and 12
		return 0;

	if @year < 0
		return 0;
		
	declare @revenue money;
	declare @startDate date = datefromparts(@year, @month, 1);
	declare @endDate date = eomonth(@startDate, 0);

	select	@revenue = sum(od.Quantity * od.SalePrice)
	from	Orders as o join OrderDetails as od on o.OrderId = od.OrderId
	where	o.OrderDate between @startDate and @endDate;
	
	return @revenue;
end
go

-- Test:
select dbo.fn_TotalRevenueOfMonth(12, 2017);


4.3. Table-Valued Function

- Kết quả trả về của hàm là một bảng (logic)
- Hàm có thể sử dụng sau mệnh đề FROM của các câu lệnh.
- Chia làm 2 loại:
	+ Inline Function:	
	+ Multi-statement Function: 
  Hai loại này chỉ khác nhau về cách tạo ra chúng, còn sử dụng thì như nhau.

4.3.1 Inline Function

Cú pháp tạo hàm:

	CREATE FUNCTION Tên_hàm(Danh_sách_tham_số)
	RETURNS TABLE 
	AS
	RETURN
	(
		Câu_lệnh_SELECT_trả_dữ_liệu_về_cho_hàm
	)

Chú ý: Đối với hàm này, chỉ dùng duy nhất 1 lệnh SELECT để trả dữ liệu về cho hàm và không
sử dụng bất kỳ lệnh nào khác. Do đó, sử dụng cách viết hàm loại này trong trường hợp có thể
giải quyết kết quả trả về của hàm bởi duy nhất 1 lệnh SELECT.
Nên ưu tiên sử dụng cách viết hàm Inline nếu được.

Ví dụ: Viết hàm fn_ListRevenueByDates để trả về một bảng cho biết doanh thu bán hàng
mỗi ngày của tháng @month năm @year (Yêu cầu chỉ thống kê doanh thu những ngày có dữ liệu)


if exists(select * from sys.objects where name = 'fn_ListRevenueByDates')
	drop function fn_ListRevenueByDates;
go

create function fn_ListRevenueByDates(@month int, @year int)
returns table
as
return
(
	select	o.OrderDate, sum(od.Quantity * od.SalePrice) as Revenue
	from	Orders as o 
			join OrderDetails as od on o.OrderId = od.OrderId
	where	month(o.OrderDate) = @month and year(o.OrderDate) = @year 			
	group by o.OrderDate
)
go

-- Test
select * from dbo.fn_ListRevenueByDates(12, 2017);


4.3.2. Multi-Statement Function

Cú pháp:

		CREATE FUNCTION Tên_hàm(danh_sách_tham_số)
		RETURNS @Biến TABLE
		(
			Cấu_trúc_bảng_chứa_dữ_liệu_trả_về
		)
		AS
		BEGIN
			-- Các lệnh trong phần thân của hàm

			RETURN;
		END
		GO

Lưu ý:
- Phải khai báo cấu trúc của bảng chứa dữ liệu trả về thông qua biến @Biến
- Hàm phải kết thúc bởi lệnh RETURN (ở cuối cùng) và chỉ có duy nhất một lệnh RETURN.
  Sau RETURN không có giá trị. Về bản chất, kết quả trả về của hàm chính là @Biến
- Khi lập trình trong hàm, cần phải hướng đến việc "đẩy" được dữ liệu vào @Biến
- Không sử dụng các lệnh trả dữ liệu về cho Client trong thân hàm.

Ví dụ: Viết hàm fn_ListRevenueByAllDates để trả về một bảng cho biết doanh thu bán hàng
mỗi ngày của tháng @month năm @year (Yêu cầu thống kê doanh thu tất cả các ngày trong tháng).
Chú ý: không dùng CTE.

if exists(select * from sys.objects where name = 'fn_ListRevenueByAllDates')
	drop function fn_ListRevenueByAllDates;
go

create function fn_ListRevenueByAllDates(@month int, @year int)
returns @tbl table
(
	OrderDate date primary key,
	Revenue money default(0)
)
as
begin
	if (@month between 1 and 12 and @year > 0)
		begin
			declare @startDate date = datefromparts(@year, @month, 1);
			declare	@endDate date = eomonth(@startDate, 0);	

			insert into @tbl(OrderDate, Revenue)
				select	o.OrderDate, sum(od.Quantity * od.SalePrice) as Revenue
				from	Orders as o 
						join OrderDetails as od on o.OrderId = od.OrderId
				where	o.OrderDate between @startDate and @endDate			
				group by o.OrderDate;

			declare @d date = @startDate;
			while @d <= @endDate
				begin
					if not exists(select * from @tbl where OrderDate = @d)
						insert into @tbl(OrderDate) values (@d);

					set @d = dateadd(day, 1, @d);
				end
		end

	return;
end
go

-- Test:
select * from dbo.fn_ListRevenueByAllDates(11, 2017);

Bài tập:
1. Viết hàm để tính được tổng số tiền của một đơn hàng nào đó dựa vào mã của đơn hàng.
2. Viết hàm để tính tổng số tiền doanh thu của một mặt hàng có mã @productId trong 
   khoảng thời gian từ ngày @fromDate đến ngày @toDate
3. Viết hàm trả về một bảng là chi tiết của đơn hàng có mã là @orderId. Thông tin cần
   trả về bao gồm mã hàng, tên hàng, đơn vị tính, số lượng, giá và thành tiền.
4. Sử dụng cách viết hàm Inline, viết hàm
		fn_GetRevenueByDateRange
   trả về bảng có chức năng thống kê doanh thu bán hàng của từng ngày trong khoảng thời
   gian từ ngày @fromDate đến ngày @toDate (yêu cầu số liệu phải đủ tất cả các ngày
   trong khoảng thời gian cần thống kê)

  







	







