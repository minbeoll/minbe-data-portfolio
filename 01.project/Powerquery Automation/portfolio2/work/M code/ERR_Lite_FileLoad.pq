let
    FolderPath = "C:\Users\minbe\Desktop\파워쿼리 포트폴리오1",

    Source = Folder.Files(FolderPath),

    // 숨김/임시파일 제거
    Files =
        Table.SelectRows(
            Source,
            each ([Attributes]?[Hidden]? <> true)
                and (not Text.StartsWith([Name], "~$"))
        ),

    // 엑셀 파일만 (필요하면 .csv도 추가 가능)
    ExcelFiles =
        Table.SelectRows(
            Files,
            each List.Contains({".xlsx",".xlsm",".xlsb",".xls"}, Text.Lower([Extension]))
        ),

    // 파일 열기 시도 (에러를 값으로 보관)
    TryOpen =
        Table.AddColumn(
            ExcelFiles,
            "Try",
            each try Excel.Workbook([Content], null, true),
            type any
        ),

    // 에러만 필터
    OnlyErrors =
        Table.SelectRows(
            TryOpen,
            each [Try][HasError] = true
        ),

    // 에러 메시지 추출
    AddMsg =
        Table.AddColumn(
            OnlyErrors,
            "ErrorMessage",
            each try [Try][Error][Message] otherwise "Unknown error",
            type text
        ),

    // 보기 좋게 컬럼 정리
    Result =
        Table.SelectColumns(
            AddMsg,
            {"Name","Extension","Date modified","Size","ErrorMessage"}
        ),

    Sorted = Table.Sort(Result, {{"Date modified", Order.Descending}})
in
    Sorted
