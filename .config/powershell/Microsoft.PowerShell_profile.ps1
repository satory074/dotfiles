# ============================================================
# Microsoft.PowerShell_profile.ps1
# PowerShell equivalent of .zshrc (WSL2 → native Windows migration)
# ============================================================

# --- UTF-8 output ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# .env (git credentials: MAIN_GIT_USER, MAIN_GIT_EMAIL, etc.)
# ============================================================
$_dotenv = Join-Path $HOME 'dotfiles\.env'
if (Test-Path $_dotenv) {
    Get-Content $_dotenv | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' } | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $k = $Matches[1].Trim()
            $v = $Matches[2].Trim().Trim('"').Trim("'")
            if ($k) { [System.Environment]::SetEnvironmentVariable($k, $v, 'Process') }
        }
    }
}
Remove-Variable _dotenv

# ============================================================
# Environment Variables
# ============================================================
$env:EDITOR        = 'nvim'
$env:BASECAMP_PATH = "$HOME\basecamp"
$env:SRC_PATH      = "$env:BASECAMP_PATH\src"
$env:GEMINI_MODEL  = 'gemini-2.5-pro'

# PATH additions (add only if the path exists)
@("$HOME\.local\bin", "$HOME\.pub-cache\bin") | ForEach-Object {
    if ((Test-Path $_) -and $env:PATH -notlike "*$_*") {
        $env:PATH = "$_;$env:PATH"
    }
}

# --- Netskope CA Certificate (Windows) ---
$_netscopeCert = 'C:\ProgramData\netskope\stagent\data\nscacert_combined.pem'
if (Test-Path $_netscopeCert) {
    $env:REQUESTS_CA_BUNDLE = $_netscopeCert
    $env:AWS_CA_BUNDLE      = $_netscopeCert
    $env:CURL_CA_BUNDLE     = $_netscopeCert
    $env:NODE_EXTRA_CA_CERTS = $_netscopeCert
    $env:GIT_SSL_CAINFO     = $_netscopeCert
}
Remove-Variable _netscopeCert

# ============================================================
# PSReadLine (replaces zsh-autosuggestions + syntax-highlighting)
# ============================================================
if (Get-Module -ListAvailable -Name PSReadLine -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -MaximumHistoryCount 100000
    Set-PSReadLineKeyHandler -Key Tab            -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow        -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow      -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key 'Ctrl+r'       -Function ReverseSearchHistory
}

# ============================================================
# Navigation
# ============================================================
function cda {
    param($path = $HOME)
    Set-Location $path
    Get-ChildItem -Force
}
function mkd {
    param($name)
    New-Item -ItemType Directory -Path $name -Force | Out-Null
    Set-Location $name
}
function op {
    if ($args.Count -gt 0) { Invoke-Item $args[0] } else { Invoke-Item '.' }
}
function lsa { Get-ChildItem -Force $args }

# ============================================================
# Clipboard
# ============================================================
function cpa {
    param($path)
    Get-Content -Encoding UTF8 $path | Set-Clipboard
}

# ============================================================
# Path shortcuts
# ============================================================
function vweek  { nvim "$env:SRC_PATH\weekly-memo\current.md" }
function catc   { cda "$env:SRC_PATH\AtCoder\satory074" }
function cbas   { cda $env:BASECAMP_PATH }
function cdot   { cda "$HOME\dotfiles" }
function csrc   { cda $env:SRC_PATH }

# ============================================================
# Config file shortcuts
# ============================================================
function vvr  { vim "$HOME\.vimrc" }
function nvvr { nvim "$HOME\.vimrc" }
function nvzr { nvim $PROFILE }
function nvnv { nvim "$HOME\.config\nvim\init.lua" }
function vzr  { nvim $PROFILE }
function szr  { . $PROFILE }
function sva  { . ".\.venv\Scripts\Activate.ps1" }
function venva { . ".\.venv\Scripts\Activate.ps1" }
function venvd { deactivate }

# ============================================================
# npx
# ============================================================
function nndp { npx netlify deploy --prod }

# ============================================================
# Git
# ============================================================
function ga    { git add $args; git status }
function gau   { git add -u; git status }
function gb    { git branch $args }
function gbr   { git branch $args }
function gbd   { git branch -d $args }
function gbm   { git branch -m $args }
function gch   { git checkout $args }
function gcho  { git checkout $args }
function gchob { git checkout -b $args }
function gcan  { git commit --amend --no-edit }
function gcm   { git commit -m $args }
function gd    { git diff $args }
function ghal  { gh auth login }
function ghic  { gh issue create $args }
function ghicl { gh issue close $args }
function glg   { git log --oneline $args }
function gme   { git merge $args }
function gpom  { git push -u origin main --tags }
function gpfom { git push --force-with-lease origin main }
function gprom { git pull -r origin main }
function gpush { git push --follow-tags $args }
function gptag { git push origin --tags }
function grbs  { git rebase $args }
function grir  { git rebase -i --root }
function grst  { git reset $args }
function gs    { git status }
function gsw   { git switch $args }
function gswc  { git switch -c $args }
function gswd  { git switch develop }
function gswm  { git switch main }
function gsws  { git switch staging }
function gtag  { git tag $args }
function gst   { git stash $args }
function gstp  { git stash pop }
function gstl  { git stash list }
function gstd  { git stash drop }
function gsts  { git stash show -p }
function gwta  { git worktree add $args }
function gwtl  { git worktree list }
function gwtr  { git worktree remove $args }
function gfb   { fzf-git-branch }
function gfa   { fzf-git-add }

function gmain {
    git config --global user.name  $env:MAIN_GIT_USER
    git config --global user.email $env:MAIN_GIT_EMAIL
    git config user.name
    gh auth switch --hostname github.com --user $env:MAIN_GIT_USER
}
function gsub {
    git config --global user.name  $env:SUB_GIT_USER
    git config --global user.email $env:SUB_GIT_EMAIL
    git config user.name
    gh auth switch --hostname github.com --user $env:SUB_GIT_USER
}

function fzf-git-branch {
    $branch = git branch --all | Where-Object { $_ -notmatch 'HEAD' } | fzf
    if ($branch) {
        $b = $branch.Trim() -replace '^remotes/[^/]+/', ''
        git checkout $b
    }
}
function fzf-git-add {
    $files = git status --short | fzf -m | ForEach-Object { $_.Trim() -split '\s+' | Select-Object -Last 1 }
    if ($files) {
        $files | ForEach-Object { git add $_ }
        git status
    }
}

# ============================================================
# Python / uv
# ============================================================
function pym  { python main.py }
function uvi  {
    param($name)
    uv init $name
    Set-Location $name
    Get-ChildItem -Force
}
function uva  { uv --native-tls add $args }
function uvar { uv --native-tls add -r requirements.txt }
function uvr  { uv run $args }
function uvrm { uv run main.py }
function uver { uv export -o requirements.txt --no-hashes }

# ============================================================
# AtCoder
# ============================================================
function accn {
    param($name)
    acc new $name
    code $name
    cda $name
}
function accs    { acc s --skip-filename -- --guess-python-interpreter pypy }
function ojt     { oj t -c "python main.py" }
function catctmp { cda (acc config-dir) }

# ============================================================
# Modern CLI tools (conditional on availability)
# ============================================================
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat --paging=never $args }
}
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --icons $args }
    function ll { eza -l  --icons --git $args }
    function la { eza -la --icons --git $args }
    function lt { eza --tree --icons -L 2 $args }
    function lsa { eza -la --icons --git $args }
} else {
    function ll { Get-ChildItem -Force $args }
    function la { Get-ChildItem -Force $args }
}
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function rgg  { rg --hidden --glob '!.git' $args }
    function todo { rg 'TODO|FIXME|HACK' --glob '!*.lock' $args }
}
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    function lg { lazygit $args }
}

# ============================================================
# fzf
# ============================================================
$env:FZF_DEFAULT_OPTS = '--height 40% --reverse --border'
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
}

# ============================================================
# zoxide (replaces z/zi from zshrc)
# ============================================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell | Out-String)
    # 'z' and 'zi' are now available from zoxide init
    function zz { zi $args }
}

# ============================================================
# Utility functions
# ============================================================
function psg {
    param($pattern)
    Get-Process | Where-Object { $_.Name -match $pattern -or $_.Description -match $pattern }
}
function port {
    param([int]$p)
    netstat -ano | Select-String ":$p\s"
}
function killport {
    param([int]$p)
    $pids = netstat -ano | Select-String ":$p\s" |
            ForEach-Object { ($_.Line.Trim() -split '\s+')[-1] } |
            Sort-Object -Unique
    foreach ($id in $pids) {
        if ($id -match '^\d+$') {
            Stop-Process -Id $id -Force -ErrorAction SilentlyContinue
            Write-Host "Killed PID $id"
        }
    }
}
function bak {
    param($path)
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Copy-Item -Recurse $path "${path}.bak.${ts}"
}
function dsize {
    param($path = '.')
    Get-ChildItem $path -Directory | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum ?? 0
        [PSCustomObject]@{ SizeKB = [int]($size / 1KB); Name = $_.Name }
    } | Sort-Object SizeKB -Descending | Select-Object -First 20 |
        ForEach-Object { "{0,10} KB  {1}" -f $_.SizeKB, $_.Name }
}
function recent {
    param([int]$days = 1)
    Get-ChildItem -Recurse -File |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-$days) -and
                       $_.FullName -notmatch '\\\.git\\' } |
        Sort-Object LastWriteTime
}
function tre { tree $args }

# ============================================================
# Node version management (fnm - fast, cross-platform)
# ============================================================
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

# ============================================================
# clasp (Google Apps Script CLI)
# ============================================================
if (Get-Command clasp -CommandType Application -ErrorAction SilentlyContinue) {
    function clasp {
        $exe = (Get-Command clasp -CommandType Application -ErrorAction SilentlyContinue |
                Select-Object -First 1).Source
        if ($args[0] -eq 'push') {
            & $exe push --force ($args[1..($args.Length - 1)])
        } else {
            & $exe @args
        }
    }
}

# ============================================================
# Local overrides (.ps1 files in ~/dotfiles/.ps1/ or ~/.ps1/)
# ============================================================
$_localDir = "$HOME\dotfiles\.ps1"
if (Test-Path $_localDir) {
    Get-ChildItem "$_localDir\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
}
Remove-Variable _localDir

# ============================================================
# Starship prompt
# ============================================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
