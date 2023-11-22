# Diskoord
## 実験環境
#### VM1
- Locust-2.12.1
- locustfile.py
#### VM2
- WordPress v6.1.1
- WooCommerce v7.1.0(WordPressプラグイン)
- WooCommerce Stripe ゲートウェイ v7.0.1(WordPressプラグイン)
- backup.sh
- diskio.py
#### VM3
- バックアップファイルの転送先
## 作成したソフトウェア
### locustfile.py
VM2にあるwordpressサイトに対してリクエストを送ります．wordpressサイトにある商品の中からランダムな商品をランダムな個数購入するようにしています．商品番号やリクエスト先，購入処理の方法は自身の環境によって変更してください．
<br>
### caord.sh
VM2にあるバックアップファイルをVM3にrsyncを用いて転送します．iostatでディスク帯域幅使用率を取得し，その値に応じてrsyncでの転送サイズを制御します．バックアップ時間にもとづいて最低限転送するサイズを計算しrsyncでの転送サイズ制御の下限に設定します．
<br>
### dadlt.sh
VM1にあるlocustfile.pyを動かしながらiostatでディスク帯域幅使用率を取得します．ディスク帯域幅使用率を1秒ごとに差を取り最大値を算出します．
