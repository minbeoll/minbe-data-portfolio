//======================================================
// Project : Monthly Sales Reporting
// Query   : Mapping_Query
// Purpose : Apply business mapping tables and validate mapping completeness.
// Author  : Minbeoll
//======================================================

let
    //------------------------------------------------------
    // Step 0. Reference the existing Sales query.
    //------------------------------------------------------
    Sales = Sales,   // Update the query name if your Sales query uses a different name.

    //------------------------------------------------------
    // Step 1. Load the mapping workbook.
    //------------------------------------------------------
    MappingFilePath = "C:\Users\minbe\Desktop\Mapping_PQ2.xlsx",  // Update this path to match your local environment.

    MapSource = Excel.Workbook(File.Contents(MappingFilePath), null, true),

    ManagerMapRaw = MapSource{[Item="ManagerMap", Kind="Sheet"]}[Data],
    ItemMapRaw    = MapSource{[Item="ItemMap",    Kind="Sheet"]}[Data],
    BranchMapRaw  = MapSource{[Item="BranchMap",  Kind="Sheet"]}[Data],

    ManagerMap = Table.TransformColumnTypes(
        Table.PromoteHeaders(ManagerMapRaw, [PromoteAllScalars=true]),
        {{"Branch", type text}, {"Item", type text}, {"SalesManager", type text}}
    ),

    ItemMap = Table.TransformColumnTypes(
        Table.PromoteHeaders(ItemMapRaw, [PromoteAllScalars=true]),
        {{"Item", type text}, {"Category", type text}, {"Account", type text}}
    ),

    BranchMap = Table.TransformColumnTypes(
        Table.PromoteHeaders(BranchMapRaw, [PromoteAllScalars=true]),
        {{"Branch", type text}, {"Region", type text}, {"CostCenter", type text}}
    ),

    //------------------------------------------------------
    // Step 2. Merge Sales Manager mapping (Branch + Item).
    //------------------------------------------------------
    M1 = Table.NestedJoin(Sales, {"Branch","Item"}, ManagerMap, {"Branch","Item"}, "m_Manager", JoinKind.LeftOuter),
    E1 = Table.ExpandTableColumn(M1, "m_Manager", {"SalesManager"}, {"SalesManager"}),

    //------------------------------------------------------
    // Step 3. Merge Item mapping (Category and Account).
    //------------------------------------------------------
    M2 = Table.NestedJoin(E1, {"Item"}, ItemMap, {"Item"}, "m_Item", JoinKind.LeftOuter),
    E2 = Table.ExpandTableColumn(M2, "m_Item", {"Category","Account"}, {"Category","Account"}),

    //------------------------------------------------------
    // Step 4. Merge Branch mapping information.
    //------------------------------------------------------
    M3 = Table.NestedJoin(E2, {"Branch"}, BranchMap, {"Branch"}, "m_Branch", JoinKind.LeftOuter),
    E3 = Table.ExpandTableColumn(M3, "m_Branch", {"Region","CostCenter"}, {"Region","CostCenter"}),

    //------------------------------------------------------
    // Step 5. Add a mapping status flag for validation.
    //------------------------------------------------------
    AddMapStatus = Table.AddColumn(
        E3,
        "MapStatus",
        each if [SalesManager] = null or [Category] = null or [Region] = null then "UNMAPPED" else "OK",
        type text
    )

in
    AddMapStatus
