# 🧰 公开数据再利用 · 实战工具包

> 把 [模块15](../README.md) 的方法落成**可直接运行的脚本和模板**。无论你最终用哪个候选数据集（[15.6](../06-候选公开数据集线索.md)），都能套用。
>
> ⚠️ 这些是**教学骨架**：命令/参数以各工具官方文档为准；用前先按 [15.6](../06-候选公开数据集线索.md) **核实数据编号与测序类型**，并准备好**元数据**。

---

## 文件清单与用途

| 文件 | 干什么 | 配套章节 |
| --- | --- | --- |
| `数据提取表模板.csv` | 做 Meta 分析时，逐篇论文提取数据填这张表（含示例行） | 15.2 / 15.5 |
| `01_download_sra.sh` | 批量下载 SRA/ENA 原始 reads | 15.1 / 15.6 |
| `02_reanalysis_pipeline.sh` | 多研究**统一再分析**(质控→物种→功能基因) 骨架 | 15.3 / 07 |
| `04_normalize_single_copy.py` | 功能基因 reads → **每基因组拷贝数**(跨研究可比) | 15.5 / 15.3 |
| `05_batch_check.R` | **批次效应自查**(PCoA+PERMANOVA) + 组成型差异提示 | 15.3 / 模型12·14 |
| `03_meta_analysis.R` | **Meta 分析**(lnRR+随机效应+调节因子+森林/漏斗图) | 15.2 / 15.5 |

> 编号 01→05 大致是"数据级再分析"的顺序；`03_meta_analysis.R` 是"结果级 Meta"的独立路径（只需填好 `数据提取表模板.csv`）。

---

## 两条典型用法

### A. 只做 Meta 分析（最省事，不碰原始序列）
```bash
# 1) 按模板填好你的数据(删掉示例行)
cp 数据提取表模板.csv my_data.csv      # 编辑 my_data.csv
# 2) 跑 Meta
Rscript 03_meta_analysis.R my_data.csv
# → 输出合并效应(±%)、I²、森林图 meta_forest.pdf、漏斗图 meta_funnel.pdf
```

### B. 下原始数据统一再分析（要算力）
```bash
# 1) 核实编号后，把 Run 号填入 accessions.txt，下载
bash 01_download_sra.sh accessions.txt ./raw
# 2) 把样本前缀填入 samples.txt，统一重算(改脚本顶部的数据库路径)
bash 02_reanalysis_pipeline.sh ./raw ./out samples.txt
# 3) 合并成"基因×样本"计数表后，单拷贝标准化
python3 04_normalize_single_copy.py func_counts.tsv scg_counts.tsv func_norm.tsv
# 4) ★必做★ 查批次效应 + 处理效应(需 元数据.tsv 含 study/treatment 列)
Rscript 05_batch_check.R func_norm.tsv 元数据.tsv
```

---

## 环境准备（一次）
```bash
# 下载与再分析
mamba create -n meta-reuse -c bioconda -c conda-forge \
  sra-tools pigz fastp bowtie2 samtools kraken2 bracken diamond seqkit
# 统计(R)
mamba create -n meta-r -c conda-forge -c bioconda \
  r-base r-metafor r-vegan bioconductor-aldex2
```

---

## ⚠️ 贯穿始终的纪律
1. **核实**编号、测序类型(鸟枪/扩增子)、元数据(15.1/15.6)。
2. **统一**流程/版本/数据库；**查批次**(05 脚本)，按研究聚类=批次严重(15.3)。
3. **正确单位**：Meta 用 lnRR(跨单位)、再分析用单拷贝标准化；组成型用 CLR(模型14)。
4. **潜力≠速率**：基因结论别越界到过程速率(框架3)。
5. **引用数据来源**与原始论文(学术伦理)。

⬅️ 返回 [模块15](../README.md) ｜ 数据线索 [15.6](../06-候选公开数据集线索.md) ｜ 算例 [15.5](../05-宏基因组指标的提取与Meta实例.md)
