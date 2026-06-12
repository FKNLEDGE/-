#!/usr/bin/env bash
# =============================================================
# 批量下载公开测序数据 (SRA/ENA)
# 配套：15.1 公开数据从哪来怎么下、15.6 候选数据集线索
# 依赖：SRA Toolkit (prefetch, fasterq-dump) 或 wget
#   安装：mamba create -n download -c bioconda sra-tools pigz
# 用法：
#   1) 先去官网核实编号与测序类型！(见 15.6 的纪律)
#      https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNAxxxxxx
#   2) 把要下的 Run 编号(SRR/ERR)填进 accessions.txt(每行一个)
#   3) bash 01_download_sra.sh accessions.txt  ./raw
# 提示：用 tmux/nohup 后台跑，数据大、耗时长(见 07.5)。
# =============================================================
set -euo pipefail

ACC_LIST="${1:-accessions.txt}"
OUTDIR="${2:-./raw}"
THREADS="${THREADS:-8}"

mkdir -p "$OUTDIR"
[ -f "$ACC_LIST" ] || { echo "找不到编号清单 $ACC_LIST(每行一个 SRR/ERR)"; exit 1; }

echo "=== 开始下载，输出到 $OUTDIR ==="
while read -r acc; do
  acc=$(echo "$acc" | tr -d '[:space:]')
  [ -z "$acc" ] && continue
  case "$acc" in \#*) continue;; esac          # 跳过注释行
  if ls "$OUTDIR/${acc}"*_1.fastq.gz >/dev/null 2>&1; then
    echo "[$acc] 已存在，跳过"; continue
  fi
  echo "---- [$acc] prefetch ----"
  prefetch --max-size 100G -O "$OUTDIR" "$acc"
  echo "---- [$acc] fasterq-dump → fastq ----"
  fasterq-dump --split-files --threads "$THREADS" -O "$OUTDIR" "$OUTDIR/$acc/$acc.sra" \
    || fasterq-dump --split-files --threads "$THREADS" -O "$OUTDIR" "$acc"
  echo "---- [$acc] 压缩 ----"
  pigz -p "$THREADS" "$OUTDIR/${acc}"_*.fastq 2>/dev/null || gzip "$OUTDIR/${acc}"_*.fastq 2>/dev/null || true
  rm -rf "$OUTDIR/$acc"                          # 删中间 .sra 省空间
done < "$ACC_LIST"

echo "=== 全部下载完成 ==="
echo "提示：务必同时整理好每个样本的【元数据】(处理/对照/pH/SOC…)，否则无法分析(见15.1)"

# --- 备选：ENA 直链下载(常更快，按需手动用) ---
# 在 https://www.ebi.ac.uk/ena/browser/view/PRJEBxxxxxx 获取 fastq_ftp 链接后:
# wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR.../SRRxxxxxxx_1.fastq.gz
