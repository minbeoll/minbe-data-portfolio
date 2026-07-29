//======================================================
// Project : Monthly Sales Reporting
// Query   : Sales
// Purpose : Load, standardize, and prepare monthly sales data.
// Author  : Minbeoll
//======================================================

let
    FolderPath = "C:\Users\minbe\Desktop\PowerQuery_Portfolio",

    Source = Folder.Files(FolderPath),

    // Step 1. Keep only visible Excel workbooks (.xlsx).
    XlsxFiles =
        Table.SelectRows(
            Source,
            each Text.Lower([Extension]) = ".xlsx"
                and [Attributes]?[Hidden]? <> true
                and not Text.StartsWith([Name], "~$")
        ),

    // Step 2. Load the first available table or worksheet from each workbook.
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

    // Step 3. Remove rows where no data could be loaded.
    KeepData = Table.SelectRows(AddTable, each [Data] <> null),

    // Step 4. Standardize column names and keep only the required fields.
    Standardize = (t as table) as table =>
        let
            // Clean column names by removing spaces and hidden characters.
            t0 = Table.TransformColumnNames(t, each Text.Trim(Text.Clean(_))),
            Cols = Table.ColumnNames(t0),

            RenamePairs =
                List.RemoveNulls({
                    if List.Contains(Cols, "Date") then null else if List.Contains(Cols, "SalesDate") then {"SalesDate","Date"} else if List.Contains(Cols, "Date") then {"Date","Date"} else null,
                    if List.Contains(Cols, "Branch") then null else if List.Contains(Cols, "Store") then {"Store","Branch"} else if List.Contains(Cols, "Branch") then {"Branch","Branch"} else null,
                    if List.Contains(Cols, "Item") then null else if List.Contains(Cols, "Product") then {"Product","Item"} else if List.Contains(Cols, "Item") then {"Item","Item"} else null,
                    if List.Contains(Cols, "Qty") then null else if List.Contains(Cols, "Quantity") then {"Quantity","Qty"} else if List.Contains(Cols, "Qty") then {"Qty","Qty"} else null,
                    if List.Contains(Cols, "UnitPrice") then null else if List.Contains(Cols, "Price") then {"Price","UnitPrice"} else if List.Contains(Cols, "UnitPrice") then {"UnitPrice","UnitPrice"} else null,
                    if List.Contains(Cols, "DiscountRate") then null else if List.Contains(Cols, "Discount") then {"Discount","DiscountRate"} else if List.Contains(Cols, "DiscountRate") then {"DiscountRate","DiscountRate"} else null
                }),

            Renamed = if List.Count(RenamePairs) > 0 then Table.RenameColumns(t0, RenamePairs, MissingField.Ignore) else t0,

            // Add the Channel column if it does not exist.
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

    // Step 5. Safely convert the Date column.
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

    // Step 6. Safely convert DiscountRate and normalize percentage values.
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

    // Step 7. Apply the final data types.
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

    // Step 8. Create calculated columns for reporting.
    AddAmount = Table.AddColumn(Typed, "Amount", each [Qty] * [UnitPrice], type number),
    AddNet = Table.AddColumn(AddAmount, "NetAmount", each [Amount] * (1 - [DiscountRate]), type number),
    AddYearMonth = Table.AddColumn(AddNet, "YearMonth", each if [Date] = null then null else Date.ToText([Date], "yyyy-MM"), type text)
in
    AddYearMonth
