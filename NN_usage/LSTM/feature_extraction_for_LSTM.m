function feature_seq = feature_extraction_for_LSTM(selector,signal,sr)

feature_seq = [];

%% parameters of STFT
win = 256; 
window = hamming(win);
noverlap = 128;
nfft = 1024;

Pxx = spectrogram(signal,window,noverlap,nfft,sr,'yaxis');
logPxx = 10*log10(abs(Pxx)+eps);

%% binarization
result = Binary_Wellner(logPxx);
result = bwareaopen(result,10);

%% segmentation
[X,Y] = size(result);
time_step = 20;
fre_step = 50; % 2150Hz
mean_standard = fre_step/2;
iter_time = floor(Y/time_step);
iter_fre = floor(X/fre_step);

%% feature extraction
for iter_t = 1:iter_time
    
    feature_col = [];
    
    for iter_f = 1:iter_fre
        [block_matrix,blob_cell] = blob_separation(result(fre_step*(iter_f-1)+1:fre_step*iter_f,...
            time_step*(iter_t-1)+1:time_step*iter_t));
        STATS = regionprops(block_matrix,'Centroid','Area','Extent');
        
        block_num = length(STATS);
        if block_num>0 
            areas = [STATS(:).Area];
            % persentages = [STATS(:).Area];
            threshold_area = median(areas)*0.03; % ÖĞÎ»Êı
            idx = find(areas>threshold_area);
        end
        
        % centeral frequency statistics
        if selector(1) == 1
            if block_num>0
                pos = [STATS(:).Centroid];
                fre_pos = pos(2:2:block_num*2);
%                 fre_feature(1,1) = mean(fre_pos(idx))-mean_standard;
%                 fre_feature(2,1) = std(fre_pos(idx));
                feature = std(fre_pos(idx))/mean(fre_pos(idx));
                feature_col = [feature_col; feature];
            else
%                 fre_feature(1,1) = -mean_standard;
%                 fre_feature(2,1) = 0;
                feature = 0;
                feature_col = [feature_col; feature];
            end
        end
        
        % length statistics
        if selector(2) == 1
            
        end
        
        % width statistics
        if selector(3) == 1
            
        end
        
        % gap statistics
        if selector(4) == 1
            
        end
        
        % block number
        if selector(5) == 1
            
        end
        
        
    end
    
    feature_seq = [feature_seq,feature_col];
    
end

end