//======================================================
// Project : Monthly Sales Reporting
// Query   : RPT_01_Monthly_Summary
// Purpose : Generate a monthly sales summary report.
// Author  : Minbeoll
//======================================================

let
    // Step 1. Reference the prepared Sales dataset.
    Source = Sales,

    // Step 2. Aggregate sales by YearMonth.
    Summary =
        Table.Group(
            Source,
            {"YearMonth"},
            {
                {"TotalAmount", each List.Sum([Amount]), type number},
                {"TotalNetAmount", each List.Sum([NetAmount]), type number},
                {"Rows", each Table.RowCount(_), Int64.Type}
            }
        ),

    // Step 3. Sort the report in ascending YearMonth order.
    Sorted = Table.Sort(Summary, {{"YearMonth", Order.Ascending}})
in
    Sorted
