#!/usr/bin/env bash
# =============================================================================
#  my-blogs 博客部署方案
#  更新：2026-06-10
# =============================================================================
#
#  ┌─────────────────────────────────────────────────────────────────┐
#  │  推荐方案：GitHub Actions 自动部署（已配置）                      │
#  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
#  │  效果：只需 git push，GitHub 自动构建 + 部署到 master 分支        │
#  │  优点：不依赖本地 Node 环境、不污染 main 分支、无需 subtree      │
#  │                                                                  │
#  │  使用方式：                                                      │
#  │    1. 写完博客，保存图片到 public/ 目录                           │
#  │    2. git add -A && git commit -m "xxx" && git push origin main   │
#  │    3. 等 1~2 分钟，GitHub Actions 自动完成部署                    │
#  │    4. 访问 https://zhangxiaofan-star.github.io 查看               │
#  │                                                                  │
#  │  注意：首次使用需要到 GitHub 仓库 Settings → Pages → Source      │
#  │        确认部署分支为 master                                      │
#  └─────────────────────────────────────────────────────────────────┘
#
#  备用方案：本地手动部署（见文末）
# =============================================================================


# =============================================================================
# 一、GitHub Actions 自动部署 —— 日常使用只需下面三行
# =============================================================================

cd D:/Project_vscode/vue/my-blogs
git add -A && git commit -m "feat: $(date +%Y-%m-%d) 更新博客"
git push origin main

# ✅ 完成！GitHub Actions 会自动处理构建和部署
# 可在 GitHub 仓库 → Actions 标签页查看部署进度


# =============================================================================
# 二、本地预览（开发调试时使用）
# =============================================================================
#
#  如果你想在本地预览效果，再决定是否 push：
#
#    cd D:/Project_vscode/vue/my-blogs
#    npm run dev
#
#  访问 http://localhost:8080 预览


# =============================================================================
# 三、常见问题
# =============================================================================

# Q1：GitHub Actions 部署失败？
#
#   检查步骤：
#   1. 访问 https://github.com/zhangxiaofan-star/zhangxiaofan-star.github.io/actions
#   2. 查看最新的 workflow run，点击看报错信息
#   3. 常见问题：
#      - "npm ci" 失败 → 删除 package-lock.json 重新 npm install
#      - " peaceiris/actions-gh-pages" 权限问题 → 检查 Settings → Actions → General → Workflow permissions 选 "Read and write permissions"

# Q2：页面更新了但网站没变化？
#
#   1. 先到 GitHub Actions 确认部署是否成功
#   2. 等待 1~3 分钟（GitHub Pages 有 CDN 缓存）
#   3. 强制刷新：Ctrl+Shift+R
#   4. 检查仓库 Settings → Pages 里 Source 是否为 master 分支

# Q3：想新增一篇博客？
#
#   1. 在 blogs/对应分类/ 下创建 .md 文件
#   2. 文件开头加 Front Matter：
#        ---
#        title: 文章标题
#        date: 2026-06-10
#        tags: [标签1, 标签2]
#        categories: [分类名]
#        ---
#   3. 配图放到 public/文章目录名/ 下
#   4. .md 里引用：![描述](/文章目录名/图片名.png)
#   5. git add -A && git commit && git push origin main


# =============================================================================
# 附：备用方案 —— 本地手动部署（GitHub Actions 不可用时的备用）
# =============================================================================
#
#  如果你不想用 GitHub Actions，可以取消下面代码的注释使用：
#
#  cd D:/Project_vscode/vue/my-blogs
#  git add -A && git commit -m "feat: 更新博客"
#  npm run build
#  git push origin $(git subtree split --prefix=public main):master --force
#  git push origin main
#
#  注意：本地构建需要 Node.js 环境，且 subtree split 首次运行较慢


# =============================================================================
# 附：项目结构速查
# =============================================================================
#
#  D:/Project_vscode/vue/my-blogs/
#  ├── .github/workflows/deploy.yml  ← GitHub Actions 配置
#  ├── .vuepress/
#  │   ├── config.js                  ← VuePress 主配置
#  │   └── public/                    ← 静态资源（图片等）
#  ├── blogs/                         ← 博客文章
#  ├── public/                        ← 静态资源（同 .vuepress/public）
#  ├── package.json
#  └── deploy.bash                    ← 本文件
#
#  GitHub 仓库分支：
#    main   → 博客源码（你 push 的地方）
#    master → 构建产物（GitHub Actions 自动推送，GitHub Pages 读取）
#
# =============================================================================
