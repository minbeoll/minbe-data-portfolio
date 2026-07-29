//======================================================
// Project : Monthly Sales Reporting
// Query   : RPT_04_Top5_Items
// Purpose : Generate the Top 5 products by Net Sales.
// Author  : Minbeoll
//======================================================

let
    // Step 1. Reference the prepared Sales dataset.
    Source = Sales_Final_PQ2,

    // Step 2. Aggregate Net Amount by Item.
    Summary =
        Table.Group(
            Source,
            {"Item"},
            {
                {"TotalNetAmount", each List.Sum([NetAmount]), type number},
                {"Rows", each Table.RowCount(_), Int64.Type}
            }
        ),

    // Step 3. Sort items by Net Amount in descending order.
    Sorted =
        Table.Sort(
            Summary,
            {{"TotalNetAmount", Order.Descending}}
        ),

    // Step 4. Return the Top 5 items.
    Top5 = Table.FirstN(Sorted, 5)

in
    Top5
