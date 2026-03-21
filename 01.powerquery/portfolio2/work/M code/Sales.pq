let
    FolderPath = "C:\Users\minbe\Desktop\파워쿼리 포트폴리오",

    Source = Folder.Files(FolderPath),

    // xlsx만 + 숨김파일 제외
    XlsxFiles =
        Table.SelectRows(
            Source,
            each Text.Lower([Extension]) = ".xlsx"
                and [Attributes]?[Hidden]? <> true
                and not Text.StartsWith([Name], "~$")
        ),

    // 각 xlsx에서 데이터 테이블 꺼내오기
    AddTable =
        Table.AddColumn(
        XlsxFiles,
        "Data",
        each
            let
                path = [Folder Path] & [Name],
                wbTry = try Excel.Workbook(File.Contents(path), null, true)
            in
                if wbTry[HasError] then null
                else
                    let
                        wb = wbTry[Value],
                        tblCandidates = Table.SelectRows(wb, each [Kind] = "Table"),
                        data1 = if Table.RowCount(tblCandidates) > 0 then tblCandidates{0}[Data] else null,
                        shtCandidates = Table.SelectRows(wb, each [Kind] = "Sheet"),
                        data2 = if data1 <> null then data1 else if Table.RowCount(shtCandidates) > 0 then shtCandidates{0}[Data] else null,
                        promoted = if data2 = null then null else try Table.PromoteHeaders(data2, [PromoteAllScalars=true]) otherwise data2
                    in
                        promoted
    ),

    // null 데이터 제거
    KeepData = Table.SelectRows(AddTable, each [Data] <> null),

    // 표준화 함수: 컬럼명 제각각 통일 + 필요한 컬럼만
    Standardize = (t as table) as table =>
        let
            // 컬럼명 청소(공백/숨은문자 제거)
            t0 = Table.TransformColumnNames(t, each Text.Trim(Text.Clean(_))),
            Cols = Table.ColumnNames(t0),

            RenamePairs =
                List.RemoveNulls({
                    if List.Contains(Cols, "Date") then null else if List.Contains(Cols, "SalesDate") then {"SalesDate","Date"} else if List.Contains(Cols, "날짜") then {"날짜","Date"} else null,
                    if List.Contains(Cols, "Branch") then null else if List.Contains(Cols, "Store") then {"Store","Branch"} else if List.Contains(Cols, "지점") then {"지점","Branch"} else null,
                    if List.Contains(Cols, "Item") then null else if List.Contains(Cols, "Product") then {"Product","Item"} else if List.Contains(Cols, "아이템") then {"아이템","Item"} else null,
                    if List.Contains(Cols, "Qty") then null else if List.Contains(Cols, "Quantity") then {"Quantity","Qty"} else if List.Contains(Cols, "수량") then {"수량","Qty"} else null,
                    if List.Contains(Cols, "UnitPrice") then null else if List.Contains(Cols, "Price") then {"Price","UnitPrice"} else if List.Contains(Cols, "단가") then {"단가","UnitPrice"} else null,
                    if List.Contains(Cols, "DiscountRate") then null else if List.Contains(Cols, "Discount") then {"Discount","DiscountRate"} else if List.Contains(Cols, "할인율") then {"할인율","DiscountRate"} else null
                }),

            Renamed = if List.Count(RenamePairs) > 0 then Table.RenameColumns(t0, RenamePairs, MissingField.Ignore) else t0,

            // Channel 없으면 생성
            WithChannel =
                if List.Contains(Table.ColumnNames(Renamed), "Channel")
                then Renamed
                else Table.AddColumn(Renamed, "Channel", each null, type text),

            NeedCols = {"Date","Branch","Item","Qty","UnitPrice","DiscountRate","Channel"},
            Selected = Table.SelectColumns(WithChannel, NeedCols, MissingField.UseNull)
        in
            Selected,
        
    ApplyStandardize = Table.AddColumn(KeepData, "Std", each Standardize([Data])),
    Combined = Table.Combine(ApplyStandardize[Std]),

    // Date null-safe
    DateFixed =
        Table.TransformColumns(
            Combined,
            {{"Date", each
                let v = _
                in
                    if v = null then null
                    else try Date.From(v) otherwise Date.FromText(Text.Replace(Text.From(v),"/","-"))
            , type date}}
        ),

    // DiscountRate null-safe + % 처리
    DiscountFixed =
        Table.TransformColumns(
            DateFixed,
            {{"DiscountRate", each
                let
                    v = _,
                    out =
                        if v = null then null
                        else
                            let
                                txt = Text.Trim(Text.From(v)),
                                num =
                                    if txt = "" then null
                                    else if Text.EndsWith(txt, "%")
                                        then Number.FromText(Text.BeforeDelimiter(txt, "%")) / 100
                                        else Number.FromText(txt)
                            in num
                in
                    out, type number}}
        ),

    // 타입 변환
    Typed =
        Table.TransformColumnTypes(
            DiscountFixed,
            {
                {"Branch", type text},
                {"Item", type text},
                {"Qty", Int64.Type},
                {"UnitPrice", type number},
                {"Channel", type text}
            }
        ),

    // 계산 컬럼
    AddAmount = Table.AddColumn(Typed, "Amount", each [Qty] * [UnitPrice], type number),
    AddNet = Table.AddColumn(AddAmount, "NetAmount", each [Amount] * (1 - [DiscountRate]), type number),
    AddYearMonth = Table.AddColumn(AddNet, "YearMonth", each if [Date] = null then null else Date.ToText([Date], "yyyy-MM"), type text)
in
    AddYearMonth
