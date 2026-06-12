# 09 · 用 GitHub Pages 免费建一个网站（10 分钟上线）

> 这是整套教程里**最有成就感**的一章：不花一分钱、不用买服务器，用 GitHub 给自己上线一个**真实可访问的网站**——个人主页、博客、简历、项目文档都行。
> 学完你会有一个 `https://你的用户名.github.io` 的网址，发给任何人都能打开。

---

## 一、GitHub Pages 是什么？

> 🔑 一句话：**GitHub Pages = GitHub 免费帮你把仓库里的网页文件，变成一个公网能访问的网站。**

你只要把 `.html` / `.css` / 图片这些文件放进仓库，打开一个开关，GitHub 就给你一个网址。它的特点：

| 能做 | 不能做 |
| --- | --- |
| ✅ 个人主页、作品集、简历 | ❌ 带后台数据库的网站（如论坛、商城后台） |
| ✅ 博客、文档站 | ❌ 运行 PHP / Java / Python 后端程序 |
| ✅ 静态展示页、活动页 | ❌ 用户登录注册、存数据到服务器 |

也就是说，它只托管**静态网站**（纯展示，内容写死在文件里）。对小白来说，做个人网站/简历/博客**完全够用，而且免费**。

---

## 二、两种站点，先分清

| 类型 | 网址长这样 | 怎么建 | 每个账号能有几个 |
| --- | --- | --- | --- |
| **用户站点** | `你的用户名.github.io` | 建一个**名字必须是 `用户名.github.io`** 的仓库 | 1 个 |
| **项目站点** | `你的用户名.github.io/仓库名` | 任意仓库，在设置里开启 Pages | 每个仓库 1 个 |

下面我们先做最酷的**用户站点**（网址最短最好看），再讲项目站点。

---

## 三、实战 A：建一个 `用户名.github.io` 个人网站

### 第 1 步：建一个特殊名字的仓库

1. 点 **➕ → New repository**。
2. **Repository name** 必须填成：`你的用户名.github.io`
   - ⚠️ 比如你用户名是 `lixiaoming`，就填 `lixiaoming.github.io`，**一个字都不能错**（GitHub 就靠这个名字识别它是个人站点）。
3. 选 **Public**，勾上 **Add a README file**，点 **Create repository**。

### 第 2 步：放一个网页文件 `index.html`

`index.html` 是网站的**首页**（浏览器默认打开的就是它）。在网页上建：**Add file → Create new file**，文件名输 `index.html`，内容**直接复制**下面这段（把名字换成你自己的）：

```html
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>李小明的个人主页</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 680px;
           margin: 60px auto; padding: 0 20px; line-height: 1.8; color: #222; }
    h1 { color: #2563eb; }
    a { color: #2563eb; }
    .card { background: #f3f4f6; border-radius: 12px; padding: 20px; margin: 20px 0; }
  </style>
</head>
<body>
  <h1>👋 你好，我是李小明</h1>
  <p>一名正在学习编程的学生，喜欢折腾各种有意思的东西。</p>

  <div class="card">
    <h2>🛠️ 我会的</h2>
    <ul>
      <li>Git 与 GitHub</li>
      <li>HTML / CSS 入门</li>
      <li>写学习笔记</li>
    </ul>
  </div>

  <div class="card">
    <h2>📫 找到我</h2>
    <p>GitHub：<a href="https://github.com/lixiaoming">@lixiaoming</a></p>
    <p>邮箱：lixiaoming@example.com</p>
  </div>

  <footer><small>用 GitHub Pages 免费搭建 🚀</small></footer>
</body>
</html>
```

下方填 commit message（如 `新增首页`），**Commit changes** 提交。

> 💡 看不懂 HTML 没关系，**先复制能跑通**，建立成就感。想学网页，把这段当模板改文字、改颜色（`#2563eb` 是蓝色，可换成 `#e11d48` 红色等）就行。

### 第 3 步：访问你的网站

用户站点**默认就开启**了 Pages，不用额外设置。等 1–3 分钟（第一次稍慢），打开浏览器访问：

```
https://你的用户名.github.io
```

🎉 你的网站上线了！全世界都能访问这个网址。

> 📌 怎么确认/查看地址：仓库 **Settings → Pages**，页面顶部会显示 **"Your site is live at https://..."** 和一个 **Visit site** 按钮。

---

## 四、实战 B：给已有项目开一个文档站（项目站点）

比如你想给第 3 章建的 `my-notes` 仓库做个网页版：

1. 进入 `my-notes` 仓库 → **Settings → Pages**。
2. **Source** 选 **Deploy from a branch**。
3. **Branch** 选 `main`，文件夹选 `/ (root)`，点 **Save**。
4. 等几分钟，访问 `https://你的用户名.github.io/my-notes`。

> 💡 如果你的网页文件放在仓库的 `docs/` 文件夹里，第 3 步文件夹就选 `/docs`。

### 懒人福利：一键套用主题（不写代码）

不想写 HTML？GitHub 自带现成主题，能直接把你仓库里的 **Markdown（`.md`）文件**变成漂亮网页：

1. **Settings → Pages**，往下找到 **Theme Chooser**，点 **Choose a theme**。
2. 挑一个喜欢的主题，**Select theme**。
3. 它会自动给你生成配置，你仓库里的 `README.md` 就会被渲染成带样式的网页。

这样你写笔记只管用 Markdown（第 3、10 章），网站样式 GitHub 全包了。

---

## 五、进阶一点点（知道有这回事就行）

- **自定义域名**：买了自己的域名（如 `xiaoming.com`）可以绑定到 Pages，在 **Settings → Pages → Custom domain** 填入即可，更显专业。
- **Jekyll 博客**：GitHub Pages 内置一个叫 Jekyll 的工具，能把 Markdown 自动生成博客。想搭博客可搜 "GitHub Pages Jekyll 博客 教程"。
- **更强的静态框架**：等你深入了，可以了解 Hugo、Hexo、VitePress 等，配合 GitHub Actions（第 12 章）自动发布。

---

## 六、踩坑急救

| 现象 | 原因 / 解法 |
| --- | --- |
| 访问是 **404** | ①刚提交要等几分钟才生效；②确认仓库里有 **`index.html`**（首页文件名必须是它）；③确认 Settings → Pages 里分支选对了 |
| 网址打不开 / 一直空白 | 用户站点仓库名必须**精确**等于 `用户名.github.io`；大小写也别错 |
| 改了内容但网站没变 | Pages 部署要 1–2 分钟；浏览器按 `Ctrl+F5` 强制刷新清缓存 |
| 图片不显示 | 图片也要 commit 进仓库，HTML 里用**相对路径**引用，如 `<img src="photo.jpg">` |

---

## ✅ 本章自测 / 练习

1. 用户站点和项目站点的网址有什么不同？一个账号能建几个用户站点？
2. **动手做**：建一个 `用户名.github.io`，用上面的模板上线你的个人主页，改成你自己的名字和介绍，把网址发给朋友看。
3. GitHub Pages 能做带登录注册、把数据存到服务器的网站吗？为什么？
4. 你的网站打开是 404，列出三个最可能的原因。

> 上线了网站，进入 [10-美化主页与Markdown进阶](./10-美化主页与Markdown进阶.md)，把你的 GitHub 主页也变好看。
