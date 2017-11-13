load cv_data.mat

class_num = 15;

test_index = randperm(40,10)';
train_index = (1:40)';
train_index(test_index) = [];
test_set = [];
train_set = [];

for i = 1:class_num
    test_set = [test_set; test_index+40*(i-1)];
    train_set = [train_set; train_index+40*(i-1)];
end

training_X = sequences(train_set);
testing_X = sequences(test_set);
training_Y = labels(train_set);
testing_Y = labels(test_set);

%% sort the data
numObservations = numel(training_X);
for i=1:numObservations
    sequence = training_X{i};
    sequenceLengths(i) = size(sequence,2);
end
[sequenceLengths,idx] = sort(sequenceLengths);
training_X = training_X(idx);
training_Y = training_Y(idx);

%% define the LSTM network
inputSize = 10;
outputSize = 100;
outputMode = 'last';
numClasses = 15;

layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(outputSize,'OutputMode',outputMode)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

%% training settings
maxEpochs = 150;
miniBatchSize = 30;
shuffle = 'never';

options = trainingOptions('sgdm', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'Shuffle', shuffle);

%% train the network
net = trainNetwork(training_X,training_Y,layers,options);

%% testing 
numObservationsTest = numel(testing_X);
for i=1:numObservationsTest
    sequence = testing_X{i};
    sequenceLengthsTest(i) = size(sequence,2);
end
[sequenceLengthsTest,idx] = sort(sequenceLengthsTest);
testing_X = testing_X(idx);
testing_Y = testing_Y(idx);

miniBatchSize = 30;
YPred = classify(net,testing_X, ...
    'MiniBatchSize',miniBatchSize);

% compute accuracy
acc = sum(YPred == testing_Y)./numel(testing_Y)
