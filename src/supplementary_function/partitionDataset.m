function [imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionDataset(imds,pxds,trainingRatio)
% Partition Blood Smear Images by randomly selecting 95% of the data for training. The
% rest is used for testing.
    
% Set initial random state for example reproducibility.
rng(15); 
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use (trainingRatio * 100) % of the images for training.
N = round(trainingRatio * numFiles);
trainingIdx = shuffledIndices(1:N);

% Use the rest for testing.
testIdx = shuffledIndices(N+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
testImages = imds.Files(testIdx);
imdsTrain = imageDatastore(trainingImages);
imdsTest = imageDatastore(testImages);

% Extract class and label IDs info.
classes = pxds.ClassNames;
labelIDs = 1:numel(pxds.ClassNames);

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
testLabels = pxds.Files(testIdx);
pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
end