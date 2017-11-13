%% path setting
Source_Path = '/Users/gongzhihao/Desktop/code/NN_usage/LSTM';
Sound_data_path = '/Users/gongzhihao/Desktop/code/NN_usage/sound_data';

Training_classes = textread([Source_Path,'/Training_classes.txt'],'%s');
[class_num,~] = size(Training_classes);

%% variable setting 
selector = [1,0,0,0,0];
labels = [];
sequences = {};

%% take sound data
for i=1:class_num
    fileFolder=fullfile([Sound_data_path, '/', Training_classes{i}]);
    dirOutput=dir(fullfile(fileFolder,'*.ogg'));
    file_names = {dirOutput.name}';
    
    [file_num,~] = size(file_names);
    label = categorical(repmat({num2str(i)},[file_num,1]));
    labels = [labels; label];
    squence = cell(file_num,1);
    
    for j=1:file_num
        [signal,sr] = audioread([Sound_data_path, '/', Training_classes{i}, '/', file_names{j}]);
        signal = signal(:,1);
        % compute features
        feature_seq = feature_extraction_for_LSTM(selector,signal,sr);
        squence(j,1) = {feature_seq};
    end
    
    sequences = [sequences; squence];
    display([Training_classes{i},' done']); 
end

save([Source_Path,'/cv_data.mat'],'labels','sequences');



    