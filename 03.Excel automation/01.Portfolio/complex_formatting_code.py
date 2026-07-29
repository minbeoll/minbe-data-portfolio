import xlwings as xw
from collections import defaultdict

# =========================
# 사용자 설정
# =========================
file_path = r"C:\Users\minbe\Desktop\company_stock_distinct.xlsx"
TARGET_SHEET = "일일 결과"

COL = "Gn"     # 오늘 적용할 열 (대문자 권장)
SRC_COL = "Vp" # 회사명+기호가 들어있는 열 (대문자 권장)
COL, SRC_COL = COL.upper(), SRC_COL.upper()


# =========================
# 유틸: Shape 이름(절대 고유)
# =========================
def make_shape_name(sheet_name: str, col: str, row: int, tag: str) -> str:
    # 예: line__일일_결과__GM__25__CLUB
    sheet_tag = sheet_name.replace(" ", "_")
    return f"line__{sheet_tag}__{col}__{row}__{tag}"


# =========================
# 유틸: 셀 내부 패딩(선이 옆셀과 이어져 보이지 않게)
# =========================
def _pad(cell, ratio=0.08, min_pt=2.0, max_pt=6.0) -> float:
    # 셀 짧은 변의 8%를 패딩으로, 2~6pt 범위에서 클램프
    p = min(cell.width, cell.height) * ratio
    if p < min_pt: p = min_pt
    if p > max_pt: p = max_pt
    return p


# =========================
# 메인
# =========================
wb = xw.Book(file_path)
ws = wb.sheets[TARGET_SHEET]
app = wb.app

# 속도/안정 옵션 저장
prev_calc = app.api.Calculation
prev_screen = app.screen_updating
prev_alerts = app.display_alerts
prev_events = app.api.EnableEvents

try:
    # 속도/안정 옵션 적용
    app.api.Calculation = -4135   # xlCalculationManual
    app.screen_updating = False
    app.display_alerts = False
    app.api.EnableEvents = False

    # === 회사명+기호 열 읽기 ===
    last_row_y = ws.range(SRC_COL + str(ws.cells.last_cell.row)).end('up').row
    y_values = ws.range(f"{SRC_COL}2:{SRC_COL}{last_row_y}").value
    if not isinstance(y_values, list):
        y_values = [y_values]

    company_symbols = defaultdict(list)
    for v in y_values:
        if isinstance(v, str) and len(v) > 1:
            name, sym = v[:-1].strip(), v[-1]
            if sym in ['♬','♨','☎','√','ø','★','®','♥','♣']:
                company_symbols[name].append(sym)

    # === 대상 열 읽기 ===
    last_row_f = ws.range(COL + str(ws.cells.last_cell.row)).end('up').row
    f_values = ws.range(f"{COL}2:{COL}{last_row_f}").value
    if not isinstance(f_values, list):
        f_values = [f_values]

    # === 시트 내 기존 도형 캐시(이름 → 객체) ===
    shapes = {s.Name: s for s in ws.api.Shapes}

    # === 상수 ===
    xlNone = -4142
    xlCriss = 16

    sheet_name = ws.name

    # === 메인 루프 ===
    for i, val in enumerate(f_values, start=2):
        cell = ws.range(f"{COL}{i}")

        # 우리가 관리하는 이번 셀의 선 이름(빨강CLUB/초록TEL)
        club_name = make_shape_name(sheet_name, COL, i, "CLUB")
        tel_name  = make_shape_name(sheet_name, COL, i, "TEL")

        # 0) 셀 서식·무늬·대각선 초기화 (해당 셀만)
        cell.api.ClearFormats()
        cell.api.Borders(5).LineStyle = xlNone  # DiagonalDown
        cell.api.Borders(6).LineStyle = xlNone  # DiagonalUp
        cell.api.Interior.Pattern = xlNone

        # 0-1) 기존 Shape(이번 셀 것만) 제거 — 옆열/다른 셀은 건드리지 않음
        old = shapes.pop(club_name, None)
        if old: old.Delete()
        old2 = shapes.pop(tel_name, None)
        if old2: old2.Delete()

        # 값 검증
        if not (isinstance(val, str) and len(val) > 1):
            continue

        name = val[:-1].strip()
        symbols = company_symbols.get(name, [])

        # 1) ♥ : 대각선 교차 무늬
        if '♥' in symbols:
            interior = cell.api.Interior
            interior.Pattern = xlCriss
            interior.PatternColor = 0x969696
        # (없으면 위 초기화 상태 유지)

        # 2) ☎ : 초록 ↗ 선 (패딩 적용)
        if '☎' in symbols:
            pad = _pad(cell)
            x1 = cell.left + pad
            y1 = cell.top + cell.height - pad   # 좌하(안쪽)
            x2 = cell.left + cell.width - pad
            y2 = cell.top + pad                 # 우상(안쪽)
            line2 = ws.api.Shapes.AddLine(x1, y1, x2, y2)
            line2.Name = tel_name
            line2.Line.Weight = 2
            line2.Line.ForeColor.RGB = 0x50B000
            line2.Line.Visible = True
            line2.Placement = 2  # 셀과 함께 이동/크기조정

        # 3) ♣ : 빨강 ↘ 선 (패딩 적용)
        if '♣' in symbols:
            pad = _pad(cell)
            x1 = cell.left + pad
            y1 = cell.top + pad                 # 좌상(안쪽)
            x2 = cell.left + cell.width - pad
            y2 = cell.top + cell.height - pad   # 우하(안쪽)
            line = ws.api.Shapes.AddLine(x1, y1, x2, y2)
            line.Name = club_name
            line.Line.Weight = 2
            line.Line.ForeColor.RGB = 0x0000FF  # 빨강(BGR)
            line.Line.Visible = True
            line.Placement = 2

        # 4) 예외 조합 우선 (♨+ø)
        if '♨' in symbols and 'ø' in symbols and '★' not in symbols:
            cell.color = (255, 255, 0)
            cell.font.color = (255, 105, 180)
            cell.font.bold = True
        elif '♨' in symbols and 'ø' in symbols and '★' in symbols:
            cell.color = (255, 255, 0)
            cell.font.color = (255, 105, 180)
            cell.font.bold = True
            cell.font.italic = True
            cell.font.name = "휴먼둥근헤드라인"
        else:
            # 5) 기본 규칙들
            if '♬' in symbols:
                for b in (7, 8, 9, 10):  # 좌/상/하/우
                    bd = cell.api.Borders(b)
                    bd.LineStyle = 1
                    bd.Weight = 3
                    bd.Color = 0x0000EE  # BGR 파란계열
            if '♨' in symbols and not ('ø' in symbols and '★' in symbols):
                cell.color = (242, 206, 239)   # 연분홍
            if '√' in symbols:
                cell.api.Font.Underline = 5    # 이중 밑줄
                cell.font.color = (0, 0, 0)
            if 'ø' in symbols and '♨' not in symbols:
                cell.color = (255, 255, 0)     # 노랑
            if '★' in symbols and not ('♨' in symbols and 'ø' in symbols):
                f = cell.font
                f.name, f.italic, f.bold, f.color = "HY견고딕", True, True, (190, 80, 20)

    wb.save()

finally:
    # 옵션 복구 (안정)
    app.api.Calculation = prev_calc
    app.screen_updating = prev_screen
    app.display_alerts = prev_alerts
    app.api.EnableEvents = prev_events
    wb.close()
