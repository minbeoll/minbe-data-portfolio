let
    // =========================
    // 0) 입력: 너가 이미 만든 결과 쿼리
    // =========================
    Sales = Sales,   // <-- 네 기존 폴더 통합 쿼리 이름이 다르면 여기만 바꿔줘

    // =========================
    // 1) 매핑 파일 로드
    // =========================
    MappingFilePath = "C:\Users\minbe\Desktop\Mapping_PQ2.xlsx",  // <-- 너 PC 경로로 수정

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

    // =========================
    // 2) Merge #1: 담당자 (Branch+Item)
    // =========================
    M1 = Table.NestedJoin(Sales, {"Branch","Item"}, ManagerMap, {"Branch","Item"}, "m_Manager", JoinKind.LeftOuter),
    E1 = Table.ExpandTableColumn(M1, "m_Manager", {"SalesManager"}, {"SalesManager"}),

    // =========================
    // 3) Merge #2: 품목 분류/계정과목 (Item)
    // =========================
    M2 = Table.NestedJoin(E1, {"Item"}, ItemMap, {"Item"}, "m_Item", JoinKind.LeftOuter),
    E2 = Table.ExpandTableColumn(M2, "m_Item", {"Category","Account"}, {"Category","Account"}),

    // =========================
    // 4) Merge #3: 지점 정보 (Branch)
    // =========================
    M3 = Table.NestedJoin(E2, {"Branch"}, BranchMap, {"Branch"}, "m_Branch", JoinKind.LeftOuter),
    E3 = Table.ExpandTableColumn(M3, "m_Branch", {"Region","CostCenter"}, {"Region","CostCenter"}),

    // =========================
    // 5) (선택) 매핑 누락 체크용 컬럼
    // =========================
    AddMapStatus = Table.AddColumn(
        E3,
        "MapStatus",
        each if [SalesManager] = null or [Category] = null or [Region] = null then "UNMAPPED" else "OK",
        type text
    )

in
    AddMapStatus
