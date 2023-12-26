BÀI 3: THỦ TỤC LƯU TRỮ (Stored Procedure)

3.1. Thủ tục lưu trữ là gì?

- Thủ tục là các đối tượng được tổ chức và lưu trữ trong cơ sở dữ liệu, cho phép 
  chúng ta module hóa các phép xử lý dữ liệu.
- Bên trong một thủ tục chứa tập các câu lệnh được lập trình bởi T-SQL và các câu lệnh
  này sẽ được thực thi khi chúng ta có lời gọi đến thủ tục.
- Thủ tục được "biên dịch" ở lần chạy đầu tiên: chiến lược thực thi các câu lệnh trong thủ
  tục được lưu trữ lại và sử dụng cho các lần gọi sau. Điều này giúp cho quá trình chạy các
  lệnh trong thủ tục thường nhanh hơn so với cách viết thông thường.
- Sử dụng thủ tục trong các CSDL giúp tăng cường bảo mật đối với dữ liệu: Thay vì cho phép
  người sử dụng truy cập trực tiếp vào các bảng dữ liệu, chúng ta tạo ra các thủ tục và cấp
  phép cho người sử dụng thông qua các thủ tục. 

Tuy nhiên, điều cần lưu ý là sử dụng thủ tục cũng làm tăng tính phức tạp và độ khó khi 
triển khai cơ sở dữ liệu.

3.2. Tạo và sử dụng thủ tục trong SQL Server

Để tạo thủ tục, sử dụng lệnh CREATE PROCEDURE hoặc CREATE PROC theo cú pháp:

		CREATE PROCEDURE Tên_thủ_tục
				Danh_sách_các_tham_số_(nếu_có)			-- Đầu vào của thủ tục
		AS
			Phần_thân_của_thủ_tục						-- Các lệnh lập trình T-SQL
		GO

Lưu ý:
- Tên thủ tục:
		+ Phải duy nhất trong cơ sở dữ liệu (không được trùng tên với các đối tượng
		  khác đã có)
	    + Nên đặt thủ tục với các tiền tố để nhận biết, phân biệt và tránh bị trùng
			Ví dụ:		proc_InsertNewCustomer
						usp_CreateNewOrder
						sp_GetRevenueByMonth	(tránh dùng vì hệ thống đã dùng)
						...
- Danh sách tham số:
		+ Mỗi tham số được khai báo với cú pháp:
				@Tên_tham_số   Kiểu_dữ_liệu  [ = Giá_trị_mặc_định]
		+ Các tham số phân cách nhau bởi dấu phẩy
		+ Tên tham số bắt đầu bởi ký tự @
- Phần thân của thủ tục:
		+ Nên bắt đầu bởi lệnh
				SET NOCOUNT ON
		  Để tắt chế độ đếm số dòng dữ liệu tác động bởi câu lệnh.
		+ Không sử dụng lệnh GO trong phần thân thủ tục.
		+ Sử lệnh RETURN để thoát ra khỏi thủ tục
- Câu lệnh CREATE PROCEDURE không được chạy trong cùng tập lệnh với các câu lệnh 
  khác, do đó phải phân cách với các câu lệnh khác bằng lệnh GO.
  
Ví dụ: Viết thủ tục 
				proc_GetOrderDetails
					@orderId int
Có chức năng hiển thị mã hàng, tên hàng, đơn vị tính, số lượng, giá bán và thành tiền
của các mặt hàng thuộc đơn hàng có mã là @orderId

-- Kiểm tra xem thủ tục đã tồn tại hay chưa? Nếu tồn tại thì xóa trước khi tạo
if exists(select * from sys.objects where name='proc_GetOrderDetails')
	drop procedure proc_GetOrderDetails;
go
-- Tạo thủ tục
create procedure proc_GetOrderDetails
	@orderId int
as
begin
	set nocount on;

	select	p.ProductId, p.ProductName, p.Unit,
			od.Quantity, od.SalePrice, od.Quantity * od.SalePrice as TotalPrice
	from	Products as p
			join OrderDetails as od on p.ProductId = od.ProductId
	where	od.OrderId = @orderId;

end	
go

* Lời gọi thủ tục được xem là 1 câu lệnh trong T-SQL, có cách viết sau:

- Cách 1:
			
			EXECUTE	 Tên_thủ_tục  Danh_sách_các_đối_số

  Với cách viết này, danh sách các đối số phải theo đúng thứ tự các tham số khi định
  nghĩa thủ tục.
		
  Ví dụ:

			EXECUTE proc_GetOrderDetails 10250

- Cách 2:
		
			EXECUTE Tên_thủ_tục	
						@Tên_tham_số = Giá_trị, 
						..., 
						@Tên_tham_số_N = Giá_trị
  
  Với cách viết này, thứ tự các tham số không quan trọng nhưng phải viết đúng tên tham số.
  
  Ví dụ:
			EXECUTE proc_GetOrderDetails @orderId = 10250;
  	
  Khuyến cáo: nên sử dụng cách 2			  		
		   
Lưu ý:
	- Thay vì EXECUTE thì có thể viết là EXEC
	- Lệnh EXECUTE/EXEC có thể bỏ qua nếu lời gọi thủ tục không được viết trong các thủ
	  tục khác.

* Để xóa thủ tục dùng lệnh: DROP PROCEDURE
* Để sửa thủ tục dùng lệnh: ALTER PROCEDURE

Ví dụ: Viết thủ tục 
			proc_GetRevenueByDate
				@month int,
				@year int
Có chức năng thống kê doanh thu bán hàng trong từng ngày của tháng @month năm @year.
Yêu cầu phải thống kê tất cả các ngày trong tháng.

if exists(select * from sys.objects where name = 'proc_GetRevenueByDate')
	drop procedure proc_GetRevenueByDate;
go

create procedure proc_GetRevenueByDate
	@month int,
	@year int
as
begin
	set nocount on;

	if @month not between 1 and 12
		return;

	declare @firstDate date = datefromparts(@year, @month, 1);
	declare @lastDate date = eomonth(@firstDate, 0);

	with cte_DoanhThu as
	(
		select	o.OrderDate, 
				sum(od.Quantity * od.SalePrice) as Revenue
		from	Orders as o
				join OrderDetails as od on o.OrderId = od.OrderId
		where	o.OrderDate between @firstDate and @lastDate				
		group by o.OrderDate
	)
	,cte_Ngay as
	(
		select @firstDate as SummaryDate
		union all
		select dateadd(day, 1, SummaryDate)
		from cte_Ngay where SummaryDate < @lastDate	
	)	
	select	t1.SummaryDate,
			isnull(t2.Revenue, 0) as Revenue
	from	cte_Ngay as t1
			left join cte_DoanhThu as t2 on t1.SummaryDate = t2.OrderDate
end
go

-- Test:

execute	proc_GetRevenueByDate 
			@month = 12,
			@year = 2017;


3.3. Tham số của thủ tục

* Tham số với giá trị mặc định:
  - Nếu một tham số có giá trị mặc định thì có thể bỏ qua (không truyền giá trị) khi
    thực hiện lời gọi thủ tục. Còn nếu tham số không có giá trị mặc định thì bắt buộc 
	phải truyền giá trị khi gọi.

* Tham số dạng đầu ra (output parameter)  
  - Tham số output là tham số mà sự thay đổi giá trị của nó trong phần thân thủ tục sẽ
  được giữ lại sau khi thoát ra khỏi thủ tục (kết thúc thủ tục)  
  - Để sử dụng tham số dạng output trong thủ tục, cần:
		+ Khai báo tham số cho thủ tục phải có thêm từ khóa output/out ở cuối
		+ Khi sử dụng thì truyền giá trị cho tham số thông qua biến và phải có từ khóa
		  output/out ở cuối

Ví dụ:
	
	create procedure proc_Test
		@a int,
		@b int,
		@c int output
	as
	begin
		set @a = @a * 2;		
		set @b = @b * 3;		
		set @c = @c + @a + @b;	
	end
	go

-- Test:
declare	@a int = 10,
		@b int = 20,
		@c int = 100;

exec proc_Test
		@a = @a,
		@b = @b,
		@c = @c output;	

select @a, @b, @c;		-- @a = 10, @b = 20, @c = 180

* Tham số đầu vào dạng bảng 

- Tham số đầu vào dạng bảng cho phép chúng truyền dữ liệu đầu vào cho thủ tục dưới dạng
tập các dòng, các cột (phức tạp).
- Để sử dụng tham số đầu vào dạng bảng, cần:
	+ Khai báo kiểu dữ liệu dạng bảng bằng lệnh
			CREATE TYPE Tên_Kiểu AS TABLE
			(
				Cấu_trúc_bảng
			)
	+ Sử dụng kiểu dữ liệu bảng cho tham số của thủ tục theo cú pháp
			@Tên_tham_số  Kiểu_Dữ_liệu_Bảng READONLY
      (Tham số kiểu bảng chỉ được phép SELECT dữ liệu bên trong thủ tục)

Ví dụ: 
(Yêu cầu: Bảng Orders -> thay đổi thiết kế cột OrderId có tính chất IDENTITY)

Viết thủ tục proc_CreateNewOrder có chức năng tạo mới một đơn hàng với thông tin đầu
vào bao gồm:
	- @orderDate		: ngày tạo đơn hàng
	- @orderDetails		: danh sách các mặt hàng được bán trong đơn hàng, mỗi mặt hàng
					      được bán bao gồm các thông tin: mã hàng, số lượng, giá bán
Đầu ra của thủ tục cho biết:
	- @orderId			: mã của đơn hàng vừa tạo
	- @totalOfMoney		: tổng trị giá của đơn hàng


-- Định nghĩa kiểu dữ liệu dùng cho đầu vào của thủ tục
if not exists(select * from sys.types where name = 'TypeOrderDetail')
begin
	create type TypeOrderDetail as table
	(
		ProductId int primary key,
		Quantity int,
		SalePrice money
	)
end
go

-- Tạo thủ tục
if exists(select * from sys.objects where name = 'proc_CreateNewOrder')
	drop procedure proc_CreateNewOrder;
go

create procedure proc_CreateNewOrder
	@orderDate date,
	@orderDetails TypeOrderDetail readonly,
	@orderId int output,
	@totalOfMoney money output
as
begin
	set nocount on;

	-- Bổ sung 1 đơn hàng mới (bảng Orders)
	insert into Orders(OrderDate) values(@orderDate);

	set @orderId = @@IDENTITY;	-- SCOPE_IDENTITY()

	-- Bổ sung chi tiết đơn hàng
	insert into OrderDetails(OrderId, ProductId, Quantity, SalePrice)
	select @orderId, ProductId, Quantity, SalePrice from @orderDetails;
	
	-- Tính tổng tiền
	select @totalOfMoney = sum(Quantity * SalePrice)
	from @orderDetails;
end
go

-- Test case:
declare	@orderDetails TypeOrderDetail,
		@orderId int,
		@totalOfMoney money;

insert @orderDetails
values	(1, 10, 20.00),
		(2, 7, 15.00),
		(5, 10, 25.00);

execute proc_CreateNewOrder
			@orderDate = '2023/10/10',
			@orderDetails = @orderDetails,
			@orderId = @orderId out,
			@totalOfMoney = @totalOfMoney out;

select @orderId as OrderId, @totalOfMoney as TotalOfMoney;

execute proc_GetOrderDetails @orderId;






	

