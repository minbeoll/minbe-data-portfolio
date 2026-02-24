let
    Source = Sales_Final_PQ2,
    Summary =
        Table.Group(
            Source,
            {"Category"},
            {
                {"TotalNetAmount", each List.Sum([NetAmount]), type number},
                {"Rows", each Table.RowCount(_), Int64.Type}
            }
        ),
    Sorted = Table.Sort(Summary, {{"TotalNetAmount", Order.Descending}})
in
    Sorted
