//======================================================
// Project : Monthly Sales Reporting
// Query   : RPT_02_Branch_by_Month
// Purpose : Generate monthly sales performance by branch.
// Author  : Minbeoll
//======================================================

let
    // Step 1. Reference the prepared Sales dataset.
    Source = Sales_Final_PQ2,

    // Step 2. Aggregate Net Amount by YearMonth and Branch.
    Summary =
        Table.Group(
            Source,
            {"YearMonth","Branch"},
            {
                {"TotalNetAmount", each List.Sum([NetAmount]), type number},
                {"Rows", each Table.RowCount(_), Int64.Type}
            }
        ),

    // Step 3. Sort by YearMonth and Net Amount.
    Sorted =
        Table.Sort(
            Summary,
            {{"YearMonth", Order.Ascending}, {"TotalNetAmount", Order.Descending}}
        )
in
    Sorted
