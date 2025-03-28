# Flutter 3 写真アプリ

オーバーレイ撮影機能と透過PNG作成機能を備えたFlutter 3写真アプリです。

## 機能

- 通常写真撮影
- オーバーレイ写真撮影
  - 透過PNG画像をオーバーレイとして追加
  - 画像の移動、回転、拡大縮小
- 透過PNG作成
  - 2枚の画像から差分を抽出して透過PNGを生成
- ギャラリー機能
  - 撮影した写真の管理
  - 写真の共有と削除

## 技術スタック

- Flutter 3
- Flutter Riverpod（状態管理）
- Clean Architectureパターン
- Cameraパッケージ
- Image処理パッケージ

## プロジェクト構造

```
lib/
├── main.dart                 # アプリケーションのエントリーポイント
├── dependency_injection.dart   # 依存関係注入設定
├── app/                      # アプリケーション全体の設定
│   ├── app.dart              # MaterialAppの設定
│   └── routes.dart           # ルート定義
├── core/                     # コア機能
│   ├── error/                # エラー処理
│   ├── utils/                # ユーティリティ関数
│   └── constants/            # 定数定義
├── domain/                   # ドメイン層
│   ├── entities/             # エンティティモデル
│   ├── repositories/         # リポジトリインターフェース
│   └── usecases/             # ユースケース
├── data/                     # データ層
│   ├── repositories/         # リポジトリ実装
│   ├── datasources/          # データソース
│   └── models/               # データモデル
└── presentation/            # プレゼンテーション層
    ├── providers/           # Riverpodプロバイダー
    ├── screens/             # 画面
    └── widgets/             # 再利用可能なウィジェット
```

## 実行方法

1. Flutter 3以上をインストールしてください
2. リポジトリをクローンします

```bash
git clone https://github.com/eidas/flutter-photo-app.git
cd flutter-photo-app
```

3. 依存関係をインストールします

```bash
flutter pub get
```

4. アプリを実行します

```bash
flutter run
```

## 注意事項

- このアプリはカメラとギャラリーの権限を必要とします
- 実機またはカメラ機能のあるエミュレータで実行してください
