<!-- WARNING: formatter failed for Total_Employees: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Total_Employees
```DAX
COUNTROWS('Employee')
```

<!-- WARNING: formatter failed for New Hire Count: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## New Hire Count
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date])
    IN VALUES('Date'[YearMonth])
)
```

<!-- WARNING: formatter failed for Leaver Count: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Leaver Count
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    NOT(
        ISBLANK('Employee'[leave_date])
    ) &&
    YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
    IN VALUES('Date'[YearMonth])
)
```

<!-- WARNING: formatter failed for Net Change: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Net Change
```DAX
[New Hire Count] - [Leaver Count]
```

## Monthly New Hires
```DAX

```

<!-- WARNING: formatter failed for VAR _YearMonth: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _YearMonth
```DAX
SELECTEDVALUE('Date'[YearMonth])
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
```

<!-- WARNING: formatter failed for YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date]): 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date])
```DAX
_YearMonth
    )
```

## Monthly Leavers
```DAX

```

<!-- WARNING: formatter failed for VAR _YearMonth: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _YearMonth
```DAX
SELECTEDVALUE('Date'[YearMonth])
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
        NOT(
            ISBLANK('Employee'[leave_date])
        ) &&
```

<!-- WARNING: formatter failed for YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date]): 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
```DAX
_YearMonth
    )
```

<!-- WARNING: formatter failed for Monthly Net Change: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Monthly Net Change
```DAX
[Monthly New Hires] - [Monthly Leavers]
```

<!-- WARNING: formatter failed for Dept New Hire Count: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Dept New Hire Count
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date])
    IN VALUES('Date'[YearMonth])
)
```

<!-- WARNING: formatter failed for Dept Leaver Count: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Dept Leaver Count
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    NOT(
        ISBLANK('Employee'[leave_date])
    ) &&
    YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
    IN VALUES('Date'[YearMonth])
)
```

<!-- WARNING: formatter failed for Position New Hire Count: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Position New Hire Count
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date])
    IN VALUES('Date'[YearMonth])
)
```

<!-- WARNING: formatter failed for Position Leaver Count: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Position Leaver Count
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    NOT(
        ISBLANK('Employee'[leave_date])
    ) &&
    YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
    IN VALUES('Date'[YearMonth])
)
```

<!-- WARNING: formatter failed for Employee Count: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Employee Count
```DAX
COUNTROWS('Employee')
```

<!-- WARNING: formatter failed for Employees_by_Age_and_Gender: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Employees_by_Age_and_Gender
```DAX
COUNTROWS('Employee')
```

<!-- WARNING: formatter failed for Employees_by_AgeGroup: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Employees_by_AgeGroup
```DAX
COUNTROWS('Employee')
```

<!-- WARNING: formatter failed for Female_Employees: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Female_Employees
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    'Employee'[Gender_Eng] = "woman"
)
```

<!-- WARNING: formatter failed for Female_Ratio: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Female_Ratio
```DAX
DIVIDE([Female_Employees], [Total_Employees])
```

<!-- WARNING: formatter failed for Male_Employees: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Male_Employees
```DAX
CALCULATE(
    COUNTROWS('Employee'),
    'Employee'[Gender_Eng] = "man"
)
```

## Retention Rate
```DAX

```

<!-- WARNING: formatter failed for VAR _period: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _period
```DAX
SELECTEDVALUE ('YearMonthDimension'[YearMonth])
```

<!-- WARNING: formatter failed for VAR _total: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _total
```DAX
CALCULATE (
        COUNTROWS (Employee),
```

<!-- WARNING: formatter failed for Employee[hire_date1]: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Employee[hire_date1]
```DAX
_period
    )
```

<!-- WARNING: formatter failed for VAR _survived: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _survived
```DAX
CALCULATE (
        COUNTROWS (Employee),
```

<!-- WARNING: formatter failed for Employee[hire_date1]: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Employee[hire_date1]
```DAX
_period,
        OR (
            ISBLANK (Employee[leave_date1]),
            Employee[leave_date1] > _period
        )
    )
RETURN
    IF (_total = 0, BLANK(), DIVIDE (_survived, _total))
```

## Dept Turnover Rate
```DAX

```

<!-- WARNING: formatter failed for VAR _dept: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _dept
```DAX
SELECTEDVALUE('Dept'[dept_name])
```

<!-- WARNING: formatter failed for VAR _month: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _month
```DAX
SELECTEDVALUE('Date'[YearMonth])
```

<!-- WARNING: formatter failed for VAR _leavers: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _leavers
```DAX
CALCULATE(
        COUNTROWS('Employee'),
```

<!-- WARNING: formatter failed for 'Dept'[dept_name]: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Dept'[dept_name]
```DAX
_dept,
```

<!-- WARNING: formatter failed for YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date]): 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
```DAX
_month
    )
```

<!-- WARNING: formatter failed for VAR _hc: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _hc
```DAX
CALCULATE(
        COUNTROWS('Employee'),
```

<!-- WARNING: formatter failed for 'Dept'[dept_name]: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Dept'[dept_name]
```DAX
_dept,
```

<!-- WARNING: formatter failed for 'Employee'[hire_date] <: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Employee'[hire_date] <
```DAX
MAX('Date'[Date]) &&
        (ISBLANK('Employee'[leave_date]) || 'Employee'[leave_date] > MAX('Date'[Date]))
    )
RETURN
    DIVIDE(_leavers, _hc, 0)
```

## Headcount Forecast (NextMonth)
```DAX

```

<!-- WARNING: formatter failed for VAR _currentMonth: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _currentMonth
```DAX
MAX('Date'[YearMonth])
```

<!-- WARNING: formatter failed for VAR _last3: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _last3
```DAX
CALCULATETABLE(
        VALUES('Date'[YearMonth]),
```

<!-- WARNING: formatter failed for 'Date'[YearMonth] <: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Date'[YearMonth] <
```DAX
_currentMonth,
        'Date'[YearMonth] > _currentMonth - 3
    )
RETURN
    AVERAGEX(
        _last3,
        [Active Headcount]
    )
```

## Active Headcount
```DAX

```

<!-- WARNING: formatter failed for VAR _maxDate: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _maxDate
```DAX
CALCULATE(
        MAX('Date'[Date]),
        ALLSELECTED('Date')
    )
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
```

<!-- WARNING: formatter failed for 'Employee'[hire_date] <: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Employee'[hire_date] <
```DAX
_maxDate,
        OR(
            ISBLANK('Employee'[leave_date]),
            'Employee'[leave_date] > _maxDate
        )
    )
```

## Cumulative Headcount
```DAX

```

<!-- WARNING: formatter failed for VAR _maxDate: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _maxDate
```DAX
CALCULATE(
        MAX('Date'[Date]),
        ALLSELECTED('Date')
    )
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
```

<!-- WARNING: formatter failed for 'Employee'[hire_date] <: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Employee'[hire_date] <
```DAX
_maxDate
    )
```

<!-- WARNING: formatter failed for Cumulative Net Change: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Cumulative Net Change
```DAX
CALCULATE(
    SUMX(
        FILTER(
            ALL('Date'),
```

<!-- WARNING: formatter failed for 'Date'[Date] <: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Date'[Date] <
```DAX
MAX('Date'[Date])
        ),
        [Net Change]
    )
)
```

## Retention Rate by Cohort
```DAX

```

<!-- WARNING: formatter failed for VAR SelectedCohort: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR SelectedCohort
```DAX
SELECTEDVALUE('Employee'[hire_date])
```

<!-- WARNING: formatter failed for VAR BaseCohortYYYYMM: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR BaseCohortYYYYMM
```DAX
FORMAT(SelectedCohort, "YYYYMM")
```

<!-- WARNING: formatter failed for VAR CohortCount: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR CohortCount
```DAX
CALCULATE(
        COUNTROWS('Employee'),
```

<!-- WARNING: formatter failed for FORMAT('Employee'[hire_date], "YYYYMM"): 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## FORMAT('Employee'[hire_date], "YYYYMM")
```DAX
BaseCohortYYYYMM
    )
```

<!-- WARNING: formatter failed for VAR SurviveCount: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR SurviveCount
```DAX
CALCULATE(
        COUNTROWS('Employee'),
```

<!-- WARNING: formatter failed for FORMAT('Employee'[hire_date], "YYYYMM"): 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## FORMAT('Employee'[hire_date], "YYYYMM")
```DAX
BaseCohortYYYYMM,
        OR(
            ISBLANK('Employee'[leave_date]),
```

<!-- WARNING: formatter failed for 'Employee'[leave_date] >: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## 'Employee'[leave_date] >
```DAX
MAX('Date'[Date])
        )
    )
RETURN
    DIVIDE(SurviveCount, CohortCount, 0)
```

<!-- WARNING: formatter failed for New Hire Rate: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## New Hire Rate
```DAX
DIVIDE ([New Hire Count], [Average Headcount])
```

<!-- WARNING: formatter failed for Average Headcount: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Average Headcount
```DAX
AVERAGEX (
    VALUES ('YearMonthDimension'[YearMonth]),
    [Active Headcount]
)
```

<!-- WARNING: formatter failed for Turnover Rate: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Turnover Rate
```DAX
DIVIDE ([Turnover Leavers], [Active Headcount], 0)
```

## Turnover Leavers
```DAX

```

<!-- WARNING: formatter failed for VAR _period: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## VAR _period
```DAX
SELECTEDVALUE ('YearMonthDimension'[YearMonth]) -- 예: 202302 (정수)
RETURN
    CALCULATE (
        DISTINCTCOUNT (Employee[emp_id]),
```

<!-- WARNING: formatter failed for Employee[leave_date1]: 404 Client Error: Not Found for url: https://www.daxformatter.com/api/daxformatter -->
## Employee[leave_date1]
```DAX
_period -- 그 월에 퇴사한 직원
    )
```
