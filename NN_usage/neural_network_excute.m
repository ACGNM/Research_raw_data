Source_Path = '/Users/gongzhihao/Desktop/code/NN_usage';
Image_path = '/color_source';

digitDatasetPath = fullfile([Source_Path, Image_path]);
digitData = imageDatastore(digitDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');

labelCount = countEachLabel(digitData)

%img = readimage(digitData,1);
%size(img)

trainNumFiles = 32;
[trainDigitData,valDigitData] = splitEachLabel(digitData,trainNumFiles,'randomize');

layers = [
    imageInputLayer([64 274 3])
    
    convolution2dLayer(3,16,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(4,'Stride',4)
    
    convolution2dLayer(3,32,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(4,'Stride',4)
    
    convolution2dLayer(3,64,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(4,'Stride',4)
    
    convolution2dLayer(3,128,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(15)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm',...
    'MaxEpochs',30, ...
    'ValidationData',valDigitData,...
    'ValidationFrequency',5,...
    'Verbose',false,...
    'Plots','training-progress');

net = trainNetwork(trainDigitData,layers,options);

save

predictedLabels = classify(net,valDigitData);
valLabels = valDigitData.Labels;

save('color_net','net');

accuracy = sum(predictedLabels == valLabels)/numel(valLabels)