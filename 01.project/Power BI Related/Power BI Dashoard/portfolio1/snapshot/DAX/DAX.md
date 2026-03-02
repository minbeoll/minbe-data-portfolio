Total_Employees =
COUNTROWS('Employee')

New Hire Count =

CALCULATE(
    COUNTROWS('Employee'),
    YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date])
    IN VALUES('Date'[YearMonth])
)

Leaver Count =

CALCULATE(
    COUNTROWS('Employee'),
    NOT(
        ISBLANK('Employee'[leave_date])
    ) &&
    YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
    IN VALUES('Date'[YearMonth])
)

Net Change =
[New Hire Count] - [Leaver Count]

Monthly New Hires =

VAR _YearMonth =
    SELECTEDVALUE('Date'[YearMonth])
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
        YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date]) =
        _YearMonth
    )

Monthly Leavers =

VAR _YearMonth =
    SELECTEDVALUE('Date'[YearMonth])
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
        NOT(
            ISBLANK('Employee'[leave_date])
        ) &&
        YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date]) =
        _YearMonth
    )

Monthly Net Change =
[Monthly New Hires] - [Monthly Leavers]

Dept New Hire Count =

CALCULATE(
    COUNTROWS('Employee'),
    YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date])
    IN VALUES('Date'[YearMonth])
)

Dept Leaver Count =

CALCULATE(
    COUNTROWS('Employee'),
    NOT(
        ISBLANK('Employee'[leave_date])
    ) &&
    YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
    IN VALUES('Date'[YearMonth])
)

Position New Hire Count =

CALCULATE(
    COUNTROWS('Employee'),
    YEAR('Employee'[hire_date]) * 100 + MONTH('Employee'[hire_date])
    IN VALUES('Date'[YearMonth])
)

Position Leaver Count =

CALCULATE(
    COUNTROWS('Employee'),
    NOT(
        ISBLANK('Employee'[leave_date])
    ) &&
    YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date])
    IN VALUES('Date'[YearMonth])
)

Employee Count =
COUNTROWS('Employee')

Employees_by_Age_and_Gender =

COUNTROWS('Employee')

Employees_by_AgeGroup =

COUNTROWS('Employee')

Female_Employees =

CALCULATE(
    COUNTROWS('Employee'),
    'Employee'[Gender_Eng] = "woman"
)

Female_Ratio =

DIVIDE([Female_Employees], [Total_Employees])

Male_Employees =

CALCULATE(
    COUNTROWS('Employee'),
    'Employee'[Gender_Eng] = "man"
)

Retention Rate =

VAR _period =
    SELECTEDVALUE ('YearMonthDimension'[YearMonth])
VAR _total =
    CALCULATE (
        COUNTROWS (Employee),
        Employee[hire_date1] =
        _period
    )
VAR _survived =
    CALCULATE (
        COUNTROWS (Employee),
        Employee[hire_date1] =
        _period,
        OR (
            ISBLANK (Employee[leave_date1]),
            Employee[leave_date1] > _period
        )
    )
RETURN
    IF (_total = 0, BLANK(), DIVIDE (_survived, _total))


Dept Turnover Rate =

VAR _dept =
    SELECTEDVALUE('Dept'[dept_name])
VAR _month =
    SELECTEDVALUE('Date'[YearMonth])
VAR _leavers =
    CALCULATE(
        COUNTROWS('Employee'),
        'Dept'[dept_name] =
        _dept,
        YEAR('Employee'[leave_date]) * 100 + MONTH('Employee'[leave_date]) =
        _month
    )
VAR _hc =
    CALCULATE(
        COUNTROWS('Employee'),
        'Dept'[dept_name] =
        _dept,
        'Employee'[hire_date] <=
        MAX('Date'[Date]) &&
        (ISBLANK('Employee'[leave_date]) || 'Employee'[leave_date] > MAX('Date'[Date]))
    )
RETURN
    DIVIDE(_leavers, _hc, 0)

    Headcount Forecast (NextMonth) =

VAR _currentMonth =
    MAX('Date'[YearMonth])
VAR _last3 =
    CALCULATETABLE(
        VALUES('Date'[YearMonth]),
        'Date'[YearMonth] <=
        _currentMonth,
        'Date'[YearMonth] > _currentMonth - 3
    )
RETURN
    AVERAGEX(
        _last3,
        [Active Headcount]
    )

Active Headcount =

VAR _maxDate =
    CALCULATE(
        MAX('Date'[Date]),
        ALLSELECTED('Date')
    )
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
        'Employee'[hire_date] <=
        _maxDate,
        OR(
            ISBLANK('Employee'[leave_date]),
            'Employee'[leave_date] > _maxDate
        )
    )

Cumulative Headcount =

VAR _maxDate =
    CALCULATE(
        MAX('Date'[Date]),
        ALLSELECTED('Date')
    )
RETURN
    CALCULATE(
        COUNTROWS('Employee'),
        'Employee'[hire_date] <=
        _maxDate
    )

Cumulative Net Change =

CALCULATE(
    SUMX(
        FILTER(
            ALL('Date'),
            'Date'[Date] <=
            MAX('Date'[Date])
        ),
        [Net Change]
    )
)

Retention Rate by Cohort =

VAR SelectedCohort =
    SELECTEDVALUE('Employee'[hire_date])
VAR BaseCohortYYYYMM =
    FORMAT(SelectedCohort, "YYYYMM")
VAR CohortCount =
    CALCULATE(
        COUNTROWS('Employee'),
        FORMAT('Employee'[hire_date], "YYYYMM") =
        BaseCohortYYYYMM
    )
VAR SurviveCount =
    CALCULATE(
        COUNTROWS('Employee'),
        FORMAT('Employee'[hire_date], "YYYYMM") =
        BaseCohortYYYYMM,
        OR(
            ISBLANK('Employee'[leave_date]),
            'Employee'[leave_date] >=
            MAX('Date'[Date])
        )
    )
RETURN
    DIVIDE(SurviveCount, CohortCount, 0)

New Hire Rate =

DIVIDE ([New Hire Count], [Average Headcount])


Average Headcount =

AVERAGEX (
    VALUES ('YearMonthDimension'[YearMonth]),
    [Active Headcount]
)


Turnover Rate =

DIVIDE ([Turnover Leavers], [Active Headcount], 0)

Turnover Leavers =

VAR _period =
    SELECTEDVALUE ('YearMonthDimension'[YearMonth]) -- 예: 202302 (정수)
RETURN
    CALCULATE (
        DISTINCTCOUNT (Employee[emp_id]),
        Employee[leave_date1] =
        _period -- 그 월에 퇴사한 직원
    )

