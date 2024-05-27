# Run Anywhere
[![Build and Release iOS App](https://github.com/atahatah/run-gpu-anywhere/actions/workflows/deploy-ios.yml/badge.svg)](https://github.com/atahatah/run-gpu-anywhere/actions/workflows/deploy-ios.yml)

このプログラムはスマホ上からSSHで接続し，テンプレートを基に簡単にプログラムを実行するアプリです．

## 実行方法
次のコマンドを実行することで実際にプログラムを実行することができます．
ただし，SSH接続が必要なため，Webでは実行できません．
```sh
git clone https://github.com/atahatah/run-gpu-anywhere
cd run-gpu-anywhere
flutter pub get
dart run build_runner build 
flutter run
```