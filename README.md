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
| `.vimrc_vs` | VSCode 向け Vim 設定 |
| `.config/nvim/init.lua` | Neovim エントリポイント（オプション・キーマップのみ） |
| `.config/nvim/lua/plugins/` | プラグイン設定（editor / ui / telescope / lsp / completion / formatting / treesitter） |
| `.claude/settings.json` | Claude Code の設定（hooks, モデル, 権限）|
| `.claude/CLAUDE.md` | Claude Code へのグローバル指示 |
| `.claude/commands/` | Claude Code カスタムコマンド |
| `.claude/statusline-command.sh` | Claude Code ステータスライン スクリプト |
| `Brewfile` | Homebrew パッケージ一覧（macOS / WSL） |
| `Aptfile` | apt パッケージ一覧（Linux） |
| `.git-hooks/pre-commit` | シークレット誤コミット防止フック |
| `test/bootstrap-check.sh` | bootstrap 検証スクリプト |
| `Dockerfile.test` | コンテナでの bootstrap テスト |

## `.env` の設定方法（デュアル Git アカウント）

`~/dotfiles/.env` を作成し、以下の変数を定義する（git 管理外）：

```shell
MAIN_GIT_USER=your-main-github-username
MAIN_GIT_EMAIL=your-main@email.com
SUB_GIT_USER=your-sub-github-username
SUB_GIT_EMAIL=your-sub@email.com
```

`.zshrc` 内の `gmain` / `gsub` 関数でアカウントを切り替えられる：

```shell
gmain   # メインアカウントに切り替え
gsub    # サブアカウントに切り替え
```

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
