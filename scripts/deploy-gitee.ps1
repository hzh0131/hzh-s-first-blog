<#
.SYNOPSIS
    构建博客并发布到 Gitee Pages（推送 dist/ 到 gh-pages 分支）。

.DESCRIPTION
    Gitee Pages 的项目页地址形如 https://<用户名>.gitee.io/<仓库名>/，
    所以构建时必须把 base 设成 /<仓库名>，否则 CSS/图片会 404。

.EXAMPLE
    .\scripts\deploy-gitee.ps1 -GiteeUser hzh0131

.EXAMPLE
    .\scripts\deploy-gitee.ps1 -GiteeUser hzh0131 -NoPush   # 只构建并检查 dist，不推送
#>
param(
    [Parameter(Mandatory = $true)][string]$GiteeUser,
    [string]$Repo = "hzh-s-first-blog",
    [string]$Branch = "gh-pages",
    [switch]$NoPush
)

# PS 5.1 下若把 ErrorActionPreference 设为 Stop，原生命令写到 stderr 的普通提示
# （例如 Browserslist 的过期提醒）会被当成致命错误中断构建，所以保持 Continue，
# 失败与否统一用 $LASTEXITCODE 判断。
$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$siteUrl = "https://$GiteeUser.gitee.io/$Repo/"
$basePath = "/$Repo"
$env:SITE_URL = $siteUrl
$env:BASE_PATH = $basePath

Write-Host "站点地址: $siteUrl" -ForegroundColor Cyan
Write-Host "资源前缀: $basePath" -ForegroundColor Cyan

if (-not (Test-Path "node_modules")) {
    pnpm install
    if ($LASTEXITCODE -ne 0) { throw "pnpm install 失败" }
}

pnpm build
if ($LASTEXITCODE -ne 0) { throw "pnpm build 失败" }
if (-not (Test-Path "dist/index.html")) { throw "没有生成 dist/index.html，构建结果不对" }

# Gitee Pages 用 Jekyll 渲染，下划线开头的文件/目录会被忽略，用 .nojekyll 关掉
Set-Content -Path "dist/.nojekyll" -Value "" -NoNewline

# 检查子路径是否真的生效（防止忘了改 base 导致线上样式全丢）
$html = Get-Content "dist/index.html" -Raw
if ($html -notmatch [regex]::Escape("$basePath/assets/")) {
    throw "构建结果里没有 $basePath/assets/ 前缀，base 没有生效"
}
Write-Host "构建检查通过，dist/ 已按 $basePath 生成" -ForegroundColor Green

if ($NoPush) {
    Write-Host "已指定 -NoPush，跳过推送。" -ForegroundColor Yellow
    return
}

$remoteUrl = "https://gitee.com/$GiteeUser/$Repo.git"
Push-Location dist
try {
    if (-not (Test-Path ".git")) {
        git init -q
        git checkout -q -b $Branch
    }
    git add -A
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    git -c user.name="gitee-pages" -c user.email="gitee-pages@local" commit -q -m "deploy: $stamp" --allow-empty
    if ($LASTEXITCODE -ne 0) { throw "git commit 失败" }
    git push -f $remoteUrl "HEAD:refs/heads/$Branch"
    if ($LASTEXITCODE -ne 0) { throw "git push 失败（检查 Gitee 账号密码 / 仓库是否存在）" }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "推送完成。首次部署还需要在网页上启动 Gitee Pages：" -ForegroundColor Green
Write-Host "  1. 打开 https://gitee.com/$GiteeUser/$Repo/pages"
Write-Host "  2. 部署分支选 $Branch，部署目录留空，勾选【强制使用 HTTPS】，点【启动】"
Write-Host "  3. 之后每次推送完，在同一个页面点【更新】才会重新部署"
Write-Host "  访问地址: $siteUrl" -ForegroundColor Cyan
