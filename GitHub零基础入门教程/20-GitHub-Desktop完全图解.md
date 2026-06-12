# 20 · GitHub Desktop 完全图解（最怕命令行？用这个，全程点鼠标）

> 如果黑窗口（命令行）让你头疼，VS Code 又觉得太"程序员"——**GitHub Desktop 就是为你准备的**。它是 GitHub 官方出的图形软件，把 clone、commit、push、切分支、解决冲突全做成了**按钮**，点一点就完成。
> 这一篇把每个按钮、每块区域都用图标出来，**零基础也能全程不碰一行命令**完成日常工作。

---

## 一、它适合谁？和命令行、VS Code 怎么选

| 工具 | 难度 | 适合 |
| --- | --- | --- |
| **命令行**（第 04 章） | ⭐⭐⭐ | 想学"通用语言"、面试要用、追求效率 |
| **VS Code**（第 11 章） | ⭐⭐ | 要写代码，顺便管版本 |
| **GitHub Desktop**（本章） | ⭐ | **纯管文件/笔记、只想点鼠标、最怕命令** |

> 🔑 三者操作的是**同一个 Git 仓库**，随便混用。**真小白建议从 GitHub Desktop 开始**，建立信心后再慢慢接触命令行。本章每个操作我都标了它**等于哪条命令**，让你"会点"的同时也"心里有数"。

---

## 二、安装与登录（5 分钟）

### 步骤 1：下载安装

1. 打开 **https://desktop.github.com**
2. 点大大的下载按钮（它会自动认出你的系统，Windows 还是 Mac）。
3. 下载完双击安装，**一路默认**即可。

### 步骤 2：登录你的 GitHub 账号

第一次打开，它会让你登录：

1. 点 **Sign in to GitHub.com**。
2. 浏览器会跳出来让你授权，点 **Authorize（授权）**，输入账号密码 + 2FA 验证码（第 02 章）。
3. 回到软件，它会问你的 **Name 和 Email**（用于提交署名）——通常自动填好了，确认一下点继续。

> 🎁 **大福利**：用 Desktop 登录后，它会**自动帮你配好身份和推送权限**——第 02 章里让你头疼的 PAT 令牌、SSH 密钥**全都不用手动弄了**！这是 Desktop 对小白最友好的一点。

---

## 三、认识主界面（对照这张图）

登录后，打开一个仓库（下一节教怎么打开），你会看到这样的布局：

```
┌─────────────────────────────────────────────────────────────────┐
│ [① Current Repository ▾] [② Current Branch ▾] [③ Push/Fetch ▾]    │ ← 顶部三大下拉
├──────────────────────────┬──────────────────────────────────────┤
│ [Changes] [History]      │                                      │
│  ④ 改动的文件列表          │      ⑥ 右边大区域：                    │
│  ☑ 日记.md               │      选中文件时，显示这个文件             │
│  ☑ 读书清单.md            │      "改了哪几行"（绿增红删）            │
│  ☐ 草稿.md               │                                      │
│                          │                                      │
├──────────────────────────┤                                      │
│ ⑤ Summary（提交标题）     │                                      │
│ [______________________] │                                      │
│ Description（可选）       │                                      │
│ [______________________] │                                      │
│ [ Commit to main ]  ← 提交按钮                                    │
└──────────────────────────┴──────────────────────────────────────┘
```

| 标号 | 名称 | 作用 | 等于命令 |
| --- | --- | --- | --- |
| ① | **Current Repository**（当前仓库） | 切换/添加你在管理的仓库 | —— |
| ② | **Current Branch**（当前分支） | 看当前在哪个分支、切换、新建分支 | `git branch` / `git switch` |
| ③ | **Push/Fetch origin** | 上传/检查云端更新（按钮文字会变） | `git push` / `git fetch` |
| ④ | **Changes 标签** | 列出你改动过的所有文件 | `git status` |
| ⑤ | **Summary + Commit 按钮** | 写提交说明并提交 | `git commit -m` |
| ⑥ | **右侧 diff 区** | 显示选中文件改了哪几行 | `git diff` |
| — | **History 标签** | 看过去所有提交历史 | `git log` |

---

## 四、把一个仓库"放进" Desktop

打开软件后，菜单 **File（文件）** 里有三个选项，对应三种情况：

### 情况 A：克隆我 GitHub 上已有的仓库（最常见）

1. **File → Clone repository（克隆仓库）**。
2. 它会**列出你账号下所有仓库**，点选一个（比如第 17 章建的 `my-first-repo`）。
3. **Local path（本地路径）**：选个文件夹存它（默认放在"文档/GitHub"下，挺好）。
4. 点 **Clone**。

> 🔗 等于 `git clone`。下载完，这个仓库就出现在 Desktop 里了。

### 情况 B：把我电脑里现成的文件夹变成仓库

1. **File → Add local repository**，选那个文件夹。
2. 如果它还不是 Git 仓库，Desktop 会提示 **"create a repository"**，点它初始化。

### 情况 C：从零新建一个仓库

1. **File → New repository（新建仓库）**。
2. 填名字、本地位置、勾上 **Initialize with a README**。
3. 点 **Create repository**。
4. 建好后是**只在本地的**，点顶部 **Publish repository（发布仓库）** 才会传到 GitHub（会问你公开还是私有）。

---

## 五、日常核心循环：改 → 提交 → 推送（全程点鼠标）

这是你天天要做的，跟着走一遍：

### 第 1 步：改文件

用你习惯的任何软件改仓库里的文件——记事本、Word、VS Code 都行。**改完保存。**

> 💡 想快速打开仓库文件夹？Desktop 菜单 **Repository → Show in Explorer（Mac 是 Finder）**，直接跳到文件夹。

### 第 2 步：回到 Desktop，看改动

切回 GitHub Desktop，**左侧 Changes 标签**会自动列出你刚改/新增的文件，每个前面有个**勾选框 ☑**。点某个文件，**右侧**就显示它改了哪几行（绿色新增、红色删除）。

> 🔗 这一屏 = `git status` + `git diff` 合体，还是可视化的。

### 第 3 步：写提交说明并提交

1. 左下角 **Summary（摘要）** 框里，写一句话说清这次改了啥，比如 `更新读书清单`。（这就是 commit message）
2. 下面 **Description** 可留空。
3. **勾选框决定提交哪些文件**——默认全勾，你也可以**只勾这次想提交的**那几个。
4. 点蓝色按钮 **Commit to main**（提交到 main 分支）。

> 🔗 等于 `git add`（勾选）+ `git commit -m "更新读书清单"`。**勾选 = add，按钮 = commit，一步到位。**

### 第 4 步：推送到 GitHub

提交完，改动还在本地。看**右上角按钮**，现在会变成 **Push origin**（带个数字，表示有几个提交待上传）。点它。

> 🔗 等于 `git push`。点完，刷新 GitHub 网页，改动就上去了 🎉。

### 一图记住

```
改文件保存 → 回Desktop看Changes → 写Summary → Commit to main → Push origin
   (工作区)      (git status)       (写说明)    (add+commit)    (push)
```

> 💡 顶部按钮平时显示 **Fetch origin**（检查云端有没有新东西），有你没下载的更新会变 **Pull origin**（点它拉下来），有你没上传的提交会变 **Push origin**。**没事多点 Fetch，保持和云端同步。**

---

## 六、用 Desktop 玩分支（对应第 05 章）

### 新建分支

1. 点顶部 **Current Branch** 下拉 → **New Branch**。
2. 输入分支名（如 `test`）→ **Create Branch**。它会自动切过去。

> 🔗 等于 `git switch -c test`

### 切换分支

点 **Current Branch** 下拉，从列表里点另一个分支名即可切换。

> 📺 切换后，你电脑文件夹里的文件会**自动变成那个分支的样子**（第 05 章说的"平行宇宙"）。

### 合并分支

1. 先切到要"接收成果"的分支（如 `main`）。
2. **Current Branch → Choose a branch to merge into main**，选 `test`，确认合并。

> 🔗 等于 `git switch main` + `git merge test`

### 发起 Pull Request

把分支 push 上去后，**Current Branch → Preview Pull Request** 或点提示里的 **Create Pull Request**，它会**自动打开浏览器**到 PR 创建页（接下来照第 06 章操作）。

---

## 七、解决冲突（Desktop 也很友好）

当 pull 或 merge 遇到冲突，Desktop 会弹窗告诉你**哪些文件冲突了**，并给你两条路：

1. **Open in [编辑器]**：用 VS Code 等打开，按第 11 章的按钮方式解决（推荐）。
2. 直接在弹窗里，对每个冲突文件选择**用哪个版本**。

解决完，回到 Desktop 正常 **Commit** 即可完成合并。

> 📖 冲突的原理见第 05 章；这里 Desktop 帮你把"找到冲突文件"这步可视化了。

---

## 八、History 标签：你的时光机

点左上 **History** 标签，能看到**所有提交历史**，每条点开能看那次改了啥（绿增红删）。

- 想撤销某次提交？**右键那条提交 → Revert changes in commit**（生成一个反向提交，安全，对应第 07 章 `git revert`）。
- 想看某次提交的细节，点一下即可。

> 🔗 等于 `git log` + `git show` + `git revert`，全可视化。

---

## 九、Desktop 常用菜单速查

| 我想…… | 在哪点 |
| --- | --- |
| 打开仓库文件夹 | Repository → Show in Explorer/Finder |
| 用编辑器打开仓库 | Repository → Open in [VS Code...] |
| 在浏览器打开这个仓库的 GitHub 页 | Repository → View on GitHub |
| 检查云端有没有更新 | 顶部 Fetch origin |
| 看历史 | 左上 History 标签 |
| 撤销最近一次"还没提交"的改动 | Changes 里右键文件 → Discard changes |
| 撤销某次"已提交"的改动 | History 里右键提交 → Revert changes in commit |

---

## 十、什么时候还得碰命令行？

GitHub Desktop 能覆盖**管文件、写笔记、简单协作**的几乎全部需求。少数高级操作（复杂的 reset、reflog、批量操作）它没有按钮，那时再用命令行（第 04、07 章）。

> 🔑 **结论**：怕命令行？**就从 GitHub Desktop 开始，零负担**。等熟悉了流程、有了底气，再去碰命令行也不迟——到那时你已经懂"它在干嘛"了，学命令只是换个输入方式。

---

## ✅ 本章自测 / 练习

1. GitHub Desktop 最大的"省事"之处是什么？（提示：第 02 章那些钥匙配置）
2. 在 Desktop 里，"勾选文件 + 写 Summary + 点 Commit"分别对应命令行的哪几条命令？
3. 顶部那个按钮什么时候显示 Fetch、什么时候显示 Pull、什么时候显示 Push？
4. **动手做**：装好 GitHub Desktop，克隆你的 `my-first-repo`，改一下 README，全程**只点鼠标**完成提交和推送，去网页确认成功。
5. **进阶动手**：在 Desktop 里新建一个分支 `desktop-test`，提交点东西，再合并回 main，最后删掉它。

> ← 回 [总览 README](./README.md)　｜　想看命令行版同样的操作：[04 章](./04-Git命令行基础.md)、[05 章](./05-分支与合并.md)
