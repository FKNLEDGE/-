#!/usr/bin/env Rscript
# =============================================================
# 批次效应自查 + 组成型差异分析(再分析必做)
# 配套：15.3(控批次)、模型12(PCoA/PERMANOVA)、模型14(组成型)
# 核心问题：合并多研究数据后，样本是按【处理】聚 还是按【研究/批次】聚?
#   若按研究聚成块 = 批次效应严重，必须处理(见15.3)。
# 用法：
#   install.packages(c("vegan"))  # ALDEx2 来自 Bioconductor
#   Rscript 05_batch_check.R  特征表.tsv  元数据.tsv
# 输入：
#   特征表.tsv : 行=基因/物种, 列=样本(第一列为名)
#   元数据.tsv : 行=样本(第一列样本名), 含列 study(研究/批次) 与 treatment(处理)
# =============================================================
args <- commandArgs(trailingOnly = TRUE)
feat_f <- ifelse(length(args)>=1, args[1], "特征表.tsv")
meta_f <- ifelse(length(args)>=2, args[2], "元数据.tsv")

suppressMessages(library(vegan))

feat <- read.delim(feat_f, row.names = 1, check.names = FALSE, comment.char = "#")
meta <- read.delim(meta_f, row.names = 1, check.names = FALSE)
otu  <- t(as.matrix(feat))                       # 行=样本, 列=特征
otu  <- otu[rownames(meta), , drop = FALSE]      # 对齐样本顺序
cat("样本数:", nrow(otu), " 特征数:", ncol(otu), "\n")
stopifnot(all(c("study","treatment") %in% colnames(meta)))

# --- 距离 + PCoA ---
d  <- vegdist(otu, method = "bray")
pc <- cmdscale(d, k = 2, eig = TRUE)
pts <- data.frame(pc$points, meta); colnames(pts)[1:2] <- c("PCoA1","PCoA2")

# --- 关键检验：是"研究"解释更多，还是"处理"? ---
cat("\n===== PERMANOVA：谁解释群落差异更多? =====\n")
a_study <- adonis2(d ~ study,     data = meta, permutations = 999)
a_trt   <- adonis2(d ~ treatment, data = meta, permutations = 999)
cat("\n[study/批次]  R2 =", round(a_study$R2[1],3), " p =", a_study$`Pr(>F)`[1], "\n")
cat("[treatment/处理] R2 =", round(a_trt$R2[1],3), " p =", a_trt$`Pr(>F)`[1], "\n")
if (a_study$R2[1] > a_trt$R2[1]) {
  cat("\n⚠️ 警告：'研究/批次'解释的差异 > '处理' → 批次效应严重!\n",
      "  对策(见15.3)：把 study 作协变量 adonis2(d~study+treatment)；或批次校正;\n",
      "  或仅在'每个研究内部都含处理与对照'的数据上做研究内对比。\n")
} else {
  cat("\n✓ '处理'解释 >= '批次'，相对可控(仍建议把 study 作协变量)。\n")
}
cat("\n控批次后处理效应：adonis2(d ~ study + treatment)\n")
print(adonis2(d ~ study + treatment, data = meta, permutations = 999, by = "margin"))

# --- 出图：分别按 处理 和 研究 着色，肉眼判断聚类模式 ---
pdf("batch_check_PCoA.pdf", width = 11, height = 5)
op <- par(mfrow = c(1,2))
cols_t <- as.integer(factor(pts$treatment)); cols_s <- as.integer(factor(pts$study))
plot(pts$PCoA1, pts$PCoA2, col = cols_t, pch = 19, main = "按处理 treatment 着色",
     xlab = "PCoA1", ylab = "PCoA2"); legend("topright", legend = levels(factor(pts$treatment)),
     col = seq_along(levels(factor(pts$treatment))), pch = 19, cex = .8)
plot(pts$PCoA1, pts$PCoA2, col = cols_s, pch = 17, main = "按研究 study 着色(若分块=批次效应)",
     xlab = "PCoA1", ylab = "PCoA2"); legend("topright", legend = levels(factor(pts$study)),
     col = seq_along(levels(factor(pts$study))), pch = 17, cex = .8)
par(op); dev.off()
cat("\n已输出 batch_check_PCoA.pdf：右图若按'研究'清晰分块，即批次效应。\n")

# --- 组成型差异分析提示(ALDEx2, Bioconductor) ---
cat("\n找差异特征请用组成型方法(模型14)，示例：\n",
    "  # BiocManager::install('ALDEx2')\n",
    "  library(ALDEx2); x <- aldex(feat, meta$treatment, test='t', effect=TRUE)\n",
    "  sig <- x[x$wi.eBH < 0.05, ]   # 校正后显著\n")
