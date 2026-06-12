#!/usr/bin/env bash
# =============================================================
# 公开宏基因组"统一再分析"流程骨架(读长路线，省算力)
# 配套：15.3 再分析、07 实操、14.1 功能基因
# 目标：把多研究的原始 reads 用【同一套流程】处理，得到可比的功能基因表
# 依赖(conda)：fastp bowtie2 samtools kraken2 bracken diamond seqkit
# 用法：bash 02_reanalysis_pipeline.sh  ./raw  ./out  samples.txt
#   samples.txt 每行一个样本前缀(对应 raw/<前缀>_1.fastq.gz / _2.fastq.gz)
# 关键纪律：所有样本必须同流程、同版本、同数据库；之后查批次效应(见末尾)。
# =============================================================
set -euo pipefail

RAW="${1:-./raw}"; OUT="${2:-./out}"; SAMPLES="${3:-samples.txt}"
THREADS="${THREADS:-16}"
HOST_IDX="${HOST_IDX:-}"                 # 如需去宿主，设为宿主 bowtie2 索引前缀
KRAKEN_DB="${KRAKEN_DB:-$HOME/db/kraken2_db}"
FUNC_DB="${FUNC_DB:-$HOME/db/NCyc/NCyc.dmnd}"   # 功能库(diamond格式),如 NCyc/CAZy
mkdir -p "$OUT"/{clean,tax,func}

while read -r s; do
  s=$(echo "$s" | tr -d '[:space:]'); [ -z "$s" ] && continue
  case "$s" in \#*) continue;; esac
  echo "==================== 样本 $s ===================="

  # ① 质控(模型4)
  fastp -i "$RAW/${s}_1.fastq.gz" -I "$RAW/${s}_2.fastq.gz" \
        -o "$OUT/clean/${s}_1.fq.gz" -O "$OUT/clean/${s}_2.fq.gz" \
        -q 20 -l 50 --detect_adapter_for_pe -w "$THREADS" \
        -j "$OUT/clean/${s}.json" -h "$OUT/clean/${s}.html"

  # ② 去宿主(可选；土壤常需去植物DNA)
  R1="$OUT/clean/${s}_1.fq.gz"; R2="$OUT/clean/${s}_2.fq.gz"
  if [ -n "$HOST_IDX" ]; then
    bowtie2 -x "$HOST_IDX" -1 "$R1" -2 "$R2" -p "$THREADS" \
      --un-conc-gz "$OUT/clean/${s}_nohost_%.fq.gz" -S /dev/null
    R1="$OUT/clean/${s}_nohost_1.fq.gz"; R2="$OUT/clean/${s}_nohost_2.fq.gz"
  fi

  # ③ 物种谱(模型9) Kraken2 + Bracken
  kraken2 --db "$KRAKEN_DB" --paired "$R1" "$R2" --threads "$THREADS" \
          --report "$OUT/tax/${s}.kreport" --output /dev/null
  bracken -d "$KRAKEN_DB" -i "$OUT/tax/${s}.kreport" \
          -o "$OUT/tax/${s}.bracken" -r 150 -l S || true

  # ④ 功能基因定量(模型10/19)：reads→蛋白比对到功能库(如 NCyc/PCyc/SCyc/CAZy)
  #    这里给 diamond 比对骨架；真实项目可先 megahit 组装再比对(见07.3)
  seqkit fq2fa "$R1" 2>/dev/null | \
    diamond blastx --db "$FUNC_DB" --query - --threads "$THREADS" \
      --outfmt 6 qseqid sseqid pident length evalue bitscore \
      --evalue 1e-5 --max-target-seqs 1 --out "$OUT/func/${s}.func.tsv" || \
    echo "  (功能比对跳过：请确认 FUNC_DB=$FUNC_DB 存在)"
done < "$SAMPLES"

echo ""
echo "=== 流程完成 ==="
echo "下一步(关键)："
echo " 1) 合并各样本功能/物种表为 矩阵(行=基因/物种, 列=样本)"
echo " 2) 标准化：功能基因优先【单拷贝基因标准化】(用 04_normalize_single_copy.py) → 每基因组拷贝数(15.5)"
echo " 3) 查批次效应：做 PCoA, 看样本是按【处理】聚 还是按【研究】聚;"
echo "    若按研究聚成块=批次严重，需把'研究'作协变量或批次校正(15.3,框架6)"
echo " 4) 组成型差异用 ALDEx2/CLR(模型14); 再与元数据(pH/SOC/产量)关联"
