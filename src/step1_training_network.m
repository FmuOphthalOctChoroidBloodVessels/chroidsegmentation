%% Image Segmentation Using SegNet

clear all, close all, clc;

%% Setup

vgg19();

%% Create Image DataStore

imgDir = fullfile(pwd,'File');
imds = imageDatastore(imgDir);

%% Create Label Ground Truth in a Collection of Images

reconstruct_label

%% PixelLabel
classes = [
    "Background"
    "Choroid"
    ];

pixelLabelID = cell(2,1);
pixelLabelID{1,1} = [2;0];
pixelLabelID{2,1} = 1;

%% PixelLabel DataStore

labelDir = fullfile(imgDir,'PixelLabelData');
pxds = pixelLabelDatastore(labelDir,classes,pixelLabelID);

%% Count pixels in each label

tbl = countEachLabel(pxds)

%% Resize Images

imageSize = [250 500 3];

imageFolder = fullfile(imgDir,'imagesReszed',filesep);
imds = resizeImages(imds,imageFolder,[imageSize(1),imageSize(2)]);

labelFolder = fullfile(imgDir,'labelsResized',filesep);
pxds = resizeLabels(pxds,labelFolder,[imageSize(1),imageSize(2)]);

%% Prepare Training and Test Sets

trainingRatio=0.8;

[imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionDataset(imds,pxds,trainingRatio);
numTrainingImages = numel(imdsTrain.Files)
numTestingImages = numel(imdsTest.Files)

%% Create the Network

numClasses = numel(classes);
lgraph = segnetLayers(imageSize,numClasses,'vgg19');

%% Balance Classes Using Class Weighting

imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq

%% Reflect Weighting on pixelClassificationLayer

pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tbl.Name, 'ClassWeights', classWeights)

%% Update SegNet

lgraph = removeLayers(lgraph, 'pixelLabels');
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph, 'softmax' ,'labels');
figure, plot(lgraph)

%% Select Training Options

options = trainingOptions('sgdm', ...
    'Momentum', 0.9, ...
    'InitialLearnRate', 1e-2, ...
    'L2Regularization', 0.0005, ...
    'MaxEpochs', 4, ...  
    'MiniBatchSize', 1, ...
    'Shuffle', 'every-epoch', ...
    'Plots','training-progress', ...
    'VerboseFrequency', 1000);

%% Data Augmentation

augmenter = imageDataAugmenter('RandXReflection',true,'RandYReflection',true,...
    'RandXTranslation', [-imageSize(1)/2 imageSize(1)/2], 'RandYTranslation', [-imageSize(2)/2 imageSize(2)/2], 'RandRotation', [-45 45]);

%% Start Training
datasource = pixelLabelImageSource(imdsTrain,pxdsTrain,...
   'DataAugmentation',augmenter);

modelDatetime=datestr(now,'yyyy-mm-dd');
[net, info] = trainNetwork(datasource,lgraph,options);
save(['trained-SegNet',modelDatetime],'net');
%% Test Network on One Image

cmap=[0.7529,0,0;0,0,0.7529];

idx = 1;
I = readimage(imdsTest,idx);
C = semanticseg(I, net);
B = labeloverlay(I, C, 'Colormap', cmap, 'Transparency',0.4);
figure,imshowpair(I, B, 'montage')
pixelLabelColorbar(cmap, classes);
expectedResult = readimage(pxdsTest,idx);
actual = uint8(C);
expected = uint8(expectedResult);
figure,imshowpair(actual, expected)

%% Dice

Dice=zeros([2,numTestingImages]);

for n=1:numTestingImages

    idx = n;
    
    I = readimage(imdsTest,idx);
    C = semanticseg(I, net);
    
    expectedResult = readimage(pxdsTest,idx);
    
   Dice(:,n)=dice(C,expectedResult);
   
end

Dice=transpose(Dice);

%% Evaluate Trained Network 

pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

%% DataSetMetrics

metrics.DataSetMetrics
%% Class Metrics

metrics.ClassMetrics