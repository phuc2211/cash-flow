CREATE DATABASE CASHFLOW;
USE CASHFLOW;


CREATE TABLE fact_deposits (
    Deposit_ID INT PRIMARY KEY,
    Customer_ID VARCHAR(20),
    Deposit_Date DATE,
    Deposit_Amount DECIMAL(15, 2),
    Account_Type VARCHAR(50),
    Term INT,
    Interest_Rate DECIMAL(5, 2),
    Interest_Outflow DECIMAL(15, 2)
);
DROP TABLE fact_deposits;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.1/Uploads/fact_deposits.csv"
INTO TABLE fact_deposits
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Deposit_ID,Customer_ID, Deposit_Date, Deposit_Amount, Account_Type, Term, Interest_Rate, Interest_Outflow);




-- dùng SHOW VARIABLES LIKE 'secure_file_priv'; để xem nguồn data có thể chạy
SHOW VARIABLES LIKE 'secure_file_priv'



CREATE TABLE fact_bond_sales (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Bond_ID VARCHAR(50),
    Bond_Sale_Date DATE,
    Sale_Amount DECIMAL(15, 2),
    Bond_Maturity_Date DATE,
    Bond_Type VARCHAR(50),
    Interest_Rate DECIMAL(5, 2)
);


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.1/Uploads/fact_bond_sales.csv"
INTO TABLE fact_bond_sales
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Bond_Sale_Date, Bond_ID, Sale_Amount, Bond_Maturity_Date, Bond_Type, Interest_Rate);



CREATE TABLE fact_interbank_transfers (
    Transfer_ID INT AUTO_INCREMENT PRIMARY KEY, -- Khóa chính, tự động tăng
    Transfer_Date DATE,                         -- Ngày giao dịch
    Transaction_ID varchar(20),                         -- Mã giao dịch
    Counterparty_Bank VARCHAR(50),              -- Ngân hàng đối tác
    Transfer_Amount DECIMAL(15, 2),             -- Số tiền giao dịch
    Transfer_Currency VARCHAR(10),              -- Loại tiền tệ
    Transfer_Type VARCHAR(10),                  -- Loại giao dịch (inbound hoặc outbound)
    Transfer_Purpose VARCHAR(50)                -- Mục đích giao dịch
);


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.1/Uploads/fact_interbank_transfers.csv"
INTO TABLE fact_interbank_transfers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Transfer_Date, Transaction_ID, Counterparty_Bank, Transfer_Amount, Transfer_Currency, Transfer_Type, Transfer_Purpose);

select * from fact_interbank_transfers;

CREATE TABLE fact_loans (
    Loan_ID INT PRIMARY KEY,
    Customer_ID varchar(20),
    Loan_Date DATE,
    Loan_Amount DECIMAL(15, 2),
    Loan_Type VARCHAR(50),
    Loan_Term INT,
    Interest_Rate DECIMAL(5, 2),
    Interest_Inflow DECIMAL(15, 2)
);

select * from fact_loans;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.1/Uploads/fact_loans.csv"
INTO TABLE fact_loans
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Loan_ID,Customer_ID,Loan_Date,Loan_Amount,Loan_Type,Loan_Term,Interest_Rate,Interest_Inflow);



CREATE TABLE fact_operating_expenses (
    Expense_ID INT PRIMARY KEY AUTO_INCREMENT,
    Expense_Date DATE,
    Expense_Type VARCHAR(50),
    Expense_Amount DECIMAL(15, 2),
    Payment_Method VARCHAR(50),
    Cost_Center_Department VARCHAR(50)
);


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.1/Uploads/fact_operating_expenses.csv"
INTO TABLE fact_operating_expenses
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Expense_Date,Expense_Type,Expense_Amount,Payment_Method,Cost_Center_Department);

CREATE TABLE fact_withdrawals (
    Withdrawal_ID INT PRIMARY KEY AUTO_INCREMENT,
    Withdrawal_Date DATE,
    Customer_ID varchar(30),
    Withdrawal_Amount DECIMAL(15, 2),
    Account_Type VARCHAR(50),
    Withdrawal_Channel VARCHAR(50),
    Branch_ATM_ID varchar(30)
);



LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.1/Uploads/fact_withdrawals.csv"
INTO TABLE fact_withdrawals
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Withdrawal_Date,Customer_ID,Withdrawal_Amount,Account_Type,Withdrawal_Channel,Branch_ATM_ID);

select count(*) as total_rows from fact_withdrawals; 
SELECT COUNT(*) AS Total_Rows FROM fact_bond_sales;

DESCRIBE fact_deposits;


 -- Liên kết giữa bảng fact_deposits, fact_loans, và fact_withdrawals qua Customer_ID
SELECT 
    d.Customer_ID,
    d.Deposit_Amount AS Total_Deposit,
    l.Loan_Amount AS Total_Loan,
    w.Withdrawal_Amount AS Total_Withdrawal
FROM 
    fact_deposits d
LEFT JOIN 
    fact_loans l ON d.Customer_ID = l.Customer_ID
LEFT JOIN 
    fact_withdrawals w ON d.Customer_ID = w.Customer_ID;
    
    
-- Liên kết giữa bảng fact_interbank_transfers và các bảng khác qua Transaction_ID
-- Nếu giao dịch trong fact_interbank_transfers liên quan đến các bảng khác:

SELECT 
    t.Transaction_ID,
    t.Transfer_Amount,
    l.Loan_Amount,
    d.Deposit_Amount
FROM 
    fact_interbank_transfers t
LEFT JOIN 
    fact_loans l ON t.Transaction_ID = l.Loan_ID
LEFT JOIN 
    fact_deposits d ON t.Transaction_ID = d.Deposit_ID;


--  Liên kết giữa các bảng qua cột ngày (Date) (phân tích dữ liệu theo thời gian)
SELECT 
    d.Deposit_Date AS Transaction_Date,
    d.Deposit_Amount,
    l.Loan_Amount,
    w.Withdrawal_Amount,
    t.Transfer_Amount
FROM 
    fact_deposits d
LEFT JOIN 
    fact_loans l ON d.Deposit_Date = l.Loan_Date
LEFT JOIN 
    fact_withdrawals w ON d.Deposit_Date = w.Withdrawal_Date
LEFT JOIN 
    fact_interbank_transfers t ON d.Deposit_Date = t.Transfer_Date;
    
    
 -- kết hợp các bảng fact dựa trên các cột chung   
SELECT 
    d.Customer_ID,
    d.Deposit_Amount,
    l.Loan_Amount,
    w.Withdrawal_Amount,
    t.Transfer_Amount,
    o.Expense_Amount
FROM 
    fact_deposits d
LEFT JOIN 
    fact_loans l ON d.Customer_ID = l.Customer_ID
LEFT JOIN 
    fact_withdrawals w ON d.Customer_ID = w.Customer_ID
LEFT JOIN 
    fact_interbank_transfers t ON d.Deposit_Date = t.Transfer_Date
LEFT JOIN 
    fact_operating_expenses o ON d.Deposit_Date = o.Expense_Date;

