//======================================================
// Project : Monthly Sales Reporting
// Query   : UNMAPPED_Add_To_ManagerMap
// Purpose : Identify unmapped records for the Sales Manager mapping table.
// Author  : Minbeoll
//======================================================

let
    // Step 1. Reference the mapping query.
    Source = Mapping_Query,

    // Step 2. Keep only unmapped records.
    UnmappedRows =
        Table.SelectRows(
            Source,
            each [SalesManager] = null
        ),

    // Step 3. Keep only the mapping key columns.
    SelectKeys =
        Table.SelectColumns(
            UnmappedRows,
            {"Branch","Item"}
        ),

    // Step 4. Remove duplicate mapping keys.
    DistinctKeys =
        Table.Distinct(SelectKeys),

    // Step 5. Sort the results by Branch.
    Sorted =
        Table.Sort(
            DistinctKeys,
            {{"Branch", Order.Ascending}}
        )
in
    Sorted
