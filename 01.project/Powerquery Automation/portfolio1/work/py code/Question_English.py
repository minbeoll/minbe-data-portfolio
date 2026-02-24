import pandas as pd

df = pd.read_excel("Question.xlsx")  
# input.xlsx ← 원본 파일명

# =========================
# 2. 컬럼명 한글 → 영어
# =========================
column_map = {
    "날짜": "Date",
    "대분류": "Category",
    "품목": "Item",
    "담당자": "Manager",
    "판매금액": "SalesAmount"
}

df = df.rename(columns=column_map)

value_map = {
    # category
    "과일": "Fruit",
    "문구": "Stationery",

    # item
    "사과": "Apple",
    "배": "Pear",
    "감": "Persimmon",
    "딸기": "Strawberry",
    "가위": "Scissors",
    "풀": "Glue",
    "볼펜": "Pen",
    "줄자": "Ruler",
    "연필": "Pencil",

    # manager
    "홍길동": "Tom",
    "철이": "Brian",

    # summary texts
    "집 계": "Summary",
    "판매 총 금액": "Total Sales"
}

# ===============================
# 4. 데이터프레임 전체 값 치환
# ===============================
df = df.replace(value_map)

# ===============================
# 5. 날짜 컬럼 정리 (datetime → date)
# ===============================
df["Date"] = pd.to_datetime(df["Date"]).dt.date


# =========================
# 4. 결과 저장
# =========================
df.to_excel("output_english5.xlsx", index=False)

print("✅ 변환 완료: output_english.xlsx 생성됨")