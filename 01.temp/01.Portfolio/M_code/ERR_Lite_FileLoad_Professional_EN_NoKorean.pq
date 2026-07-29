//======================================================
// Project : Monthly Sales Reporting
// Query   : ERR_Lite_FileLoad
// Purpose : Identify workbook loading errors during folder import.
// Author  : Minbeoll
//======================================================

let
    FolderPath = "C:\Users\minbe\Desktop\PowerQuery_Portfolio",

    // Step 1. Load all files from the source folder.
    Source = Folder.Files(FolderPath),

    // Step 2. Remove hidden and temporary files.
    Files =
        Table.SelectRows(
            Source,
            each ([Attributes]?[Hidden]? <> true)
                and (not Text.StartsWith([Name], "~$"))
        ),

    // Step 3. Keep supported Excel workbooks only.
    ExcelFiles =
        Table.SelectRows(
            Files,
            each List.Contains({".xlsx",".xlsm",".xlsb",".xls"}, Text.Lower([Extension]))
        ),

    // Step 4. Attempt to open each workbook.
    TryOpen =
        Table.AddColumn(
            ExcelFiles,
            "Try",
            each try Excel.Workbook([Content], null, true),
            type any
        ),

    // Step 5. Keep only failed workbook loads.
    OnlyErrors =
        Table.SelectRows(TryOpen, each [Try][HasError] = true),

    // Step 6. Extract the error message.
    AddMsg =
        Table.AddColumn(
            OnlyErrors,
            "ErrorMessage",
            each try [Try][Error][Message] otherwise "Unknown error",
            type text
        ),

    // Step 7. Select the output columns.
    Result =
        Table.SelectColumns(
            AddMsg,
            {"Name","Extension","Date modified","Size","ErrorMessage"}
        ),

    // Step 8. Sort the results by the modified date.
    Sorted = Table.Sort(Result, {{"Date modified", Order.Descending}})
in
    Sorted
