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

2.6. Bảng tạm (temporary table)

Bảng tạm là bảng được sử dụng để lưu trữ dữ liệu tạm thời. Khác với biến
bảng, bảng tạm có phạm vi sử dụng là trong một phiên làm việc (một phiên
làm việc bắt đầu từ khi mở kết nối đến CSDL cho đến khi đóng kết nối).

Một số điểm khác biệt giữa biến bảng và bảng tạm:
- Phạm vi sử dụng:
	+ Biến bảng có hiệu lực trong khối lệnh mà nó được khai báo và
	  thực thi.
	+ Bảng tạm có hiệu lực trong phiên làm việc (session)
- Cách tạo:
	+ Biến bảng: sử dụng lệnh DECLARE để khai báo
	+ Bảng tạm: Sử dụng lệnh CREATE TABLE hoặc SELECT ... INTO để tạo
	  ra bảng tạm (tương tự như bảng vật lý)
- Tên:
	+ Biến bảng: tên bắt đầu bởi dấu @
	+ Bảng tạm: tên bắt đầu bởi dấu #
- Bảng tạm được quản lý bởi CSDL hệ thống: tempdb

Trong T-SQL, bảng tạm thường dùng để lưu tạm thời dữ liệu truy xuất
được từ các bảng vật lý để tiến hành xử lý => ưu điểm:
	- Tốc độ xử lý dữ liệu trên bảng tạm nhanh hơn so với việc 
	  phải xử lý trực tiếp trên bảng vật lý.
	- Tránh phải làm việc trực tiếp trên dữ liệu "thật".

Chú ý: Bảng tạm chỉ tồn tại trong phiên làm việc mà nó được tạo ra.
Nó bị xóa khi kết thúc phiên làm việc hoặc do chúng ta chủ động xóa
bằng lệnh DROP TABLE

Ví dụ: tình huống

-- Lấy mã, tên và giá của các mặt hàng không bán được
-- trong tháng 2 năm 2018
SELECT	ProductId, ProductName, Price 
INTO	#TempProducts 
FROM	Products as p
WHERE	p.ProductId not in 
		(
			SELECT	od.ProductId
			FROM	Orders as o
					JOIN OrderDetails as od ON o.OrderId = od.OrderId
			WHERE	MONTH(o.OrderDate) = 2
				AND YEAR(o.OrderDate) = 2018
		)
GO

-- Xử lý dữ liệu
SELECT * FROM #TempProducts;

-- Giữ lại các mặt hàng giá cao hơn 50 để xử lý
DELETE FROM #TempProducts WHERE Price <= 50;

-- Giảm giá xuống 20%
UPDATE	#TempProducts
SET		Price = Price * 0.8

-- Truy vấn, so sánh
SELECT	t1.*,
		t2.Price as OldPrice
FROM	#TempProducts as t1
		JOIN Products as t2 ON t1.ProductId = t2.ProductId;

-- Cập nhật lại giá
UPDATE	t2 
SET		t2.Price = t1.Price
FROM	#TempProducts as t1
		JOIN Products as t2 ON t1.ProductId = t2.ProductId

DROP TABLE #TempProducts;

2.7. Biểu thức bảng (CTE: Common Table Expression)

- Truy vấn con (sub-query): là 1 câu lệnh SELECT được viết lồng vào
  bên trong 1 câu lệnh khác (SELECT, INSERT, UPDATE, DELETE). Kết quả
  của truy vấn con được sử dụng cho một truy vấn khác (cha)

  Ví dụ: Cho biết tất cả thông tin của mọi mặt hàng và tổng số lượng
  đã bán được.

  SELECT p.*,
	     t.SumOfQuantity
  FROM	Products AS p
		LEFT JOIN
		(
			SELECT	ProductID, SUM(Quantity) AS SumOfQuantity
			FROM	OrderDetails 
			GROUP BY ProductID 
		) AS t ON p.ProductID = t.ProductID

- Thay vì viết bằng truy vấn con, truy vấn trên có thể viết lại bằng
  cách dùng CTE như sau:

  WITH cte_ThongKe AS
  (
		SELECT	ProductID, SUM(Quantity) AS SumOfQuantity
		FROM	OrderDetails 
		GROUP BY ProductID 
  )
  SELECT	p.*, t.SumOfQuantity
  FROM		Products AS p
			LEFT JOIN cte_ThongKe AS t ON p.ProductID = t.ProductID

Cú pháp CTE:

	WITH tên_cte_1 AS
	(
		Câu_lệnh_SELECT_lấy_dữ_liệu_cho_cte_1
	)
	,tên_cte_2 AS
	(
		Câu_lệnh_SELECT_lấy_dữ_liệu_cho_cte_2
	)
	,...
	,tên_cte_N AS
	(
		Câu_lệnh_SELECT_lấy_dữ_liệu_cho_cte_N
	)
	Lệnh_xử_lý_dữ_liệu_sử_dụng_các_CTE

Lưu ý:
- Nếu trước lệnh WITH có một lệnh khác thì lệnh đó phải kết thúc bằng
  dấu chấm phẩy.
- Trong lệnh lấy dữ liệu cho CTE sau có thể truy vấn đến CTE đã định
  nghĩa phía trên.

Ví dụ:
	- Truy vấn A
	- Truy vấn B dùng đến A
	- Truy vấn C dùng đến B
	- Truy vấn D dùng đến A và C
	- Truy vấn dùng đến A, B, C và D

	WITH cte_A AS
	(
		SELECT ... FROM ...
	)
	,cte_B AS
	(
		SELECT ... FROM cte_A
	)
	,cte_C AS
	(
		SELECT ... FROM cte_B
	)
	,cte_D AS
	(
		SELECT ... FROM cte_A, cte_C
	)
	SELECT ... FROM cte_A, cte_B, cte_C, cte_D;

* Sử dụng CTE có thể viết được các truy vấn dữ liệu dạng đệ qui

Ví dụ: Tạo ra bảng chứa danh sách các ngày từ ngày @startDate cho đến
ngày @endDate 

DECLARE	@startDate date = '2018/02/01',
		@endDate date = '2018/02/28';

WITH cte_Ngay AS
(
	SELECT	1 AS STT, @startDate AS Ngay
	
	UNION ALL 
	
	SELECT	STT + 1, DATEADD(DAY, 1, Ngay)
	FROM	cte_Ngay 
	WHERE	Ngay < @endDate
)
SELECT * FROM cte_Ngay;

Ví dụ: 

-- Cho bảng DonVi như sau:
CREATE TABLE DonVi 
(
	MaDonVi nvarchar(50) primary key,
	TenDonVi nvarchar(255),
	MaDonViCha nvarchar(50) null
)
GO

INSERT INTO DonVi VALUES
('DV01', N'Khoa CNTT', NULL),
('DV02', N'Khoa Toán', NULL),
('DV03', N'Bộ môn KHMT', 'DV01'),
('DV04', N'Bộ môn Giải tích', 'DV02'),
('DV05', N'Bộ môn CNPM', 'DV01'),
('DV06', N'Bộ môn Mạng', 'DV01'),
('DV07', N'Bộ môn Đại số', 'DV02'),
('DV08', N'Tổ Thuật toán', 'DV03'),
('DV09', N'Tổ AI', 'DV03'),
('DV10', N'Khoa Hóa', NULL)

SELECT * FROM DonVi;

-- Hiển thị danh sách các đơn vị, Mức (level), đường dẫn và tên đầy đủ của đơn vị
-- Đường dẫn: chuỗi các mã đơn vị đi từ gốc đến nút tương ứng với  đơn vị đó.
--		Ví dụ: DV01\DV03\DV09
-- Tên đầy đủ, ví dụ: Tổ Thuật toán, Bộ môn KHMT, Khoa CNTT

WITH cte_DonVi AS
(
	SELECT	1 AS Muc,
			CAST(MaDonVi AS nvarchar(1000)) AS DuongDan,
			CAST(TenDonVi AS nvarchar(2000)) AS TenDayDu,
			*
	FROM	DonVi WHERE MaDonViCha IS NULL 

	UNION ALL

	SELECT	cha.Muc + 1,
			CAST(CONCAT(cha.DuongDan, '\', con.MaDonVi) AS nvarchar(1000)),
			CAST(CONCAT(con.TenDonVi, ', ', cha.TenDayDu) AS nvarchar(2000)),
			con.*
	FROM	DonVi AS con
			JOIN cte_DonVi AS cha ON con.MaDonViCha = cha.MaDonVi
)
SELECT * FROM cte_DonVi ORDER BY DuongDan;


2.8. Sử dụng con trỏ để duyệt dữ liệu

Khi truy vấn dữ liệu, chúng ta thường có nhu cầu lấy dữ liệu tại mỗi
dòng để thực hiện các phép xử lý. Điều này dẫn đến cần phép duyệt từng dòng
trong bảng. 

Trong T-SQL, con trỏ (CURSOR) dùng để duyệt dữ liệu.

Ví dụ: Truy vấn tên và giá các mặt hàng có giá nhỏ hơn 20 và in (PRINT) 
ra màn hình

-- B1: Khai báo biến con trỏ, trỏ vào kết quả truy vấn
DECLARE contro CURSOR FOR
	SELECT ProductName, Price FROM Products WHERE Price < 20;

-- B2: Mở con trỏ
OPEN contro;

-- B3: Dịch con trỏ vào dòng đầu tiên và đọc dữ liệu (lưu vào biến)
DECLARE @name nvarchar(50), 
		@price money;

FETCH NEXT FROM contro INTO @name, @price;

-- B4: Lặp và đọc các dòng tiếp theo
WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT @name;
		PRINT @price;

		FETCH NEXT FROM contro INTO @name, @price;
	END

-- B5: Đóng con trỏ (sau khi đóng, có thể OPEN lại)
CLOSE contro;

-- B6: Giải phóng con trỏ nếu không còn sử dụng
DEALLOCATE contro;

GO

Lưu ý: Chỉ nên dùng con trỏ trong trường hợp thực sự cần thiết.
Nếu có cách giải quyết bằng truy vấn (con, cte, biến bảng,...) thì 
nên ưu tiên bằng truy vấn.






