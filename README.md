# dotfiles

macOS + zsh 向けの個人設定ファイル群。シンボリックリンク方式で管理。

## 前提条件

- macOS / Linux (Ubuntu 22.04+) / WSL2
- zsh
- git

## インストール

```shell
cd ~/dotfiles && bash ./install.sh
```

`install.sh` は以下を実行する（冪等・macOS/Linux 対応）：

1. OS を自動検出（macOS / WSL2 / Linux）
2. git / Homebrew / gh CLI / oh-my-zsh の存在確認（未インストールの場合は自動インストール）
3. git hooks パスを `.git-hooks/` に設定（シークレット誤コミット防止）
4. 各設定ファイルのシンボリックリンクを `~` に作成
5. `.claude/settings.json` が未存在の場合、sample から自動コピー
6. Brewfile / Aptfile からパッケージをインストール

## 含まれる設定ファイル

| ファイル | 概要 |
|---|---|
| `.zshrc` | zsh メイン設定。Starship プロンプト・エイリアス・関数など |
| `.gitconfig` | Git のグローバル設定（delta / rerere / histogram diff） |
| `.vimrc` | Vim 設定 |
| `.vimrc_vs` | VSCodeVim から `vim.vimrc.path` で読み込まれる Vim 設定 |
| `.config/Code/User/settings.json` | VSCode ユーザー設定（OS ごとの宛先に symlink） |
| `.config/Code/User/keybindings.json` | VSCode キーバインド |
| `.claude/settings.json` | Claude Code の設定（hooks, モデル, 権限）|
| `.claude/CLAUDE.md` | Claude Code へのグローバル指示 |
| `.claude/commands/` | Claude Code カスタムコマンド |
| `.claude/statusline.py` (macOS/Linux) / `.claude/statusline-command.ps1` (Windows) | Claude Code ステータスライン |
| `Brewfile` | Homebrew パッケージ一覧（macOS / WSL） |
| `Aptfile` | apt パッケージ一覧（Linux） |
| `.git-hooks/pre-commit` | シークレット誤コミット防止フック |
| `test/bootstrap-check.sh` | bootstrap 検証スクリプト |
| `Dockerfile.test` | コンテナでの bootstrap テスト |

## Git identity（マシンごと）

`.gitconfig` に `[user]` は **書かない**。`[include] path = ~/.gitconfig.local` だけを持ち、実際の `name` / `email` はマシンごとに `~/.gitconfig.local`（git 管理外）で設定する：

```ini
; ~/.gitconfig.local
[user]
    name = your-name
    email = your@email.com
```

`install.sh` / `install.ps1` が初回実行時に空の `~/.gitconfig.local` を生成するので、そこに identity を書き込んでから commit する。未記入だと `git commit` が "Please tell me who you are" で失敗するので、誤った identity でコミットしてしまう事故を防げる。

個人 Mac には `satory074`、仕事 PC には work アカウントの identity を、それぞれの `~/.gitconfig.local` に書く。

## Claude Code 設定のセットアップ

`.claude/settings.json` は `.gitignore` で除外されているためサンプルからコピーして使う：

```shell
cp ~/dotfiles/.claude/settings.json.sample ~/dotfiles/.claude/settings.json
```

Discord 通知を使う場合は `YOUR_DISCORD_WEBHOOK_URL` を実際の Webhook URL に置き換える。

## プロンプト（Starship）

`.zshrc` は [Starship](https://starship.rs/) をプロンプトとして使用する。
Starship は `brew install starship`（macOS/WSL）または `cargo install starship`（Linux）でインストールできる。

カスタマイズは `~/.config/starship.toml` に記述する。デフォルト設定でも十分機能する。

## `.zsh/` ディレクトリ（ローカル専用設定）

マシン固有の設定を置く場所（git 管理外）。`.zshrc` 末尾で自動読み込みされる。

```zsh
# 例: ~/.zsh/work.zsh
export COMPANY_API_KEY="..."
alias vpn='sudo openfortivpn work.example.com'
```

ファイルを作成するだけで反映される（`source ~/.zshrc` が必要）。

## テスト

```bash
# bootstrap の最小チェック（git / ファイル存在確認）
DOTFILES=~/dotfiles bash ~/dotfiles/test/bootstrap-check.sh

# コンテナでフル bootstrap テスト（Docker 必要）
docker build -f Dockerfile.test -t dotfiles-test .
docker run --rm dotfiles-test
```
