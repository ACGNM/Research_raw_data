Source_Path = '/Users/gongzhihao/Desktop/code/NN_usage';
Sound_data_path = '/sound_data';
Image_path = '/bin_source';
Image_path2 = '/color_source';
Training_classes = textread([Source_Path,'/Training_classes.txt'],'%s');

[class_num,~] = size(Training_classes);
sample_length = 132300;
map = parula();
L = size(map,1);

%% fixing szie
% min_y = 274;

%% generate image data
for i=1:class_num
    
    fileFolder=fullfile([Source_Path, Sound_data_path, '/', Training_classes{i}]);
    dirOutput=dir(fullfile(fileFolder,'*.ogg'));
    file_names = {dirOutput.name}';
    
    [file_num,~] = size(file_names);
    for j=1:file_num
        
        %% gammatone filter
        [d,sr] = audioread([Source_Path, Sound_data_path, '/', Training_classes{i}, '/', file_names{j}]);
        d = d(1:sample_length,1);
        [D,F] = gammatonegram(d,sr);
        tem = 20*log10(D);
        tem(tem==-Inf) = min(tem(tem~=-Inf));
        
        
        %% save binary image
%         bin_img = Binary_Wellner(D);
%         bin_img = bin_img(:,1:274);
%%%%%%%%%%%ÅÐ¶Ï½á¹û³ß´ç%%%%%%%%%%%%%%%%%%%%%%%
        
        if size(D,2)>=298
            bin_img = tem(:,25:298);
        end
%         
%         [x,y] = size(bin_img);
%         if x~=64 || y~=298
%             display([Training_classes{i}, '/', file_names{j}]);
%             if y<min_y
%                 min_y = y;
%             end
%         end
        if ~exist([Source_Path, Image_path2, '/', Training_classes{i}]) 
            mkdir([Source_Path, Image_path2, '/', Training_classes{i}]) 
        end 
        % Scale the matrix to the range of the map.
        Gs = round(interp1(linspace(min(bin_img(:)),max(bin_img(:)),L),1:L,bin_img));
        H = reshape(map(Gs,:),[size(Gs) 3]); % Make RGB image from scaled.
        imwrite(H, map, [Source_Path, Image_path2, '/', Training_classes{i}, '/', file_names{j}, '.png']);
        
    end
    display([Training_classes{i},' done']);
end


