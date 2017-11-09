%for i=1:30

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

imagesc(logPxx);

result = Binary_Wellner(logPxx);
result = bwareaopen(result,10);

figure();
imshow(result);

% spectrogram(y1,window,noverlap,nfft,fs,'yaxis');


% %//////////////////////4月26日_统计//////////////////////////
% [fre,time] = size(result);
% count_matrix = zeros(fre,fre,time);
% start_fre = 0;
% 
% for i=1:time
%     fre_seq = find(result(:,i));
%     if ~isempty(fre_seq)
%     point_num = length(fre_seq);
%     if point_num>=2
%     point_count = 1;
%     start_fre = fre_seq(1);
%     for j = 1:point_num-1
%         gap = fre_seq(j+1) - fre_seq(j);
%         if gap<=5 && j~=point_num-1
%             point_count = point_count+gap;
%         elseif gap>5 && j~=point_num-1
%             count_matrix(start_fre,point_count,i) = 1;
%             start_fre = fre_seq(j+1);
%             point_count = 1;
%         elseif gap<=5 && j==point_num-1
%             point_count = point_count+gap;
%             count_matrix(start_fre,point_count,i) = 1;
%         else
%             count_matrix(start_fre,point_count,i) = 1;
%             count_matrix(fre_seq(j+1),1,i) = 1;
%         end
%     end
%     end
%     count_matrix(fre_seq(1),1,i) = 1;
%     end
% end
% 
% 
% number = length(find(count_matrix));
% Z = [];
% X = [];
% Y = [];
% 
% for i = 1:time
%     [x,y] = find(count_matrix(:,:,i));
%     X = [X;x];
%     Y = [Y;y];
%     z = zeros(length(x),1)+i;
%     Z = [Z;z];
% end
% 
% figure('color','white');
% scatter3(X,Y,Z,2);
% set(gca,'xlim',[0 513]);
% set(gca,'XTick',0:102.6:513);
% set(gca,'xticklabel',0:4410:22050);
% xlabel('Frequence (Hz)');
% set(gca,'ylim',[0 513]);
% set(gca,'yticklabel',0:100:500);
% ylabel('count');
% set(gca,'zlim',[0 1032]);
% set(gca,'ZTick',0:206.4:1032);
% set(gca,'zticklabel',0:0.6:3);
% zlabel('time (s)');




%//////////////////////声音生成////////////////////////////
% fs_half = double(fs/2);
% 
% f_num = double(nfft/2);
% f1 = zeros(f_num+1,1);
% for i = 1:f_num+1
%     f1(i,1) = (fs_half/f_num)*(i-1);
% end
% 
% segment2 = floor((N-noverlap)/(win-noverlap));
% win = win-noverlap;
% re_sound = zeros(1,segment2*win);
% 
% for i=1:segment2
%     array_noze = find(result(:,i));
%     array_len = length(array_noze);
%     for j=1:array_len
%         if f1(array_noze(j),1)<40000
%         count = 1:win;
%         re_sound(1,(i-1)*win+1:i*win) = re_sound(1,(i-1)*win+1:i*win)+(abs_Pxx(array_noze(j),i)/(nfft/20))*cos(2*pi*f(array_noze(j),1)*count+atan(imag(s(array_noze(j),i))/real((s(array_noze(j),i)))));
%         end
%     end
% end
% 
% 
% 
% re_sound = re_sound-mean(re_sound,2);
% 
% sound(re_sound,fs);

%re_sound=re_sound/2; %avoid to be clipped
%audiowrite('.1.wav',re_sound,fs);

%//////////////////分水岭//////////////////////////
% D = bwdist(~result);
% 
% D = -D;
% D(~result) = Inf;
% 
% L = watershed(D,8);
% L(~result) = 0;
% rgb = label2rgb(L,'jet',[.5 .5 .5]);
% figure();
% imshow(rgb,'InitialMagnification','fit');
% title('Watershed transform of D');

%/////////////////超像素分割/////////////////////
% A = imread('spec4.png');
% 
% 
% [L,N] = superpixels(A,500,'method','slic');
% 
% figure
% BW = boundarymask(L);
% imshow(imoverlay(A,BW,'cyan'),'InitialMagnification',60)


% [L,N] = superpixels(im.CData,500);
% 
% figure
% BW = boundarymask(L);
% imshow(imoverlay(im.CData,BW,'cyan'),'InitialMagnification',67);
%end