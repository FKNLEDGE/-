# 07.3 · 组装、分箱与 MAG（路线乙：重建基因组）

> 这一篇你会：**把碎片拼成长片段(contig) → 把 contig 按物种归堆(分箱) → 得到一个个基因组(MAG) → 给 MAG 质控、分类、注释。**
> 这是宏基因组的"硬核"部分，也是最有成就感的部分——你将亲手"复活"一个个从未被培养过的微生物的基因组。

对应模型：组装=模型 6；分箱=模型 7；MAG 质控=模型 8；分类=模型 9；注释=模型 10。

> 💡 前提：先做完第 02 篇的质控、去宿主，拿到干净 read。

---

## 第 1 步 · 组装：把碎片拼成长片段（MEGAHIT）

**做什么**：把几千万条 read，按重叠关系拼成更长的 contig（模型 6 的 de Bruijn 图）。

```bash
conda activate assembly

megahit \
  -1 clean/sample_1.fq.gz \
  -2 clean/sample_2.fq.gz \
  -o assembly/sample_megahit \   # 输出目录
  -t 16 \                        # 线程
  --min-contig-len 1000          # 只保留 ≥1000bp 的 contig（短的没分析价值）
# 结果在 assembly/sample_megahit/final.contigs.fa
```

**为什么用 MEGAHIT**：省内存、快，**土壤这种超大数据首选**。追求更高质量、内存够 → 可用 `metaspades.py`。

**检查组装质量**：
```bash
seqkit stats assembly/sample_megahit/final.contigs.fa
# 关注：contig 数量、总长度、N50（越大通常越好，模型6）
```

> ⚠️ **土壤极难组装**（原理 6）：大量 read 拼不进去、contig 又短又碎、N50 偏低，都很正常，不是你做错了。

> 进阶：把**多个样本一起组装（co-assembly）**或分别组装后合并，能帮后面分箱（提供"丰度共变"信号）。

---

## 第 2 步 · 预测基因（Prodigal）

**做什么**：在 contig 上找出一个个基因（开放阅读框 ORF），翻译成蛋白序列，供后面功能注释。

```bash
prodigal \
  -i assembly/sample_megahit/final.contigs.fa \
  -a function/sample.proteins.faa \   # 蛋白序列（功能注释要用）
  -d function/sample.genes.fna \      # 核酸序列
  -p meta                             # 宏基因组模式（关键！多物种混合）
```

---

## 第 3 步 · 算覆盖度：为分箱准备"丰度信号"

**为什么**：分箱要靠"同一基因组的 contig 在各样本里丰度同涨同落"（模型 7）。所以先把 read **比回 contig**，算每条 contig 在每个样本的覆盖深度。

```bash
# 1) 给 contig 建索引
bowtie2-build assembly/sample_megahit/final.contigs.fa assembly/sample_index

# 2) 把每个样本的 read 比回去，得到排序好的 bam
bowtie2 -x assembly/sample_index \
  -1 clean/sample_1.fq.gz -2 clean/sample_2.fq.gz -p 16 | \
  samtools sort -@ 8 -o assembly/sample.bam
samtools index assembly/sample.bam

# 3) 汇总成深度表（MetaBAT2 自带工具）
jgi_summarize_bam_contig_depths \
  --outputDepth assembly/sample.depth.txt \
  assembly/sample.bam
```

> 多样本时，把所有样本的 bam 都列在最后，得到"多样本深度表"，分箱效果会**好很多**。

---

## 第 4 步 · 分箱：把 contig 按物种归堆（MetaBAT2）

```bash
metabat2 \
  -i assembly/sample_megahit/final.contigs.fa \   # contig
  -a assembly/sample.depth.txt \                  # 深度表
  -o bins/sample_bin \                            # 输出前缀：会生成 sample_bin.1.fa, .2.fa ...
  -m 1500 \                                       # 参与分箱的最小 contig 长度
  -t 16
# 每个 bins/sample_bin.N.fa 就是一个候选基因组(MAG)
```

> 🔑 **进阶但强烈推荐**：用**多个分箱工具**（MetaBAT2 + MaxBin2 + CONCOCT/SemiBin2）各跑一遍，再用 **DAS_Tool** 或 **metaWRAP 的 bin_refinement** 整合精炼——**土壤分箱质量低，精炼几乎是必需的**（模型 7 的坑）。多样本还要用 **dRep** 去冗余。

---

## 第 5 步 · 给 MAG 质控（CheckM2）

**做什么**：评估每个 MAG 的**完整度**和**污染度**（模型 8、MIMAG 标准）。

```bash
conda activate annot

checkm2 predict \
  --threads 16 \
  --input bins/ \                  # 放所有 .fa 的目录
  --extension fa \
  --output-directory results/checkm2
# 看 results/checkm2/quality_report.tsv：每个 MAG 的 Completeness 和 Contamination
```

**筛选标准**（MIMAG）：
- **高质量**：完整度 >90% 且 污染度 <5%
- **中等质量**：完整度 ≥50% 且 污染度 <10%
- 一个常用综合门槛：`完整度 − 5×污染度 > 50`

```bash
# 示例：用 awk 挑出“完整度>50 且 污染度<10”的 MAG 名单
awk -F'\t' 'NR>1 && $2>50 && $3<10 {print $1}' results/checkm2/quality_report.tsv
```

> ⚠️ **别拿中低质量 MAG 当完整基因组解读它的通路**——缺的那段可能只是没拼到（模型 8 的坑）。

---

## 第 6 步 · 给 MAG 分类（GTDB-Tk）

**做什么**：用标准化的 GTDB 数据库，告诉你每个 MAG 是"门→纲→…→种"的什么（模型 9）。

```bash
gtdbtk classify_wf \
  --genome_dir bins/ \
  --extension fa \
  --out_dir results/gtdbtk \
  --cpus 16 \
  --skip_ani_screen        # 新版本常需此参数或提供 --mash_db；以官方文档为准
# 结果 results/gtdbtk/*.summary.tsv 里有每个 MAG 的分类
```

---

## 第 7 步 · 给 MAG 做功能注释（eggNOG-mapper / DRAM）

**做什么**：给 MAG 里的基因贴功能标签（KEGG/COG/CAZy 等，模型 10）。

```bash
# 先对某个 MAG 预测蛋白（或用第2步的整体蛋白按 bin 拆分）
prodigal -i bins/sample_bin.1.fa -a bins/sample_bin.1.faa -p single

# eggNOG-mapper 注释
emapper.py \
  -i bins/sample_bin.1.faa \
  -o results/sample_bin.1 \
  --output_dir results/eggnog \
  --data_dir ~/db/eggnog \
  --cpu 16
# 结果 *.emapper.annotations 里有每个基因的 KEGG KO、COG、CAZy 等注释
```

> 想系统看 MAG 的**代谢全貌** → 用 **DRAM**（自动整理出碳氮硫等代谢通路表）。
> 想看**碳氮磷硫循环基因**（模型 19）→ 把蛋白比对到 **CAZy / NCyc / PCyc / SCyc** 专用库。
> 想挖**新药/抗生素生物合成基因簇 BGC**（案例 9）→ 用 **antiSMASH**。

---

## 🧭 这一篇的产物，如何连到结论

```
clean reads
   └─ megahit ─► contigs ─┬─ prodigal ─► 蛋白 ─► eggnog/DRAM ─► 功能表
                          └─ 覆盖度 ─► metabat2 ─► MAG ─┬─ checkm2 ─► 质量表
                                                        ├─ gtdbtk ─► 分类表
                                                        └─ eggnog ─► 各MAG功能表
   全部表 ─► 进 R（第 04 篇）做统计、比较、画图 ─► 结论
```

## ✅ 本篇完成检查

- [ ] 有了 `final.contigs.fa`，看过 N50
- [ ] 分箱得到一批 `bins/*.fa`
- [ ] CheckM2 质量表出来了，会挑高/中质量 MAG
- [ ] GTDB-Tk 给出了分类
- [ ] （可选）做了功能注释

➡️ 下一篇：[`04-统计与可视化.md`](./04-统计与可视化.md)——把这些表变成图。
