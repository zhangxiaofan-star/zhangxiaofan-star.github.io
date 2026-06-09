#!/usr/bin/env bash
# =============================================================================
#  my-blogs 博客部署完整教程
#  仓库：zhangxiaofan-star/zhangxiaofan-star.github.io
#  更新：2026-06-10
# =============================================================================
#
#  ─────────────────────────────────────────────────────
#  目录
#  ─────────────────────────────────────────────────────
#  一、项目结构说明
#  二、环境依赖说明
#  三、SSH 代理配置（已完成，仅供参考）
#  四、日常更新博客的完整命令
#  五、常见问题 & 排查
#  ─────────────────────────────────────────────────────


# =============================================================================
# 一、项目结构说明
# =============================================================================
#
#  D:/Project_vscode/vue/my-blogs/
#  ├── blogs/                    ← 博客文章（.md 文件）
#  │   ├── category1/            ← 嵌入式（ESP32）
#  │   ├── category2/            ← AI/大模型 & 后端
#  │   └── category3/            ← SpringBoot
#  ├── docs/                     ← 留言板等特殊页面
#  ├── public/                   ← 静态资源（图片等） & 构建输出目录
#  ├── .vuepress/config.js       ← VuePress 主配置
#  ├── package.json
#  └── deploy.bash               ← 本文件
#
#  GitHub 仓库分支说明：
#  ┌────────────────┬─────────────────────────────────────────┐
#  │ 分支            │ 内容                                      │
#  ├────────────────┼─────────────────────────────────────────┤
#  │ main           │ 博客源码（.md 文章、配置、图片素材等）          │
#  │ master         │ 构建产物（public/ 下的 HTML/CSS/JS 静态文件） │
#  └────────────────┴─────────────────────────────────────────┘
#  GitHub Pages 读取 master 分支 → 部署到 zhangxiaofan-star.github.io


# =============================================================================
# 二、环境依赖说明
# =============================================================================
#
#  Node.js  : 推荐使用 managed 版本
#    路径：C:\Users\RUzha\.workbuddy\binaries\node\versions\22.22.2\node.exe
#
#  VuePress : 已安装在 node_modules，无需全局安装
#    构建命令：node node_modules/vuepress/cli.js build .
#
#  Git      : D:/Program Files/Git/mingw64/bin/connect.exe（SSH 代理工具）
#
#  Clash Verge（代理工具）:
#    HTTP  代理端口：127.0.0.1:7897
#    SSH 推送需要代理，已通过 ~/.ssh/config 配置好


# =============================================================================
# 三、SSH 代理配置（已完成，仅供参考）
# =============================================================================
#
#  文件位置：C:\Users\RUzha\.ssh\config
#
#  配置内容：
#  ─────────────────────────────────────────────
#  # GitHub via Clash Verge proxy
#  Host github.com
#      HostName github.com
#      User git
#      ProxyCommand "D:/Program Files/Git/mingw64/bin/connect.exe" -H 127.0.0.1:7897 %h %p
#
#  # GitHub SSH over HTTPS port（443端口，穿透某些防火墙）
#  Host github443
#      HostName ssh.github.com
#      Port 443
#      User git
#      ProxyCommand "D:/Program Files/Git/mingw64/bin/connect.exe" -H 127.0.0.1:7897 %h %p
#  ─────────────────────────────────────────────
#
#  当前 remote 使用 github443 别名（SSH 走 443 端口 + HTTP 代理）：
#    git@github443:zhangxiaofan-star/zhangxiaofan-star.github.io.git
#
#  验证 SSH 连接是否正常：
ssh -T git@github443 -o ConnectTimeout=15 2>&1
#  预期输出：Hi zhangxiaofan-star! You've successfully authenticated...


# =============================================================================
# 四、日常更新博客的完整命令
# =============================================================================

# ── 进入项目目录 ──────────────────────────────────────────────
cd D:/Project_vscode/vue/my-blogs

# ── Step 1：提交博客源码到 main 分支 ──────────────────────────
git add -A
git commit -m "feat: 描述你的更新内容"
git push origin main
# ✅ 推送源码到 GitHub main 分支


# ── Step 2：构建静态页面 ───────────────────────────────────────
"C:\Users\RUzha\.workbuddy\binaries\node\versions\22.22.2\node.exe" node_modules/vuepress/cli.js build .
# 构建完成后，静态文件会输出到 public/ 目录
# ✅ 构建时间约 30~60 秒


# ── Step 3：把构建产物推送到 master 分支（触发 GitHub Pages 部署）──
git push origin $(git subtree split --prefix=public main):master --force
# ✅ 推送完成后，等 1~2 分钟刷新 https://zhangxiaofan-star.github.io


# ── 一键脚本（三步合一）────────────────────────────────────────
# 把下面三行复制到终端运行，把"这里填写你的更新说明"替换成实际内容：
: '
cd D:/Project_vscode/vue/my-blogs
git add -A && git commit -m "feat: 这里填写你的更新说明"
"C:\Users\RUzha\.workbuddy\binaries\node\versions\22.22.2\node.exe" node_modules/vuepress/cli.js build .
git push origin $(git subtree split --prefix=public main):master --force && git push origin main
'


# =============================================================================
# 五、常见问题 & 排查
# =============================================================================

# ── Q1：push 报错 "Connection reset" 或 "Timed out" ─────────────
#
#  原因：Clash Verge 代理没开，或端口变了
#  排查：
curl -x http://127.0.0.1:7897 -s -o /dev/null -w "%{http_code}" --max-time 8 https://api.github.com
#  如果返回 200 或 403，说明代理正常；如果 000，说明代理没开
#
#  解决：打开 Clash Verge，确保 HTTP 代理端口是 7897，然后重试


# ── Q2：SSH 测试报 "sign_and_send_pubkey: no mutual signature" ──
#
#  原因：SSH key 算法不被支持
#  解决：在 ~/.ssh/config 的 github443 Host 块里加一行：
#    PubkeyAcceptedAlgorithms +ssh-rsa


# ── Q3：构建出错（Node 版本问题）────────────────────────────────
#
#  确保用 managed node（22.x），不要用系统 node：
"C:\Users\RUzha\.workbuddy\binaries\node\versions\22.22.2\node.exe" --version
#  预期输出：v22.22.2


# ── Q4：git subtree split 卡住或报错 ────────────────────────────
#
#  说明：git subtree split 会遍历所有提交历史，首次运行较慢（1~3 分钟）
#  耐心等待即可；如果报 "prefix 'public' did not match any files"，
#  说明 public/ 目录没有被 commit，先检查 .gitignore 是否误忽略了 public/


# ── Q5：页面更新了但网站没变化 ───────────────────────────────────
#
#  1. 等待 1~3 分钟，GitHub Pages 有构建延迟
#  2. 强制刷新浏览器缓存：Ctrl+Shift+R
#  3. 检查 GitHub 仓库 Actions 页面，看 Pages 是否部署成功


# ── Q6：想新增一篇博客的完整流程 ────────────────────────────────
#
#  1. 在对应分类目录下创建 .md 文件，例如：
#       blogs/category2/2026/新文章标题.md
#
#  2. 文件开头必须有 Front Matter（参考其他 .md 的格式）：
#       ---
#       title: 文章标题
#       date: 2026-06-10
#       tags: [标签1, 标签2]
#       categories: [分类名]
#       ---
#
#  3. 如果有配图，把图片放在 public/文章目录名/ 下，
#     在 .md 里引用时用绝对路径：
#       ![图片描述](/文章目录名/图片文件名.png)
#
#  4. 按照第四节的三步命令推送部署即可


# =============================================================================
# 附：git 配置信息备忘
# =============================================================================
#
#  git remote：
#    origin → git@github443:zhangxiaofan-star/zhangxiaofan-star.github.io.git
#
#  git 代理（全局）：
#    http.proxy  = http://127.0.0.1:7890
#    https.proxy = http://127.0.0.1:7890
#    （实际 SSH 推送走 ~/.ssh/config 里的 ProxyCommand，不走 http.proxy）
#
#  查看当前 git 配置：
git config --global --list | grep proxy
git remote -v
#
# =============================================================================
# End of deploy.bash
# =============================================================================
