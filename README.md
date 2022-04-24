# dagger_test
Daggerで環境構築　＆　デプロイ

## Dagger
`cd my-app`
### ビルド
`dagger do build`
### ローカルで確認
`open _build/index.html`

### テスト単体(ビルド時にも走っている)
`dagger do test`

## Actionsのテスト
`node:12-buster-slim`で実行されると docker でエラーになるので ubuntuを指定する。
`docker pull nektos/act-environments-ubuntu:18.04`
`act -P ubuntu-18.04=nektos/act-environments-ubuntu:18.04`

CF. [Githhub Actionsをローカルで実行するnectos/actでcommand not foundが出たときの対処法](https://www.rasukarusan.com/entry/2021/01/27/224725)
[nektos/act](https://github.com/nektos/act)

# TODO
package.jsonにhomepage直書きしているのを直す。
