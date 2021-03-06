DECLARE @StartDocDate date;
DECLARE @EndDocDate date;
DECLARE @StartItemDate date;
DECLARE @EndItemDate date;
DECLARE @Dispatch_WH INT;
DECLARE @NullDate date;
DECLARE @FutureDate date;

SET @StartDocDate= [%0];
SET @EndDocDate=[%1];
SET @StartItemDate=[%2];
SET @EndItemDate=[%3];
SET @Dispatch_WH =[%4];

DECLARE @values TABLE
(
    Value varchar(1000)
)
IF @Dispatch_WH <> '1' AND @Dispatch_WH <> '2'
BEGIN
    INSERT INTO @values VALUES('1')
    INSERT INTO @values VALUES('2')
    INSERT INTO @values VALUES('0')
END
ELSE
BEGIN
    INSERT INTO @values VALUES(@Dispatch_WH)
END

SET @NullDate = '17530101';
SET @FutureDate = '20991231';

IF @StartDocDate <> @NullDate AND @EndDocDate = @NullDate  BEGIN SET @EndDocDate = @FutureDate END
IF @StartItemDate <> @NullDate AND @EndItemDate = @NullDate BEGIN  SET @EndItemDate = @FutureDate END

IF @EndDocDate <> @NullDate AND @EndItemDate <> @NullDate
BEGIN
SELECT DISTINCT *
FROM(
        SELECT '' AS "Checkbox",
             T0.DocEntry AS DocEntryC1,
             T0.DocNum AS '文件編號',
             T0.CardName AS '客戶名',
             T0.DocDate AS '訂單日期',
             T0.U_Dispatch_WH AS '分派倉庫'
 FROM ORDR T0 
 LEFT JOIN RDR1 R1 ON T0.DocEntry = R1.DocEntry  
 
 WHERE T0.DocStatus = 'O' AND T0.U_Dispatch_WH IN (SELECT value FROM @values )
  AND R1.OpenQty > 0
  AND ((T0.DocDate >=  @StartDocDate 
  AND T0.DocDate <=  @EndDocDate)
  AND (R1.U_item_ldeli >= @StartItemDate 
  AND R1.U_item_ldeli <= @EndItemDate))
) T99
END

ELSE IF @EndDocDate <> @NullDate AND @EndItemDate = @NullDate 
BEGIN
SELECT DISTINCT *
FROM(
        SELECT '' AS "Checkbox",
             T0.DocEntry AS DocEntryC2,
             T0.DocNum AS '文件編號',
             T0.CardName AS '客戶名',
             T0.DocDate AS '訂單日期',
             T0.U_Dispatch_WH AS '分派倉庫'
 FROM ORDR T0  
 WHERE T0.DocStatus = 'O' AND T0.U_Dispatch_WH IN (SELECT value FROM @values ) 
  AND T0.DocDate >=  @StartDocDate 
  AND T0.DocDate <=  @EndDocDate
) T99
END

ELSE IF @EndDocDate = @NullDate AND @EndItemDate <> @NullDate 
BEGIN
SELECT DISTINCT *
FROM(
        SELECT '' AS "Checkbox",
             T0.DocEntry AS DocEntryC3,
             T0.DocNum AS '文件編號',
             T0.CardName AS '客戶名',
             T0.DocDate AS '訂單日期',
             T0.U_Dispatch_WH AS '分派倉庫'
 FROM ORDR T0  
  LEFT JOIN RDR1 R1 ON T0.DocEntry = R1.DocEntry  
 WHERE T0.DocStatus = 'O' AND T0.U_Dispatch_WH IN (SELECT value FROM @values )
  AND R1.OpenQty > 0 
  AND R1.U_item_ldeli >= @StartItemDate 
  AND R1.U_item_ldeli <= @EndItemDate
) T99
END

ELSE 
BEGIN

SELECT '' AS "Checkbox"
,'請至少輸入一個篩選值，請關閉此報表視窗' AS '提示訊息'

END
