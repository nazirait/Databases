-- Task 1.1 I created the table 'Invoice' in MS SQL Server Management Studio

CREATE TABLE Invoice (
    INVOICE_KEY INT IDENTITY(1,1) PRIMARY KEY,
    INVOICE_DATE DATE,
    NET_AMOUNT MONEY,
    GROSS_AMOUNT MONEY,
    TAX_PCT DECIMAL(5,2)
);

-- SELECT * FROM Invoice;
