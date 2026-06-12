# 12 · GitHub Actions 自动化入门（让 GitHub 替你干活）

> 你 PR 页面上见过的那个绿色 ✅ / 红色 ❌，就是 **GitHub Actions** 跑出来的。这一章用大白话 + 一个**能直接抄、立刻看到效果**的例子，带你跑通人生第一个自动化流程。
> 不需要你会编程，跟着复制粘贴就能看到"每次提交，GitHub 自动帮我做事"。

---

## 一、GitHub Actions 是什么？解决什么问题？

设想这些重复劳动：

- 每次改完代码，都要**手动跑一遍测试**确认没改坏。
- 每次更新博客，都要**手动把网站重新部署**一遍。
- 每次有人提 PR，都想**自动检查**代码格式对不对。

> 🔑 一句话：**GitHub Actions = 你设定好"当发生某件事时，自动执行某些步骤"，之后 GitHub 在它的服务器上替你自动跑，不用你动手。**

这套"自动流水线"有个统称叫 **CI/CD**（持续集成 / 持续部署）。对小白，先理解成"**触发条件 → 自动执行一串命令**"就够了。

### 一个生活类比

就像你给手机设的**自动化规则**："**当**我到家（触发），**就**自动开灯、连 WiFi（执行步骤）"。GitHub Actions 就是给你仓库设规则："**当**有人 push（触发），**就**自动跑测试、发通知（执行步骤）"。

---

## 二、记住四个词（看懂别人的配置就靠它们）

```
Workflow（工作流）= 一整套自动化流程，写在一个 .yml 文件里
   └─ 由一个 Event（事件）触发，比如 push、pull_request、定时
        └─ 包含一个或多个 Job（任务）
             └─ 每个 Job 由一串 Step（步骤）组成
                  └─ Step 可以执行命令，或调用别人写好的 Action（动作）
```

| 词 | 大白话 |
| --- | --- |
| **Workflow** | 一条完整的自动化流水线 |
| **Event** | 什么时候触发（push / 提 PR / 每天定时…） |
| **Job** | 流水线里的一个任务（可多个并行） |
| **Step** | 任务里的一小步（敲一条命令 / 用一个现成动作） |
| **Runner** | GitHub 提供的、真正帮你跑这些步骤的云端电脑 |
| **Action** | 别人封装好的可复用步骤，在 Marketplace 能搜到一堆 |

---

## 三、配置放哪？固定的目录结构

Actions 的配置文件，**必须**放在仓库的这个固定位置：

```
你的仓库/
└── .github/
    └── workflows/
        └── 随便起名.yml      ← 你的工作流写在这里（.yml 或 .yaml 后缀）
```

> 📌 `.github/workflows/` 这个路径**一个字都不能错**，GitHub 就认这里。文件用 **YAML** 格式（靠**缩进**表示层级，缩进必须用空格，不能用 Tab——这是新手最常踩的坑）。

---

## 四、实战：第一个会"打招呼"的工作流

我们做一个最简单的：**每次有人 push，GitHub 自动打印一句问候并列出文件**。最适合先看到"它真的在自动跑"。

### 最省事的建法：在网页上用模板

1. 进入任意仓库（用 `my-notes` 练手），点顶部 **Actions** 标签。
2. 第一次会推荐一堆模板，点最上面 **"set up a workflow yourself"**（自己配一个）。
3. 它会帮你新建 `.github/workflows/main.yml`，把内容**全部替换**成下面这段：

```yaml
name: 我的第一个工作流          # 工作流名字，会显示在 Actions 页

on: [push]                     # 触发事件：每次有人 push 就跑

jobs:
  say-hello:                   # 任务名（自己起）
    runs-on: ubuntu-latest     # 用一台云端 Ubuntu 电脑来跑
    steps:
      - name: 打个招呼
        run: echo "你好，这是我的第一个自动化流程！🎉"

      - name: 把代码拉下来
        uses: actions/checkout@v4   # 调用官方现成动作：把仓库代码下载到 runner

      - name: 列出仓库里的文件
        run: ls -la
```

4. 右上角 **Commit changes** 提交。

### 看它自动跑起来

提交后，**这次提交本身就是一次 push，立刻触发了工作流**：

1. 回到 **Actions** 标签，会看到一条正在跑（🟡 转圈）或已完成（✅ 绿勾）的记录。
2. 点进去 → 点 `say-hello` 任务 → 能看到**每一步的实时日志**，包括你那句"你好"被打印出来、`ls -la` 列出的文件。

🎉 你刚刚让 GitHub 在它的云端电脑上，**自动**执行了你写的步骤！

### 逐行读懂这段配置

| 配置 | 意思 |
| --- | --- |
| `name:` | 给工作流起个显示名 |
| `on: [push]` | **何时触发**——这里是"每次 push"。可改成 `on: [pull_request]`（提 PR 时）等 |
| `jobs:` | 下面是要做的任务 |
| `runs-on: ubuntu-latest` | 用一台**全新的云端 Ubuntu 电脑**来跑（跑完即焚） |
| `steps:` | 任务的步骤清单 |
| `run:` | **执行一条命令行命令** |
| `uses:` | **调用一个现成的 Action**，`actions/checkout@v4` 是最常用的"把代码拉到 runner 上" |

---

## 五、再进一步：一个"真有用"的例子（自动跑测试）

如果你写 Python 项目，可以让每次提交自动跑测试。把工作流换成：

```yaml
name: 自动测试

on: [push, pull_request]       # push 和提 PR 时都跑

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4         # 拉代码

      - uses: actions/setup-python@v5     # 装 Python 环境
        with:
          python-version: '3.12'

      - name: 安装依赖
        run: pip install -r requirements.txt

      - name: 运行测试
        run: pytest
```

之后，**谁提的 PR 只要测试没过（❌），就能一眼看出来别合并**——这正是第 6 章 PR 页面里 "Checks" 那一栏的来源。团队靠它**自动守住质量底线**。

> 💡 不写 Python 也一样：换成 Node.js 用 `npm test`、检查 Markdown 死链、自动部署网站……套路都是"**装环境 → 拉代码 → 跑命令**"。Marketplace（github.com/marketplace?type=actions）上有海量现成 Action 直接 `uses` 调用。

---

## 六、给项目加个"状态徽章"

配好工作流后，可以在 README 顶部放一个**实时显示"构建通过/失败"**的徽章（就是第 10 章那种）。格式：

```markdown
![CI](https://github.com/你的用户名/仓库名/actions/workflows/main.yml/badge.svg)
```

绿了说明自动检查通过，红了说明有问题——让访客一眼看到项目健康度，很专业。

---

## 七、两个安全 & 避坑提醒

| 提醒 | 说明 |
| --- | --- |
| 🔐 **别把密码/密钥写进 .yml** | 需要用敏感信息（如部署密钥）时，存到 **Settings → Secrets and variables → Actions**，在工作流里用 `${{ secrets.名字 }}` 引用，**绝不明文写进文件** |
| 📐 **YAML 缩进用空格不用 Tab** | 缩进错乱是最常见的报错。对齐用空格，层级靠缩进 |
| 💰 **公开仓库免费额度足够** | Public 仓库用 Actions 基本免费；Private 仓库有每月免费分钟数，超了才计费，个人学习用不完 |

---

## ✅ 本章自测 / 练习

1. 用自己的话解释 Workflow、Event、Job、Step 四个词的关系。
2. Actions 的配置文件必须放在哪个目录？文件是什么格式？最容易因为什么写错？
3. `run:` 和 `uses:` 两种步骤有什么区别？`actions/checkout` 是干嘛的？
4. **动手做**：在 `my-notes` 里建第四节那个"打招呼"工作流，提交后去 Actions 标签看它自动运行的日志，截图你那句问候被打印出来。
5. 需要在工作流里用一个部署密钥，正确的做法是把它写在哪里？为什么不能直接写进 .yml？

> 自动化也会了，进入 [13-实战练习与闯关清单](./13-实战练习与闯关清单.md)，用一套任务把全部技能练成肌肉记忆。
