#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把土壤宏基因组学学习库的 35 个 markdown 文件合并成单文件合订本。
输出：
  - 土壤宏基因组学-完整合订本.md   （单文件 Markdown，带目录）
  - 土壤宏基因组学-完整合订本.html （自包含 HTML，可点击目录 + 打印成 PDF）
用法：python3 build_book.py
"""
import os
import re
import html as htmllib

import markdown
from markdown.extensions.toc import TocExtension, slugify_unicode

HERE = os.path.dirname(os.path.abspath(__file__))      # .../土壤宏基因组学/合订本
ROOT = os.path.dirname(HERE)                            # .../土壤宏基因组学

# 阅读顺序（每个文件夹的 README 在前）
FILES = [
    "README.md",
    "思路地图-灵魂导览.md",
    "00-零基础启蒙.md",
    "01-第一性原理.md",
    "02-必学模型/README.md",
    "02-必学模型/01-实验与测序模型.md",
    "02-必学模型/02-生信分析模型.md",
    "02-必学模型/03-多样性与统计模型.md",
    "02-必学模型/04-群落构建生态模型.md",
    "02-必学模型/05-功能与生态系统模型.md",
    "03-思维框架.md",
    "04-案例库.md",
    "05-工具与数据库速查.md",
    "06-术语表与延伸阅读.md",
    "07-实操教程/README.md",
    "07-实操教程/01-环境与软件安装.md",
    "07-实操教程/02-质控与读长分析.md",
    "07-实操教程/03-组装分箱与MAG.md",
    "07-实操教程/04-统计与可视化.md",
    "07-实操教程/05-常见报错与排查.md",
    "08-难点图解/README.md",
    "08-难点图解/01-组成型数据与CLR.md",
    "08-难点图解/02-组装与分箱.md",
    "08-难点图解/03-群落构建βNTI与RCbray.md",
    "08-难点图解/04-多样性与排序.md",
    "08-难点图解/05-relicDNA与休眠-测到的DNA不等于活菌.md",
    "09-速记卡片与速查图.md",
    "10-前沿模型与方法/README.md",
    "10-前沿模型与方法/01-AI与基础模型.md",
    "10-前沿模型与方法/02-Hi-C邻近连接与病毒组.md",
    "10-前沿模型与方法/03-从基因潜力到活性与互作.md",
    "10-前沿模型与方法/04-培养组学复兴.md",
    "10-前沿模型与方法/05-菌株水平与微多样性.md",
    "10-前沿模型与方法/06-AI时代的可能性与冷静判断.md",
    "11-多组学整合与他山之石/README.md",
    "11-多组学整合与他山之石/01-组学阶梯与多组学整合.md",
    "11-多组学整合与他山之石/02-他山之石.md",
    "11-多组学整合与他山之石/03-各类组学详解.md",
    "11-多组学整合与他山之石/04-从组学领域借方法.md",
    "11-多组学整合与他山之石/05-他山之石进阶.md",
    "11-多组学整合与他山之石/06-代谢组学深入-土壤视角.md",
    "11-多组学整合与他山之石/07-被忽略的成员-真核古菌原生生物.md",
    "12-自测与练习/README.md",
    "12-自测与练习/01-基础概念自测.md",
    "12-自测与练习/02-分析与统计自测.md",
    "12-自测与练习/03-生态与功能自测.md",
    "12-自测与练习/04-纠错与案例分析.md",
    "12-自测与练习/05-论文判读实战.md",
    "12-自测与练习/06-论文判读实战集-土壤养分.md",
    "12-自测与练习/07-论文判读实战集-固碳.md",
    "12-自测与练习/08-论文判读实战集-N2O与温室气体.md",
    "12-自测与练习/09-论文判读实战集-根际与植物微生物.md",
    "13-资源导航与优质教程.md",
    "14-专题-养分循环与施肥/README.md",
    "14-专题-养分循环与施肥/01-养分循环的微生物机制与功能基因.md",
    "14-专题-养分循环与施肥/02-化肥与有机物添加的微生物效应.md",
    "14-专题-养分循环与施肥/03-有机碳固存与激发效应.md",
    "14-专题-养分循环与施肥/04-研究设计与分析方案.md",
    "14-专题-养分循环与施肥/05-化学计量比视角-固碳与增产.md",
    "14-专题-养分循环与施肥/06-全球视角与跨体系综合.md",
    "14-专题-养分循环与施肥/07-固碳前沿争议.md",
    "14-专题-养分循环与施肥/08-课题推演沙盘.md",
    "15-用好公开数据与Meta分析/README.md",
    "15-用好公开数据与Meta分析/01-公开数据从哪来怎么下.md",
    "15-用好公开数据与Meta分析/02-Meta分析方法.md",
    "15-用好公开数据与Meta分析/03-公开宏基因组数据再分析.md",
    "15-用好公开数据与Meta分析/04-进阶数据再利用.md",
    "15-用好公开数据与Meta分析/05-宏基因组指标的提取与Meta实例.md",
    "15-用好公开数据与Meta分析/06-候选公开数据集线索.md",
    "15-用好公开数据与Meta分析/07-实战工具包与各数据集用法.md",
]

# 把指向本地 .md 的相对链接（单文件里会失效）替换成纯文字，保留外部 http 链接
LOCAL_MD_LINK = re.compile(r"\[([^\]]+)\]\(\.{1,2}/[^)]*\.md[^)]*\)")

def clean(text):
    return LOCAL_MD_LINK.sub(r"**\1**", text)

def first_h1(text):
    for line in text.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return "(无标题)"

# ---------- 1) 生成合订本 Markdown ----------
md_chunks = []
md_chunks.append("# 🦠 土壤宏基因组学 · 完整合订本\n")
md_chunks.append("> 本文件由学习库 35 个文档自动合并生成，便于离线通读 / 全文搜索 / 打印。\n>\n"
                 "> 单文件内文档间跳转链接已转为普通文字，请用下面目录或搜索定位。原始分文件见仓库 `土壤宏基因组学/`。\n")
md_chunks.append("\n## 📑 总目录\n")
for i, f in enumerate(FILES, 1):
    text = open(os.path.join(ROOT, f), encoding="utf-8").read()
    md_chunks.append(f"{i}. {first_h1(text)}　`{f}`")
toc_md = "\n".join(md_chunks) + "\n\n---\n"

body_md = []
for f in FILES:
    text = clean(open(os.path.join(ROOT, f), encoding="utf-8").read())
    body_md.append(text.strip())
combined_md = toc_md + "\n\n---\n\n".join(body_md) + "\n"

out_md = os.path.join(HERE, "土壤宏基因组学-完整合订本.md")
open(out_md, "w", encoding="utf-8").write(combined_md)
print("已生成:", out_md, f"({len(combined_md)} 字符)")

# ---------- 2) 生成自包含 HTML ----------
H2 = re.compile(r'<h2 id="([^"]+)">(.*?)</h2>', re.S)
TAG = re.compile(r"<[^>]+>")

chapters = []   # (idx, title, chap_id, html, [(h2id,h2text)...])
for i, f in enumerate(FILES, 1):
    raw = clean(open(os.path.join(ROOT, f), encoding="utf-8").read())
    md = markdown.Markdown(extensions=[
        "extra", "sane_lists",
        TocExtension(slugify=slugify_unicode, permalink=False),
    ])
    body = md.convert(raw)
    chap_id = f"chap-{i}"
    title = first_h1(raw)
    subs = [(hid, TAG.sub("", htext).strip()) for hid, htext in H2.findall(body)]
    chapters.append((i, title, chap_id, body, subs))

# 顶部可点击目录（章 + 节）
toc_items = []
for i, title, chap_id, body, subs in chapters:
    toc_items.append(f'<li><a href="#{chap_id}"><b>{htmllib.escape(title)}</b></a>')
    if subs:
        toc_items.append("<ul>")
        for hid, htext in subs:
            toc_items.append(f'<li><a href="#{hid}">{htmllib.escape(htext)}</a></li>')
        toc_items.append("</ul>")
    toc_items.append("</li>")
toc_html = "<ul class='toc'>" + "\n".join(toc_items) + "</ul>"

sections = []
for i, title, chap_id, body, subs in chapters:
    sections.append(f'<section class="chapter" id="{chap_id}">\n{body}\n</section>')

CSS = """
:root{ --ink:#1a1a1a; --muted:#666; --line:#e2e2e2; --accent:#2c7a3f; --bg:#fff; --code-bg:#f6f8fa; }
*{ box-sizing:border-box; }
body{ font-family:"PingFang SC","Microsoft YaHei","Hiragino Sans GB","Source Han Sans SC","Noto Sans CJK SC","WenQuanYi Zen Hei",sans-serif;
  color:var(--ink); background:var(--bg); line-height:1.75; margin:0;
  font-size:16px; -webkit-font-smoothing:antialiased; }
.wrap{ max-width:860px; margin:0 auto; padding:40px 28px 80px; }
h1,h2,h3,h4{ line-height:1.35; font-weight:700; }
h1{ font-size:1.9em; border-bottom:3px solid var(--accent); padding-bottom:.3em; margin-top:0; }
h2{ font-size:1.45em; border-bottom:1px solid var(--line); padding-bottom:.25em; margin-top:1.6em; }
h3{ font-size:1.18em; margin-top:1.3em; }
h4{ font-size:1.03em; color:#333; }
a{ color:var(--accent); text-decoration:none; }
a:hover{ text-decoration:underline; }
p,li{ font-size:1em; }
blockquote{ margin:1em 0; padding:.5em 1em; border-left:4px solid var(--accent);
  background:#f3f8f4; color:#2f2f2f; border-radius:0 6px 6px 0; }
code{ font-family:"WenQuanYi Zen Hei Mono","Sarasa Mono SC",ui-monospace,Menlo,Consolas,monospace;
  background:var(--code-bg); padding:.12em .4em; border-radius:4px; font-size:.9em; }
pre{ background:var(--code-bg); border:1px solid var(--line); border-radius:8px;
  padding:14px 16px; overflow:auto; line-height:1.5; }
pre code{ background:none; padding:0; font-size:.86em; white-space:pre; }
table{ border-collapse:collapse; width:100%; margin:1em 0; font-size:.94em; }
th,td{ border:1px solid var(--line); padding:7px 10px; text-align:left; vertical-align:top; }
th{ background:#f0f5f1; }
tr:nth-child(even) td{ background:#fafafa; }
hr{ border:none; border-top:1px solid var(--line); margin:2em 0; }
.cover{ text-align:center; padding:60px 0 30px; border-bottom:3px solid var(--accent); margin-bottom:24px; }
.cover h1{ border:none; font-size:2.4em; }
.cover .sub{ color:var(--muted); font-size:1.05em; margin-top:8px; }
.toc{ list-style:none; padding-left:0; }
.toc>li{ margin:.35em 0; }
.toc ul{ list-style:none; padding-left:1.4em; margin:.2em 0; }
.toc ul li{ color:var(--muted); font-size:.92em; margin:.1em 0; }
.tocbox{ background:#f8faf8; border:1px solid var(--line); border-radius:10px; padding:18px 24px; margin-bottom:10px; }
.chapter{ padding-top:10px; }
@media print{
  body{ font-size:11.5pt; }
  .wrap{ max-width:100%; padding:0; }
  .chapter{ page-break-before:always; }
  .cover{ page-break-after:always; }
  .tocbox{ page-break-after:always; }
  pre,table,blockquote,img{ page-break-inside:avoid; }
  a{ color:var(--ink); }
}
"""

html_doc = f"""<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>土壤宏基因组学 · 完整合订本</title>
<style>{CSS}</style></head>
<body><div class="wrap">
<div class="cover">
  <h1>🦠 土壤宏基因组学</h1>
  <div class="sub">小白系统学习库 · 完整合订本</div>
  <div class="sub">第一性原理 · 20 个必学模型 · 7 个思维框架 · 10 个案例 · 实操教程 · 难点图解 · 前沿与多组学</div>
  <div class="sub" style="margin-top:18px;font-size:.9em;">共 {len(FILES)} 章 · 自动合并生成 · 用浏览器「打印 → 另存为 PDF」即得电子书</div>
</div>
<div class="tocbox"><h2 style="margin-top:0;border:none;">📑 目录</h2>
{toc_html}
</div>
{''.join(sections)}
</div></body></html>"""

out_html = os.path.join(HERE, "土壤宏基因组学-完整合订本.html")
open(out_html, "w", encoding="utf-8").write(html_doc)
print("已生成:", out_html, f"({len(html_doc)} 字符)")
print("章节数:", len(chapters))
