[y1,fs] = audioread(['/Users/gongzhihao/Desktop/code/NN_usage/sound_data/Pouring_water/3-161500-A.ogg']);
y1 = y1(:,1);

N = length(y1);
win = 256;
window = rectwin(win);
noverlap = 128;
nfft = 1024;
time = double(length(y1)/fs);

%figure();
[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
logPxx = 10*log10(abs(Pxx)+eps);
abs_Pxx = abs(s);

%imagesc(logPxx);

result = Binary_Wellner(logPxx);
result = bwareaopen(result,10);
[X,Y] = size(result);

time_step = 170; %0.2s
fre_step = 50; %2150Hz
iter_time = floor(Y/time_step);
iter_fre = floor(X/fre_step);

%% sample
% BW = Binary_Wellner(D2);
% [block_matrix,blob_cell] = blob_separation(BW);
% 
% STATS = regionprops(block_matrix,'ConvexHull','Centroid');
% %STATS = regionprops(L,'ConvexHull','Centroid');
% 
% a = length(STATS);
% 
% figure();
% imshow(BW);
% axis on;
% hold on
% for i = 1:a
%     Draw_polygon(STATS(i).ConvexHull(:,1),STATS(i).ConvexHull(:,2));
%     %plot(STATS(i).Centroid(1),STATS(i).Centroid(2),'.','markersize',20);
% end
% hold off

%% extract feature
block_set = {};
count = 1;
for iter_t = 1:iter_time
    for iter_f = 1:iter_fre
        [block_matrix,blob_cell] = blob_separation(result(fre_step*(iter_f-1)+1:fre_step*iter_f,...
            time_step*(iter_t-1)+1:time_step*iter_t));
        block_set{count} = block_matrix;
        count = count + 1;
    end
end

time_positions = time_step+1:time_step:time_step*iter_time;
fre_positions = fre_step+1:fre_step:fre_step*iter_fre;
time_x_location = repmat(time_positions,[2 1]);
time_y_location = repmat([0;513],[1 iter_time-1]);
fre_x_location = repmat(fre_positions,[2 1]);
fre_y_location = repmat([0;1722],[1 iter_fre-1]);
                
figure();
imshow(result);
hold on
line(time_x_location,time_y_location, ...
        'Color','r', ...
        'LineStyle','--');
hold on
line(fre_y_location,fre_x_location, ...
        'Color','r', ...
        'LineStyle','--');
STATS = regionprops(block_set{14},'ConvexHull','Centroid');
%STATS = regionprops(L,'ConvexHull','Centroid');

a = length(STATS);

figure();
imshow(result(fre_step*3+1:fre_step*4,time_step+1:time_step*2));
axis on;
hold on
for i = 1:a
    Draw_polygon(STATS(i).ConvexHull(:,1),STATS(i).ConvexHull(:,2));
    %plot(STATS(i).Centroid(1),STATS(i).Centroid(2),'.','markersize',20);
end
hold off