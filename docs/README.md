# このプロジェクトが行うこと
- 脈絡膜層の抽出：機械学習を用いた画像処理技術による脈絡膜層の領域分割（cf. [Kei Otsuka., 2021](https://www.mathworks.com/matlabcentral/fileexchange/66448-medical-image-segmentation-using-segnet)）
- 脈絡膜層の平滑化：3次平滑化スプラインを用いた脈絡膜層の平滑化（cf. [csaps](https://jp.mathworks.com/help/curvefit/csaps.html)）
- 脈絡膜層厚マップの作成：脈絡膜層厚のヒートマップを用いた可視化（cf. [Fheng Fang et al., 2016](https://iovs.arvojournals.org/article.aspx?articleid=2586083)）（cf. [Rueden, Curtis T et al., 2017](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-017-1934-z)）

# このプロジェクトが有益な理由
脈絡膜を3次元再構築することにより，脈絡膜の立体構造を把握し、肥厚や菲薄化などの局所的な形態変化をとらえることが可能となり、また数理的解析も行うことができます.

# このプロジェクトの使い始め方
## 利用環境
このスクリプトはMATLAB2019a，Windows10Proで動作を確認しています．

## OCTイメージからの脈絡膜層の抽出と脈絡膜厚マップの作成
### 概要
OCT画像を取り込み，脈絡膜層を抽出する。その後平滑化スプラインをかけて脈絡膜厚マップの作成を行います.
- 入力：tif画像 (.tif)とそのGroundTruthラベル画像 (.png)．元画像はFileというフォルダー内にいれ、ラベル画像はPixelLabelDataというフォルダー内に入れます．
PixelLabelDataはFileフォルダー内に入れておきます.
- 出力1：転移学習によりパラメータが変更されたSegNet
- 出力2：平滑化スプラインがかけられた脈絡膜厚マップ
- 出力3：平滑化スプラインがかけられた脈絡膜のマスクデータ
### 実行手順 
- step1_training_network.m
	- 'File'にラベリングに用いた元画像を.tif形式で入れます.
	- 'File'フォルダー内に'PixelLabelData'というフォルダーを作りそこにラベリングした際にイメージラベラー等で作成したラベリング画像を.png形式で入れます.
	- スクリプトを実行します.
- step2_smoothing_spline.m
	- コマンドウインドウにstep2_smoothing_spline(folder,net,OrgvolSize)を入力し、実行します.
	- folderには.img形式の3次元的なOCT画像が入ったフォルダーを指定します.
	- netにはstep1_training_network.mで出力されたネットワークあるいは既存のMathWorksのアドオン等で得られるネットワークを指定します.
	- OrgvolSizeにはOCTボリュームの大きさを指定する. PLEX Elite の 6×6 OCTA Cube でスキャンされた.imgファイルであったときOrgvolSizeは[1536 500 500]となります.
### Set Parameters (主要なパラメータのみ)
- step1_training_network.m
	- imageSize(Line 39): 入力層のイメージサイズを指定します.
	- trainingRatio(Line 49): データセット全体における学習に用いるデータの割合を指定します (残りはテストに用いることになります). 
	- InitialLearnRate(Line 80): 学習開始時点の学習率を指定します.
	- MaxEpochs(Line 82): 学習する際の最大のエポック数を指定します.
	- MiniBatchSize(Line 83): ミニバッチサイズを指定します.
	- idx(Line 104): 検証するテストイメージの番号を指定します.
- step2_smoothing_spline.m
	- volSize(Line 46): 解析を行うOCTボリュームのサイズを指定します.
	- smoothingparameter(Line 123, 1208): 3次平滑化スプラインを行う際の平滑化パラメータを指定します. 

# このプロジェクトに関するヘルプをどこで得るか
* バグ報告・ご要望などは[issue](https://github.com/FmuOphthalOctChoroidBloodVessels/chroidsegmentation/issues)にて受け付けております．
* ご質問は管理者（m161089@fmu.ac.jp）までご連絡ください．

# 引用
このソフトウェアを使った研究を学術文献として発表する場合は以下の文献を引用していただけると大変うれしいです
- Tsuji, Shingo, Tetsuju Sekiryu, Yukinori Sugano, Akira Ojima, Akihito Kasai, Masahiro Okamoto, and Satoshi Eifuku. 2020. “Semantic Segmentation of the Choroid in Swept Source Optical Coherence Tomography Images for Volumetrics.” Scientific Reports 10 (1): 1088.
- Sekiryu, Tetsuju, Yukinori Sugano, Akira Ojima, Takafumi Mori, Minoru Furuta, Masahiro Okamoto, and Satoshi Eifuku. 2019. “Hybrid Three-Dimensional Visualization of Choroidal Vasculature Imaged by Swept-Source Optical Coherence Tomography.” Translational Vision Science & Technology 8 (5): 31.

# このプロジェクトのメンテナンス者とコントリビューター
このプロジェクトのソースコードは以下の者が作成しました．
- 辻真伍（m161089@fmu.ac.jp）：作成，保守








