﻿CREATE DATABASE ORDER_PRODUCT
GO

USE [ORDER_PRODUCT]
GO

CREATE TABLE CUSTOMER
(
	CustomerId int PRIMARY KEY,
	CustomerName nvarchar(50),
	Email nvarchar(MAX),
	Phone nvarchar(50),
	Address nvarchar(max)
)
GO

CREATE TABLE PAYMENT
(
	PaymentId int Primary key,
	PaymentName nvarchar(50),
	PaymentFee float
)
GO

CREATE TABLE ORDER_PRODUCT
(
	OrderId int primary key,
	OrderDay date,
	OrderStatus nvarchar(50),
	OrderSum float,
	CustomerId int,
	PaymentId int,
	CONSTRAINT FK_CustomerId FOREIGN KEY (CustomerId) REFERENCES CUSTOMER(CustomerId),
	CONSTRAINT FK_PaymentId FOREIGN KEY (PaymentId) REFERENCES PAYMENT(PaymentId),
)
GO
CREATE TABLE PRODUCT 
(
	ProductId int primary key,
	ProductName nvarchar(50),
	ProductDescription nvarchar(50),
	ProductPrice float,
	ProductQuantity int,
)
GO

CREATE TABLE ORDER_DETAIL
(
	OrderDetailId int primary key,
	Quantity int,
	ProductPrice float,
	Total float,
	ProductId int,
	OrderId int,
	CONSTRAINT FK_ProductId FOREIGN KEY (ProductId) REFERENCES PRODUCT(ProductId),
	CONSTRAINT FK_OrderId FOREIGN KEY (OrderId) REFERENCES ORDER_PRODUCT(OrderId),
)
GO

insert into CUSTOMER(CustomerId,CustomerName, Email, Phone, Address)
values(1,'Nguyen Van A', 'nguyenvana@gmail.com', '0905123456', 'Da Nang')
insert into CUSTOMER(CustomerId,CustomerName, Email, Phone, Address)
values(2,'Nguyen Van B', 'nguyenvanb@gmail.com', '0905123457', 'Ha Noi')
insert into CUSTOMER(CustomerId,CustomerName, Email, Phone, Address)
values(3,'Nguyen Van C', 'nguyenvanc@gmail.com', '0905123458', 'Ho Chi Minh')
insert into CUSTOMER(CustomerId,CustomerName, Email, Phone, Address)
values(4, 'Nguyen Van D', 'nguyenvanc@gmail.com', '0905123458', 'Ho Chi Minh')
SELECT * FROM CUSTOMER

insert into PAYMENT(PaymentId,PaymentName, PaymentFee)
values(1, 'COD', 30000)
insert into PAYMENT(PaymentId, PaymentName, PaymentFee)
values(2, 'BANK', 1000)
SELECT * FROM PAYMENT

insert into PRODUCT(ProductId, ProductName, ProductDescription, ProductPrice, ProductQuantity)
values(1, 'san pham 1', 'mo ta san pham 1', 20000, 25)
insert into PRODUCT(ProductId, ProductName, ProductDescription, ProductPrice, ProductQuantity)
values(2, 'san pham 2', 'mo ta san pham 2', 30000, 20)
insert into PRODUCT(ProductId, ProductName, ProductDescription, ProductPrice, ProductQuantity)
values(3, 'san pham 3', 'mo ta san pham 3', 40000, 15)
select * from PRODUCT

insert into ORDER_PRODUCT(OrderId ,OrderDay, OrderStatus, OrderSum, CustomerId, PaymentId)
values(1, '2022-03-07', 'Pending', 40000, 1 , 2)
insert into ORDER_PRODUCT(OrderId ,OrderDay, OrderStatus, OrderSum, CustomerId, PaymentId)
values(2, '2022-03-07', 'Pending', 60000, 2 , 1)
insert into ORDER_PRODUCT(OrderId ,OrderDay, OrderStatus, OrderSum, CustomerId, PaymentId)
values(3, '2022-03-07', 'Pending', 80000, 3 , 1)
SELECT * FROM ORDER_PRODUCT

insert into ORDER_DETAIL(OrderDetailId, Quantity, ProductPrice, Total, ProductId, OrderId)
values(1, 2, 20000, 40000, 1, 1)
insert into ORDER_DETAIL(OrderDetailId, Quantity, ProductPrice, Total, ProductId, OrderId)
values(2, 2, 30000, 60000, 2, 2)
insert into ORDER_DETAIL(OrderDetailId, Quantity, ProductPrice, Total, ProductId, OrderId)
values(3, 2, 40000, 80000, 3, 3)
select * from ORDER_DETAIL

--1)View
--a)Tạo view từ bảng OrderbyDetail. View này sẽ có Quantity và Total
CREATE VIEW V_ORDER_DETAIL AS
SELECT Quantity, Total
FROM ORDER_DETAIL

--b)Tạo view hiện thị danh sách có giá lớn hơn hoặc bằng 30000
CREATE VIEW C_ORDER_DETAIL AS
SELECT Total,OrderId,OrderDetailId
FROM ORDER_DETAIL
WHERE ProductPrice >=30000

SELECT * FROM C_ORDER_DETAIL
DROP VIEW C_ORDER_DETAIL


--2) Procedure
--a)Hiện sản phẩm có productprice trên 30000 và total trên 50000
CREATE PROCEDURE GetProduct
AS
BEGIN
    SELECT ProductName, ProductDescription, P.ProductPrice, ProductQuantity FROM ORDER_DETAIL O JOIN PRODUCT P ON O.ProductId=P.ProductId
	WHERE Total > 50000 AND P.ProductPrice > 30000
END;
 
EXEC GetProduct


--b) Thuc hiện tạo  Procedure hiển thị dữ liệu đơn hàng theo mã đơn hàng
CREATE PROCEDURE displayOrderÌno
(
    @madh int
)
AS
BEGIN
    SELECT  *  
        
    FROM 
       ORDER_PRODUCT
    WHERE
        ORDER_PRODUCT.CustomerId = @madh

END;

exec displayOrderÌno  3

--c) Thuc hiện tạo các Procedure thêm dữ liệu vào bản ORDER_PRODUCT

CREATE proc SP_AddOrderKH                 
					   @CustomerId INT,
					   @PaymentId INT,
					   @OrderDay DATE,	
					   @OrderStatus NVARCHAR(100),
					   @OrderSum float
as
begin


	--Ktra su ton tai cua MaKH
	if not exists(select *from CUSTOMER where CUSTOMER.CustomerId=@CustomerId)
	begin
		print @CustomerId + ' ' + 'Chua ton tai trong bang CUSTOMER'
		return
	end

	--Ktra su ton tai cua MaPTTT
	if not exists(select *from PAYMENT where PAYMENT.PaymentId=@PaymentId)
	begin
		print @PaymentId + ' ' + 'Chua ton tai trong bang PAYMENT'
		return
	end

	 INSERT INTO ORDER_PRODUCT VALUES
	( @OrderDay, @OrderStatus, @OrderSum, @CustomerId,@PaymentId)
end
go

exec SP_AddOrderKH	 '2022-03-08', 'Pending', 4000.000, 1 , 2
go

--d) thủ tục procedure xóa khách hàng theo ID
create procedure Sp_CUSTOMER (@id_customer int) 
	as 
	 begin 
		delete from CUSTOMER where CUSTOMER.CustomerId = @id_customer ;  
	 end  ;
	 exec Sp_CUSTOMER 4

--3)Funtion
--a)Tính tổng total 
CREATE FUNCTION Fn_TongTotal() 
RETURNS TABLE RETURN 
SELECT SUM(Total) AS "TongTotal"
FROM ORDER_DETAIL
GO
SELECT * FROM Fn_TongTotal()
--b)Tạo funtion cho biết tên product có total lớn hơn hoặc bằng 40000
CREATE FUNCTION Fn_TenTotal40000() 
RETURNS TABLE RETURN 
SELECT  ProductName
FROM ORDER_DETAIL O JOIN PRODUCT P ON O.ProductId=P.ProductId 
WHERE Total >= 40000
GO
SELECT * FROM Fn_TenTotal40000()

-- Tổng sản phẩm đã bán theo mã sản phẩm
create function total_product(@ProductId int)
returns int
as
	begin
		declare @totlal int

		select @totlal = sum(Quantity) from ORDER_DETAIL
		where ORDER_DETAIL.ProductId = @ProductId

		return @totlal
	end

select dbo.total_product(1) as totalSP
