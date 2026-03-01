import re
import time
import requests
from pathlib import Path


SQLBI_URL = "https://www.daxformatter.com/api/daxformatter"


def format_dax_sqlbi(dax_code: str, *, list_sep=",", dec_sep=".") -> str:
    """
    SQLBI DAX Formatter API로 100점 포맷 반환
    """
    dax_code = dax_code.strip()
    if not dax_code:
        return ""

    payload = {
        "Dax": dax_code,
        "ListSeparator": list_sep,
        "DecimalSeparator": dec_sep,
    }

    r = requests.post(SQLBI_URL, json=payload, timeout=30)
    r.raise_for_status()
    data = r.json()
    # API 응답 키: formatted
    return data.get("formatted", "").strip()


def split_measures_from_text(text: str):
    """
    MD/텍스트에서 'Measure Name =' 패턴을 기준으로 measure 블록 분리.
    - 제목:  라인 시작에서  <이름> =
    - 본문:  다음 제목 또는 EOF까지
    """
    # 예: "Active Headcount =" / "Dept New Hire Count="
    title_re = re.compile(r"^\s*([^\n=]+?)\s*=\s*$", re.MULTILINE)

    matches = list(title_re.finditer(text))
    if not matches:
        return []

    blocks = []
    for i, m in enumerate(matches):
        name = m.group(1).strip()
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        body = text[start:end].strip()

        # body에서 앞/뒤 불필요 공백 정리
        blocks.append((name, body))

    return blocks


def build_markdown(measures, *, sleep_sec=0.25):
    """
    measures: List[(name, dax_body)]
    """
    out_lines = []
    for idx, (name, dax_raw) in enumerate(measures, start=1):
        # 본문이 "CALCULATE(...)" 한 줄로 축약돼 있어도 그대로 포맷 시도
        try:
            formatted = format_dax_sqlbi(dax_raw)
        except Exception as e:
            formatted = dax_raw  # 실패하면 원문 유지
            out_lines.append(f"<!-- WARNING: formatter failed for {name}: {e} -->")

        # Markdown: 제목 + DAX fenced block
        out_lines.append(f"## {name}")
        out_lines.append("```DAX")
        out_lines.append(formatted)
        out_lines.append("```")
        out_lines.append("")  # measure 사이 빈 줄

        # 너무 빠르면 서버가 싫어할 수 있으니 살짝 텀
        if sleep_sec:
            time.sleep(sleep_sec)

    return "\n".join(out_lines).rstrip() + "\n"


def main(
    input_path: str = "DAX.md",
    output_path: str = "DAX_formatted.md",
):
    in_path = Path(input_path)
    if not in_path.exists():
        raise FileNotFoundError(f"Input not found: {in_path.resolve()}")

    raw_text = in_path.read_text(encoding="utf-8", errors="ignore")
    measures = split_measures_from_text(raw_text)

    if not measures:
        raise ValueError(
            "measure 제목 패턴을 못 찾았어. "
            "라인 단독으로 'Measure Name =' 형태인지 확인해줘."
        )

    md = build_markdown(measures)
    Path(output_path).write_text(md, encoding="utf-8")

    print(f"✅ Done: {len(measures)} measures formatted")
    print(f"   Input : {in_path.resolve()}")
    print(f"   Output: {Path(output_path).resolve()}")


if __name__ == "__main__":
    main()