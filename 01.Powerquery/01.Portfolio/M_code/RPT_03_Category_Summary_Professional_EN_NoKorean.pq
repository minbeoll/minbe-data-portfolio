//======================================================
// Project : Monthly Sales Reporting
// Query   : RPT_03_Category_Summary
// Purpose : Generate a sales summary by product category.
// Author  : Minbeoll
//======================================================

let
    // Step 1. Reference the prepared Sales dataset.
    Source = Sales_Final_PQ2,

    // Step 2. Aggregate Net Amount by Category.
    Summary =
        Table.Group(
            Source,
            {"Category"},
            {
                {"TotalNetAmount", each List.Sum([NetAmount]), type number},
                {"Rows", each Table.RowCount(_), Int64.Type}
            }
        ),

    // Step 3. Sort the report by Net Amount in descending order.
    Sorted =
        Table.Sort(
            Summary,
            {{"TotalNetAmount", Order.Descending}}
        )
in
    Sorted
