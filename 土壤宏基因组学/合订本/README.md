# 📖 合订本（电子书）

把学习库的 **66 个文档**自动合并成单文件，方便**离线通读 / 全文搜索 / 打印**。

## 三种格式，按需取用

| 文件 | 用途 | 怎么用 |
| --- | --- | --- |
| **土壤宏基因组学-完整合订本.pdf** | 直接读/打印的电子书（310 页） | 任意 PDF 阅读器打开即可 |
| **土壤宏基因组学-完整合订本.html** | 带可点击目录的网页书 | 浏览器打开；想要最佳排版的 PDF，按 `Ctrl/Cmd+P` →「另存为 PDF」 |
| **土壤宏基因组学-完整合订本.md** | 纯文本合订本 | 任意 Markdown 阅读器 / 直接在 GitHub 上读 |

> 💡 **想要最漂亮的 PDF**：用浏览器打开 HTML 再「打印 → 另存为 PDF」。你自己电脑上的中文字体（苹方/微软雅黑）和 emoji 通常比服务器生成的更好看。
> ⚠️ 仓库里这份自动生成的 PDF 正文中文完整，但少数 emoji 图标（🦠📑 等）可能不显示——纯属装饰，不影响内容。

## 重新生成

内容更新后，重新生成合订本：

```bash
cd 土壤宏基因组学/合订本
pip3 install markdown          # 首次需要
python3 build_book.py          # 生成 .md 和 .html
# 可选：生成 PDF（需要 weasyprint）
pip3 install weasyprint
python3 -c "from weasyprint import HTML; HTML('土壤宏基因组学-完整合订本.html').write_pdf('土壤宏基因组学-完整合订本.pdf')"
```

阅读顺序、章节结构都在 `build_book.py` 的 `FILES` 列表里维护。
