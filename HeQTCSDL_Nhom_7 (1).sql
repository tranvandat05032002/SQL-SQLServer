BÀI 2: CƠ BẢN VỀ LẬP TRÌNH VỚI T-SQL

(T-SQL: Transact-SQL)

2.1. Một số qui tắc khi trong lập trình T-SQL

- Một câu lệnh có thể viết trên một hoặc nhiều dòng.
- Kết thúc câu lệnh có thể có dấu chấm phẩy hoặc không có đều được.
- Không phân biệt chữ hoa và chữ thường
- Một khối lệnh được viết trong cặp từ khóa
	BEGIN

	END
  (tương tự cặp dấu { } trong C)
- Các tập lệnh (nếu viết trong cùng 1 cửa sổ/file) thì phân cách bởi
  lệnh GO.

2.2. Khai báo biến

- Biến phải được khai báo trước khi sử dụng
- Cú pháp:

	DECLARE	@Tên_biến  Kiểu_dữ_liệu [=Giá_trị_khởi_tạo]

Lưu ý:
	- Tên biến phải bắt đầu bởi 1 dấu @
	- Kiểu dữ liệu của biến là các kiểu dữ liệu chuẩn do SQL Server
	  cung cấp (nvarchar, int, float, decimal, bit, date, datetime,...)
	- Có thể khai báo nhiều biến cùng bởi 1 lệnh DECLARE, các biến phân
	  cách nhau bởi dấu chấm phẩy.

Ví dụ:
	
	DECLARE	@name nvarchar(255),
			@age int = 40,
			@address nvarchar(255) = N'77 Nguyễn Huệ';

2.3. Phép gán

Trong T-SQL, có 2 cách để thực hiện phép gán:

- Cách 1: Sử dụng lệnh SET 

		SET @Tên_biến = Biểu_thức

  Lưu ý: Trong SQL, một câu lệnh SELECT trả về kết quả là 1 cột
  và tối đa là 1 dòng được xem là một biểu thức.

 Ví dụ:

DECLARE	@name nvarchar(255),
		@id int;

SET @id = 5;

SET @name = (SELECT CustomerName FROM Customers WHERE CustomerId = @id);

PRINT @name;

GO

Mỗi lệnh SET thì chỉ gán giá trị cho một biến

- Cách 2: Sử dụng lệnh SELECT

	SELECT	@Tên_biến_1 = Biểu_thức_1,
			@Tên_biến_2 = Biểu_thức_2,
			...
			@Tên_biến_3 = Biểu_thức_3
	[FROM ... WHERE ...]

Cách viết này thường dùng để truy vấn dữ liệu và đưa kết quả truy vấn
vào lưu trữ trong biến (thay vì trả dữ liệu về cho Client)

Ví dụ:

DECLARE	@firstName nvarchar(255),
		@lastName nvarchar(255),
		@id int;

SELECT	@id = 5;

SELECT	@firstName = FirstName, 
		@lastName = LastName
FROM	Employees
WHERE	EmployeeId = @id;

PRINT @firstName;
PRINT @lastName;
GO

2.4. Các cấu trúc điều khiển

- Rẽ nhánh: Lệnh IF có cú pháp

	IF điều_kiện
		Khối_lệnh_của_IF
	ELSE
		Khối_lệnh_của_ELSE 

   (ELSE là tùy chọn)

- Lặp: Lệnh WHILE 
	
	WHILE điều_kiện
		Khối_lệnh_của_WHILE 

	(Khi điều kiện đang đúng thì lặp)

	Khi viết vòng lặp WHILE cần chú ý tính dừng của vòng lặp.

	Có thể sử dụng lệnh BREAK và CONTINUE trong vòng lặp WHILE.

Ví dụ: Viết chương trình in ra màn hình tất cả các ngày (ngày/tháng/năm)
trong một tháng @month năm @year nào đó.

DECLARE	@month int = 2,
		@year int = 2023;

DECLARE @ngay date,	
		@thu nvarchar(50);

SET @ngay = DATEFROMPARTS(@year, @month, 1);

WHILE MONTH(@ngay) = @month
	BEGIN
		SET @thu = CASE DATEPART(WEEKDAY, @ngay)
						WHEN 2 THEN N'Thứ hai'
						WHEN 3 THEN N'Thứ ba'
						WHEN 4 THEN N'Thứ tư'
						WHEN 5 THEN N'Thứ năm'
						WHEN 6 THEN N'Thứ sáu'
						WHEN 7 THEN N'Thứ bảy'
						ELSE N'Chủ nhật'
				   END
		PRINT @thu + N', ngày ' + CONVERT(nvarchar(50), @ngay, 103);

		SET @ngay = DATEADD(DAY, 1, @ngay);
	END
GO

2.5. Biến kiểu bảng

- Trong T-SQL không có các kiểu dữ liệu trừu tượng (array, struct,
  class, list,...)
- Có thể sử dụng dữ liệu kiểu bảng để thay thế (tương đối)
- Để khai báo biến kiểu bảng, sử dụng cú pháp:

	DECLARE	@Tên_biến TABLE
	(
		Tên_cột_1  Kiểu_dữ_liệu  Tính_chất,
		...
		Tên_cột_N  Kiểu_dữ_liệu  Tính_chất
	)

- Mỗi một lệnh DECLARE chỉ khai báo 1 biến bảng và không kết hợp khai
  báo với các biến khác.
- Không được sử dụng lệnh gán đối với biến bảng.
- Chỉ được phép sử dụng các lệnh SELECT, INSERT, UPDATE và DELETE đối
  với biến bảng.

Ví dụ: Tạo 1 biến bảng có 2 cột 
			Thu		nvarchar(50)
			Ngay	date
và trong bảng này lưu dữ liệu thứ ngày của tất cả các ngày trong
tháng @month năm @year nào đó.

DECLARE	@month int = 2,
		@year int = 2018;

DECLARE @tblThuNgay TABLE
(
	Thu nvarchar(50),
	Ngay date primary key
)

DECLARE @ngay date,	
		@thu nvarchar(50);

SET @ngay = DATEFROMPARTS(@year, @month, 1);

WHILE MONTH(@ngay) = @month
	BEGIN
		SET @thu = CASE DATEPART(WEEKDAY, @ngay)
						WHEN 2 THEN N'Thứ hai'
						WHEN 3 THEN N'Thứ ba'
						WHEN 4 THEN N'Thứ tư'
						WHEN 5 THEN N'Thứ năm'
						WHEN 6 THEN N'Thứ sáu'
						WHEN 7 THEN N'Thứ bảy'
						ELSE N'Chủ nhật'
				   END
		
		INSERT INTO @tblThuNgay(Thu, Ngay)
		VALUES(@thu, @ngay);

		SET @ngay = DATEADD(DAY, 1, @ngay);
	END

SELECT * FROM @tblThuNgay;		

GO

Ví dụ: Sử dụng biến bảng như ở trên để thống kê doanh thu bán hàng
của tất cả các ngày trong tháng @month, năm @year

DECLARE	@month int = 2,
		@year int = 2018;

DECLARE @tblThuNgay TABLE
(
	Thu nvarchar(50),
	Ngay date primary key
)

DECLARE @ngay date,	
		@thu nvarchar(50);

SET @ngay = DATEFROMPARTS(@year, @month, 1);

WHILE MONTH(@ngay) = @month
	BEGIN
		SET @thu = CASE DATEPART(WEEKDAY, @ngay)
						WHEN 2 THEN N'Thứ hai'
						WHEN 3 THEN N'Thứ ba'
						WHEN 4 THEN N'Thứ tư'
						WHEN 5 THEN N'Thứ năm'
						WHEN 6 THEN N'Thứ sáu'
						WHEN 7 THEN N'Thứ bảy'
						ELSE N'Chủ nhật'
				   END
		
		INSERT INTO @tblThuNgay(Thu, Ngay)
		VALUES(@thu, @ngay);

		SET @ngay = DATEADD(DAY, 1, @ngay);
	END

SELECT	t1.Thu, t1.Ngay,
		ISNULL(t2.Revenue, 0) AS DoanhThu
FROM	@tblThuNgay AS t1
		LEFT JOIN
		(
			SELECT	o.OrderDate,
					SUM(od.Quantity * od.SalePrice) AS Revenue
			FROM	Orders AS o
					JOIN OrderDetails AS od ON o.OrderId = od.OrderId
			WHERE	MONTH(o.OrderDate) = @month 
				AND YEAR(o.OrderDate) = @year
			GROUP BY o.OrderDate
		) AS t2 ON t1.Ngay = t2.OrderDate	

GO

Cách làm khác:

DECLARE	@month int = 2,
		@year int = 2018;

DECLARE @tblThongKe TABLE
(
	OrderDate date primary key,
	Revenue money default(0)
)

INSERT INTO @tblThongKe(OrderDate, Revenue)
	SELECT	o.OrderDate,
			SUM(od.Quantity * od.SalePrice) AS Revenue
	FROM	Orders AS o
			JOIN OrderDetails AS od ON o.OrderId = od.OrderId
	WHERE	MONTH(o.OrderDate) = @month
		AND	YEAR(o.OrderDate) = @year
	GROUP BY o.OrderDate;

DECLARE @ngay date = DATEFROMPARTS(@year, @month, 1);

WHILE MONTH(@ngay) = @month 
	BEGIN
		IF NOT EXISTS(SELECT * FROM @tblThongKe WHERE OrderDate = @ngay)
			INSERT INTO @tblThongKe(OrderDate)
			VALUES(@ngay);

		SET @ngay = DATEADD(DAY, 1, @ngay)
	END
SELECT * FROM @tblThongKe;
GO






