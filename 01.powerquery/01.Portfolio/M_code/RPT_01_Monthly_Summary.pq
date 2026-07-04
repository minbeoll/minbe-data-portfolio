let
    Source = Sales,
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
    Sorted = Table.Sort(Summary, {{"YearMonth", Order.Ascending}})
in
    Sorted
