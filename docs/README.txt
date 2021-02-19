# OCTイメージからの脈絡膜層の抽出と脈絡膜厚マップの作成
## 制作者
辻真伍（m161089@fmu.ac.jp）

## 概要
OCT画像を取り込み，脈絡膜層を抽出する。その後平滑化スプラインをかけて脈絡膜厚マップの作成を行う.
- 入力：tif画像 (.tif)とそのGroundTruthラベル画像 (.png)．元画像はFileというフォルダー内にいれ、ラベル画像はPixelLabelDataというフォルダー内に入れる．
PixelLabelDataはFileフォルダー内に入れておく.
- 出力1：転移学習によりパラメータが変更されたSegNet
- 出力2：平滑化スプラインがかけられた脈絡膜厚マップ
- 出力3：平滑化スプラインがかけられた脈絡膜のマスクデータ

## 利用環境
このスクリプトはMATLAB2019a, Windows10Proで動作を確認しています．

## 実行手順 
step1_training_network.m
- 'File'にラベリングに用いた元画像を.tif形式で入れる.
- 'File'フォルダー内に'PixelLabelData'というフォルダーを作りそこにラベリングした際にイメージラベラー等で作成したラベリング画像を.png形式で入れる.
- スクリプトを実行する.

step2_smoothing_spline.m
- コマンドウインドウにstep2_smoothing_spline(folder,net,OrgvolSize)を入力し、実行する.
--folderには.img形式の3次元的なOCT画像が入ったフォルダーを指定する.
--netにはstep1_training_network.mで出力されたネットワークあるいは既存のMathWorksのアドオン等で得られるネットワークを指定する.
--OrgvolSizeにはOCTボリュームの大きさを指定する. PLEX Elite の 6×6 OCTA Cube でスキャンされた.imgファイルであったときOrgvolSizeは[1536 500 500]となる.

## Set Parameters (主要なパラメータのみ)

step1_training_network.m
- imageSize(Line 39): 入力層のイメージサイズを指定する.
- trainingRatio(Line 49): データセット全体における学習に用いるデータの割合を指定する (残りはテストに用いることになる). 
- InitialLearnRate(Line 80): 学習開始時点の学習率を指定する.
- MaxEpochs(Line 82): 学習する際の最大のエポック数を指定する.
- MiniBatchSize(Line 83): ミニバッチサイズを指定する.
- idx(Line 104): 検証するテストイメージの番号を指定する.

step2_smoothing_spline.m
- volSize(Line 46): 解析を行うOCTボリュームのサイズを指定する.
- smoothingparameter(Line 123, 1208): 3次平滑化スプラインを行う際の平滑化パラメータを指定する. 