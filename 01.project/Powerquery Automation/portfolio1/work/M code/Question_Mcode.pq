let
    
    // 1️⃣ 원본 불러오기 (표 이름 수정 가능)
    Source =
        Excel.CurrentWorkbook(){[Name="Table1"]}[Content],

    // 2️⃣ 컬럼 타입 정리
    Typed =
        Table.TransformColumnTypes(
            Source,
            {
                {"Date", type date},
                {"Category", type text},
                {"Item", type text},
                {"Manager", type text},
                {"SalesAmount", Int64.Type}
            }
        ),

    // 3) 분류용 품목 리스트 (필요하면 여기만 추가/수정)
    FruitItems = {"Apple","Pear","Persimmon","Strawberry"},
    StationeryItems = {"Scissors","Glue","Pen","Ruler","Pencil"},

    // 4) Category가 비어있으면 Item으로 채우기 (Fruit/Stationery)
    CategoryFixed =
        Table.AddColumn(
            Typed,
            "CategoryFixed",
            each
                let
                    cat = [Category],
                    item = [Item]
                in
                    if cat <> null and Text.Trim(cat) <> "" then Text.Trim(cat)
                    else if List.Contains(StationeryItems, item) then "Stationery"
                    else if List.Contains(FruitItems, item) then "Fruit"
                    else "Unknown",
            type text
        ),

    // 5) Manager + CategoryFixed 기준 합계
    Grouped =
        Table.Group(
            CategoryFixed,
            {"Manager", "CategoryFixed"},
            {{"TotalSales", each List.Sum([SalesAmount]), type number}}
        ),

    // 6) Pivot (Fruit / Stationery 고정)
    Pivoted =
        Table.Pivot(
            Grouped,
            {"Fruit","Stationery"},
            "CategoryFixed",
            "TotalSales",
            List.Sum
        ),

    // 7) null -> 0
    Filled =
        Table.ReplaceValue(
            Pivoted,
            null,
            0,
            Replacer.ReplaceValue,
            {"Fruit","Stationery"}
        ),
    
    // 1) 정렬용 순서 컬럼 추가 (Tom 먼저)
    AddSortKey =
        Table.AddColumn(
            Filled,
            "SortKey",
            each if [Manager] = "Tom" then 1 else 2,
            Int64.Type
        ),

    // 2) SortKey 기준 정렬
    SortedCustom =
        Table.Sort(AddSortKey, {{"SortKey", Order.Ascending}}),


    // 1) Manager별로 "블록 테이블" 생성
    AddBlock =
        Table.AddColumn(
            SortedCustom,
            "Block",
            each
                let
                    mgr = [Manager],
                    fruit = [Fruit],
                    stat = [Stationery]
                in
                    #table(
                        {"Label", "Fruit", "Stationery"},
                        {
                            {mgr, null, null},
                            {"Total Sales", fruit, stat},
                            {null, null, null}
                        }
                    )
        ),

    
    // 2) Block 컬럼만 추출
    BlocksOnly =
        Table.SelectColumns(AddBlock, {"Block"}),

    // 3) 모든 블록을 하나의 테이블로 합치기
    Combined =
        Table.Combine(BlocksOnly[Block])

in
    Combined
