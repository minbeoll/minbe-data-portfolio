let
    Source = Mapping_query,

    // 매핑 안 된 행만
    UnmappedRows =
        Table.SelectRows(
            Source,
            each [SalesManager] = null
        ),

    // 매핑 기준 키만 선택
    SelectKeys =
        Table.SelectColumns(
            UnmappedRows,
            {"Branch","Item"}
        ),

    // 중복 제거 (유니크 키만)
    DistinctKeys =
        Table.Distinct(SelectKeys),

    Sorted =
        Table.Sort(DistinctKeys, {{"Branch", Order.Ascending}})
in
    Sorted
