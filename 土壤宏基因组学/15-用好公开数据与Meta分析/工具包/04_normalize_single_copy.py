#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
单拷贝基因标准化：把功能基因的 reads 计数 → "每基因组平均拷贝数"
配套：15.5(标准化)、15.3(再分析)

原理(见15.5)：
  某基因的 per-genome 拷贝数 = 该基因reads数 / 一组通用单拷贝基因(USiCGs)的平均reads数
  这样消除测序深度与基因组大小影响，跨样本/跨研究可比(近似"绝对"概念)。

用法：
  python3 04_normalize_single_copy.py 功能基因计数表.tsv 单拷贝基因计数表.tsv 输出.tsv
输入：
  功能基因计数表.tsv : 行=基因, 列=样本, 值=reads计数(第一列为基因名)
  单拷贝基因计数表.tsv: 行=单拷贝标志基因, 列=样本, 值=reads计数(同样品列名)
说明：实际项目中单拷贝基因计数可用 MUSiCC、或比对到 USiCGs/通用单拷贝基因集得到。
"""
import sys, csv

def read_table(path):
    with open(path, encoding="utf-8") as f:
        rows = [r for r in csv.reader(f, delimiter="\t") if r and not r[0].startswith("#")]
    header = rows[0][1:]                      # 样本名
    data = {r[0]: list(map(float, r[1:])) for r in rows[1:]}
    return header, data

def main():
    if len(sys.argv) < 4:
        print(__doc__); sys.exit(1)
    func_f, scg_f, out_f = sys.argv[1], sys.argv[2], sys.argv[3]

    fh, fdata = read_table(func_f)
    sh, sdata = read_table(scg_f)
    if fh != sh:
        print("⚠️ 两个表的样本列名/顺序不一致，请先对齐！")
        print("  功能表样本:", fh); print("  单拷贝表样本:", sh); sys.exit(1)

    n = len(fh)
    # 每个样本：单拷贝基因的平均 reads 数(作为"一个基因组的当量")
    scg_means = []
    for j in range(n):
        vals = [v[j] for v in sdata.values()]
        m = sum(vals) / len(vals) if vals else 0.0
        scg_means.append(m)
    for j, m in enumerate(scg_means):
        if m <= 0:
            print(f"⚠️ 样本 {fh[j]} 的单拷贝基因平均为0，无法标准化(检查比对)。")

    # 标准化：功能基因reads / 单拷贝平均 = 每基因组拷贝数
    with open(out_f, "w", encoding="utf-8", newline="") as out:
        w = csv.writer(out, delimiter="\t")
        w.writerow(["gene"] + fh)
        for gene, vals in fdata.items():
            norm = [ (vals[j] / scg_means[j]) if scg_means[j] > 0 else "NA"
                     for j in range(n) ]
            w.writerow([gene] + [f"{x:.4f}" if x != "NA" else "NA" for x in norm])

    print(f"✅ 完成：{out_f}")
    print("  单位 = 每基因组平均拷贝数(copies/genome)，可跨样本/跨研究比较。")
    print("  示例解读：nosZ=1.5 表示平均每个微生物基因组约含1.5个nosZ。")
    print("  下一步：查批次效应(PCoA)、组成型差异(ALDEx2)、与元数据关联(见15.3/15.5)。")

if __name__ == "__main__":
    main()
