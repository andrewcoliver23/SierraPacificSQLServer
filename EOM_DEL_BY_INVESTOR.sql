WITH PHH_DEL AS (
SELECT iIf([INV_CODE] In ('4EF','4EG', '47V', '47W', '47X'),'FNMA',IIf([INV_CODE] in ('5AK', '30J'),'FHLMC',
IIf([INV_CODE] In ('A60','ACT', '1S0', '1S2', '1S1'),'Portfolio','Others'))) as Investor,
CASE 
WHEN
FCL_STATUS = 'A'
Then 'FC'
WHEN Cast(Loan.PMT_DUE_DATE_NEXT as date) = DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)
THEN 'D-Days'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) = 1
THEN 'D030'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) = 2
THEN 'D060'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) = 3
THEN 'D090'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) >= 4
THEN 'D120'
ELSE 'CURRENT'
END AS 'Del', COUNT(Loan.LOAN_NBR_SERVICER) as #, SUM(cast(PRIN_BALANCE_CURR as money)) as UPB
FROM PHH.Loan INNER JOIN PHH.Delinquency ON Loan.LOAN_NBR_SERVICER = Delinquency.LOAN_NBR_SERVICER AND LOAN.DATA_ASOF_DATE = Delinquency.DATA_ASOF_DATE
LEFT JOIN PHH.Foreclosure ON Delinquency.LOAN_NBR_SERVICER = Foreclosure.LOAN_NBR_SERVICER AND Delinquency.DATA_ASOF_DATE = Foreclosure.DATA_ASOF_DATE
WHERE LOAN.DATA_ASOF_DATE = '2022-09-30' AND CAST(PRIN_BALANCE_CURR AS MONEY) > 1 and INV_CODE NOT IN ('30M')
GROUP BY IIf([INV_CODE] In ('4EF','4EG', '47V', '47W', '47X'),'FNMA',IIf([INV_CODE] in ('5AK', '30J'),'FHLMC',IIf([INV_CODE] In ('A60','ACT', '1S0', '1S2', '1S1'),'Portfolio','Others'))), 
CASE 
WHEN
FCL_STATUS = 'A'
Then 'FC'
WHEN Cast(Loan.PMT_DUE_DATE_NEXT as date) = DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)
THEN 'D-Days'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) = 1
THEN 'D030'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) = 2
THEN 'D060'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) = 3
THEN 'D090'
WHEN DATEDIFF(m, Loan.PMT_DUE_DATE_NEXT, DATEFROMPARTS(datepart(yy, Loan.DATA_ASOF_DATE), datepart(mm, Loan.DATA_ASOF_DATE), 01)) >= 4
THEN 'D120'
ELSE 'CURRENT'
END),

LC_DEL AS (
SELECT IIf([InvestorID] In ('4EF','4EG', '47V', '47W', '47X'),'FNMA',IIf([InvestorID] in ('5AK', '30J'),'FHLMC',IIf([InvestorID] In ('A60','ACT', '1S0', '1S2', '1S1'),'Portfolio',IIF([InvestorID] in ('6BV', 'XBV'), 'GNMA', 'Others'))))
AS Investor,
CASE 
WHEN
LOAN.ForeclosureStatusCode = 'A'
Then 'FC'
WHEN cast(LOAN.NextPaymentDueDate as date) = DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) 
THEN 'D-Days'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) = 1
THEN 'D030'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) = 2
THEN 'D060'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) = 3
THEN 'D090'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) >= 4
THEN 'D120'
ELSE 'CURRENT'
END AS 'Del', COUNT(Loan.LoanNumber) as #, SUM(cast(FirstPrincipalBalance as money)) as UPB 
FROM LoanCare.Loan INNER JOIN LOANCARE.Delinquency ON LOAN.LoanNumber = Delinquency.LoanNumber AND LOAN.MspLastRunDate = Delinquency.MspLastRunDate
WHERE LOAN.MspLastRunDate = '2022-09-30' AND CAST(FirstPrincipalBalance AS MONEY) >1 AND Loan.LoanReoStatusCode <> 'A' AND InvestorId NOT IN ('4C9')
GROUP BY IIf([InvestorID] In ('4EF','4EG', '47V', '47W', '47X'),'FNMA',IIf([InvestorID] in ('5AK', '30J'),'FHLMC',IIf([InvestorID] In ('A60','ACT', '1S0', '1S2', '1S1'),'Portfolio',iif([InvestorID] in ('6BV', 'XBV'), 'GNMA', 'Others')))), 
CASE 
WHEN
LOAN.ForeclosureStatusCode = 'A'
Then 'FC'
WHEN cast(LOAN.NextPaymentDueDate as date) = DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01)  
THEN 'D-Days'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) = 1
THEN 'D030'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) = 2
THEN 'D060'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) = 3
THEN 'D090'
WHEN DATEDIFF(m, Loan.NextPaymentDueDate, DATEFROMPARTS(datepart(yy, Loan.MspLastRunDate), datepart(mm, Loan.MspLastRunDate), 01) ) >= 4
THEN 'D120'
ELSE 'CURRENT'
END),

ALL_DEL AS 
(SELECT * FROM PHH_DEL
UNION
SELECT * FROM LC_DEL)

select Investor, Del, sum(#) as #, sum(UPB) as UPB
from ALL_DEL
GROUP BY Investor, Del
order by 1, 2