#!/usr/bin/env Rscript
# =============================================================
# Meta 分析脚本（响应比 lnRR + 随机效应 + 调节因子）
# 配套：15.2 方法、15.5 算例、数据提取表模板.csv
# 用法：
#   1) 按"数据提取表模板.csv"填好你的数据(可删除示例行)
#   2) install.packages("metafor")   # 首次
#   3) Rscript 03_meta_analysis.R  数据提取表模板.csv
# 说明：lnRR=ln(处理/对照) 为组内比值、无量纲，可跨单位合并；
#       但建议把 qPCR绝对量 与 宏基因组相对量 分开跑(见15.5)。
# =============================================================

args <- commandArgs(trailingOnly = TRUE)
infile <- ifelse(length(args) >= 1, args[1], "数据提取表模板.csv")

suppressMessages({
  if (!requireNamespace("metafor", quietly = TRUE))
    stop("请先安装: install.packages('metafor')")
  library(metafor)
})

# --- 读数据：跳过以 # 开头的注释行 ---
dat <- read.csv(infile, comment.char = "#", stringsAsFactors = FALSE)
cat("读入", nrow(dat), "行；指标(gene)：",
    paste(unique(dat$gene), collapse = ", "), "\n")

# --- 只分析某一个指标(按需修改) ---
target_gene <- "nosZ"
d <- subset(dat, gene == target_gene)
cat("\n分析指标：", target_gene, "，共", nrow(d), "个研究/对比\n")

# --- 数据质量检查 ---
need <- c("ctl_mean","ctl_sd","ctl_n","trt_mean","trt_sd","trt_n")
bad  <- d[!complete.cases(d[, need]) | d$ctl_mean <= 0 | d$trt_mean <= 0, ]
if (nrow(bad) > 0) {
  cat("⚠️ 以下行缺均值/SD/n或均值<=0，将被剔除：",
      paste(bad$study_id, collapse = ", "), "\n")
  d <- d[complete.cases(d[, need]) & d$ctl_mean > 0 & d$trt_mean > 0, ]
}

# --- 计算效应量：响应比 lnRR (measure="ROM") ---
es <- escalc(measure = "ROM",
             m1i = trt_mean, sd1i = trt_sd, n1i = trt_n,   # 处理组
             m2i = ctl_mean, sd2i = ctl_sd, n2i = ctl_n,   # 对照组
             data = d)
cat("\n各研究 lnRR (yi) 与方差 (vi)：\n")
print(es[, c("study_id","gene","unit","yi","vi")], row.names = FALSE)

# --- 随机效应模型合并 ---
res <- rma(yi, vi, data = es, method = "REML")
cat("\n===== 合并结果(随机效应) =====\n"); print(res)

# --- 换算成百分比变化，更直观 ---
pct  <- (exp(res$b) - 1) * 100
lopct <- (exp(res$ci.lb) - 1) * 100
hipct <- (exp(res$ci.ub) - 1) * 100
cat(sprintf("\n合并效应：%s 平均变化 = %+.1f%% (95%%CI: %+.1f%% ~ %+.1f%%)\n",
            target_gene, pct, lopct, hipct))
cat(sprintf("异质性 I^2 = %.1f%%  (>75%% 属高异质，建议做调节因子分析)\n", res$I2))
sig <- ifelse(res$pval < 0.05, "显著", "不显著")
cat(sprintf("是否显著(p=%.3g)：%s\n", res$pval, sig))

# --- 调节因子分析(Meta回归)：解释异质性，按需启用 ---
if ("climate" %in% names(es) && length(unique(es$climate)) > 1) {
  cat("\n===== 调节因子：climate(气候) =====\n")
  print(rma(yi, vi, mods = ~ factor(climate), data = es, method = "REML"))
}
if ("crop" %in% names(es) && length(unique(es$crop)) > 1) {
  cat("\n===== 调节因子：crop(作物体系) =====\n")
  print(rma(yi, vi, mods = ~ factor(crop), data = es, method = "REML"))
}
# 连续型调节因子(初始SOC、pH、年限)示例：
# print(rma(yi, vi, mods = ~ initial_SOC, data = es))

# --- 出图：森林图 + 漏斗图(查发表偏倚) ---
pdf("meta_forest.pdf", width = 8, height = max(4, 0.4*nrow(es)+2))
forest(res, slab = es$study_id,
       header = c(paste0(target_gene, " 研究"), "lnRR [95%CI]"))
dev.off()
pdf("meta_funnel.pdf", width = 6, height = 6); funnel(res); dev.off()
cat("\n已输出：meta_forest.pdf, meta_funnel.pdf\n")
# 发表偏倚检验(研究数>=10时较可靠)：
if (nrow(es) >= 10) { cat("\nEgger检验：\n"); print(regtest(res)) }

cat("\n完成。提醒：基因丰度是潜力，要谈过程速率需配通量数据(框架3)。\n")
