let
    Source = Sales_Final_PQ2,
    Summary =
        Table.Group(
            Source,
            {"Item"},
            {
                {"TotalNetAmount", each List.Sum([NetAmount]), type number},
                {"Rows", each Table.RowCount(_), Int64.Type}
            }
        ),
    Sorted = Table.Sort(Summary, {{"TotalNetAmount", Order.Descending}}),
    Top5 = Table.FirstN(Sorted, 5)
in
    Top5
