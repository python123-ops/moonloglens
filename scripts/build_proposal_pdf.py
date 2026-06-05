from pathlib import Path

from docx import Document
from docx.shared import Pt
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "competition"
PDF_PATH = OUT_DIR / "MoonLogLens项目申报书.pdf"
DOCX_PATH = OUT_DIR / "MoonLogLens项目申报书.docx"

TITLE = "MoonLogLens 项目申报书"
PROJECT_NAME = "MoonLogLens：MoonBit 轻量级结构化日志解析与查询引擎"

SECTIONS = [
    (
        "一、项目简介",
        "MoonLogLens 是一个面向 MoonBit 生态的轻量级结构化日志解析、查询与聚合基础库。项目支持 logfmt 风格日志解析、带位置的错误诊断、字段过滤、全文关键字匹配、字段存在性查询和按字段计数聚合，可作为日志采集与查询系统、自动化构建日志分析、服务运行状态排查等场景的基础组件。",
    ),
    (
        "二、项目方向与适用场景",
        "日志是基础软件系统中最常见的可观测数据来源之一。MoonLogLens 先提供一个小而完整的 MoonBit 日志处理内核，使开发者能够在 MoonBit 程序中快速解析结构化日志、筛选故障事件、统计服务分布，并为后续日志采集、查询系统和可观测性工具奠定基础。适用场景包括服务运行日志快速筛选、自动化构建日志分析、边缘设备日志摘要统计，以及后续日志采集和索引系统建设。",
    ),
    (
        "三、计划实现的核心功能",
        "1. 解析 level=ERROR service=api msg=\"request timeout\" 等 logfmt 风格日志；2. 支持引用值、空格、转义字符和多行文本解析；3. 在错误中返回行列位置，便于定位格式问题；4. 支持 level:ERROR service:api text:\"timeout\" has:trace_id 等查询表达式；5. 提供字段读取、消息读取、过滤匹配和按字段计数聚合 API；6. 提供命令行演示、测试、README、设计文档和 CI 配置。",
    ),
    (
        "四、原创性说明",
        "本项目为原创项目，不是移植已有开源项目。项目围绕 MoonBit 生态中的结构化日志解析与查询需求重新设计数据结构、扫描器、查询语法、错误诊断、测试和 CLI 示例。首版不引入外部依赖，不依赖数据库或平台服务，聚焦可复用、可测试、可发布的基础库能力。项目采用 Apache-2.0 开源许可证。",
    ),
    (
        "五、技术路线",
        "核心解析器采用确定性单遍扫描，逐字符维护当前位置、当前键、当前值、是否处于引用值，以及引用值中的转义状态。查询器复用轻量扫描思路，将查询文本转换为字段等值、全文包含和字段存在三类条件。聚合器使用数组保存首次出现顺序，保证测试和 CLI 输出稳定。项目结构包括根包核心库、cmd/main 命令行示例、黑盒测试、竞赛材料和 CI 配置。",
    ),
    (
        "六、预期成果",
        "项目预期交付一个可运行的 MoonBit 结构化日志处理基础库，覆盖解析、查询、过滤和聚合场景的测试集，清晰的 README 与项目申报材料，以及可在 GitLink 与 GitHub 上核验的完整开源仓库。后续可继续扩展真实日志文件读取、流式采集、倒排索引、更多查询组合和可视化分析能力。",
    ),
]


def register_font() -> str:
    candidates = [
        Path("C:/Windows/Fonts/msyh.ttc"),
        Path("C:/Windows/Fonts/simhei.ttf"),
        Path("C:/Windows/Fonts/simsun.ttc"),
    ]
    for font in candidates:
        if font.exists():
            pdfmetrics.registerFont(TTFont("MoonLogLensCN", str(font)))
            return "MoonLogLensCN"
    return "Helvetica"


def build_pdf() -> None:
    font = register_font()
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "TitleCN",
        parent=styles["Title"],
        fontName=font,
        fontSize=22,
        leading=30,
        alignment=TA_CENTER,
        spaceAfter=20,
    )
    heading = ParagraphStyle(
        "HeadingCN",
        parent=styles["Heading2"],
        fontName=font,
        fontSize=13,
        leading=18,
        textColor=colors.HexColor("#1f3b73"),
        spaceBefore=10,
        spaceAfter=6,
    )
    body = ParagraphStyle(
        "BodyCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=10.5,
        leading=17,
        firstLineIndent=21,
        spaceAfter=5,
    )
    meta = ParagraphStyle(
        "MetaCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=10.5,
        leading=16,
    )

    doc = SimpleDocTemplate(
        str(PDF_PATH),
        pagesize=A4,
        rightMargin=2 * cm,
        leftMargin=2 * cm,
        topMargin=1.8 * cm,
        bottomMargin=1.8 * cm,
        title=TITLE,
    )
    story = [Paragraph(TITLE, title)]
    table = Table(
        [
            [Paragraph("项目名称", meta), Paragraph(PROJECT_NAME, meta)],
            [Paragraph("参赛方向", meta), Paragraph("MoonBit 国产基础软件开源生态项目", meta)],
            [Paragraph("开源许可证", meta), Paragraph("Apache-2.0", meta)],
            [Paragraph("GitLink 仓库", meta), Paragraph("https://gitlink.org.cn/python123/moonloglens", meta)],
            [Paragraph("GitHub 仓库", meta), Paragraph("https://github.com/px830/moonloglens", meta)],
        ],
        colWidths=[3.2 * cm, 12 * cm],
    )
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), font),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#edf3ff")),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#9aa9c7")),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ]
        )
    )
    story.extend([table, Spacer(1, 0.4 * cm)])
    for section_title, text in SECTIONS:
      story.append(Paragraph(section_title, heading))
      story.append(Paragraph(text, body))
    doc.build(story)


def build_docx() -> None:
    doc = Document()
    doc.styles["Normal"].font.name = "Microsoft YaHei"
    doc.styles["Normal"].font.size = Pt(10.5)
    title = doc.add_heading(TITLE, level=0)
    title.alignment = 1
    table = doc.add_table(rows=5, cols=2)
    table.style = "Table Grid"
    rows = [
        ("项目名称", PROJECT_NAME),
        ("参赛方向", "MoonBit 国产基础软件开源生态项目"),
        ("开源许可证", "Apache-2.0"),
        ("GitLink 仓库", "https://gitlink.org.cn/python123/moonloglens"),
        ("GitHub 仓库", "https://github.com/px830/moonloglens"),
    ]
    for row, (key, value) in zip(table.rows, rows):
        row.cells[0].text = key
        row.cells[1].text = value
    for section_title, text in SECTIONS:
        doc.add_heading(section_title, level=1)
        doc.add_paragraph(text)
    doc.save(DOCX_PATH)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    build_pdf()
    build_docx()
    print(PDF_PATH)
    print(DOCX_PATH)


if __name__ == "__main__":
    main()
