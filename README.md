# dotfiles

macOS + zsh 向けの個人設定ファイル群。シンボリックリンク方式で管理。

## 前提条件

- macOS
- zsh
- git

## インストール

```shell
cd ~/dotfiles && bash ./install.sh
```

`install.sh` は以下を実行する：

1. git / Homebrew / gh CLI の存在確認（未インストールの場合は自動インストール）
2. 各設定ファイルのシンボリックリンクを `~` に作成
3. `~/.zshrc` をリロード

## 含まれる設定ファイル

| ファイル | 概要 |
|---|---|
| `.zshrc` | zsh メイン設定。エイリアス・関数・パス設定など |
| `.gitconfig` | Git のグローバル設定 |
| `.vimrc` | Vim 設定 |
| `.vimrc_vs` | VSCode 向け Vim 設定 |
| `.claude/settings.json` | Claude Code の設定（hooks, モデル, 権限）|
| `.claude/CLAUDE.md` | Claude Code へのグローバル指示 |
| `.claude/commands/` | Claude Code カスタムコマンド |
| `.claude/statusline-command.sh` | Claude Code ステータスライン スクリプト |

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

## `.zsh/` ディレクトリ

ローカル専用の追加設定を置く場所（git 管理外）。
`~/.zshrc` から `source ~/.zsh/*.zsh` のように読み込むことで環境ごとの差分設定が可能。
