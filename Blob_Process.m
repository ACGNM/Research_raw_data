class = 'cicada';
filename = [class,'-1'];
%[y1,fs] = audioread(['./sound/',class,'/',filename,'.wav']);
[y1,fs] = audioread(['./sound/',filename,'.wav']);
y1 = y1(:,1);
%c = cwt(y1,1:48,'db4','plot');

N = length(y1);
win = 256;
window = rectwin(win);
noverlap = 128;
nfft = 1024;
time = double(length(y1)/fs);
[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
%spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
logPxx = 10*log10(abs(Pxx)+eps);

%figure();
%plot(logPxx(:,20),'linewidth', 2);

result = Binary_Wellner(logPxx);
result = bwareaopen(result,3);
%result = imbinarize(result);
total = sum(result,1);

%result = result(1:200,1:100);
figure(2);
imshow(result);
axis on;


%find(result(:,1))


% %///////////////////////2017_05_30_分块/////////////////////////////
[fre,time] = size(result);
count_matrix = zeros(fre,fre,time); %计数结果，从哪开始，持续多长
start_fre = 0;

for i=1:time
    fre_seq = find(result(:,i));
    if ~isempty(fre_seq)
        point_num = length(fre_seq);
        if point_num>=2
            point_count = 1;
            start_fre = fre_seq(1);
            
            for j = 1:point_num-1
                %count_matrix(33,1,1)
                gap = fre_seq(j+1) - fre_seq(j);
                if gap<=10 && j~=point_num-1
                    point_count = point_count+gap;
                elseif gap>10 && j~=point_num-1
                    count_matrix(start_fre,point_count,i) = 1;
                    start_fre = fre_seq(j+1);
                    point_count = 1;
                elseif gap<=10 && j==point_num-1
                    point_count = point_count+gap;
                    count_matrix(start_fre,point_count,i) = 1;
                else
                    count_matrix(start_fre,point_count,i) = 1;
                    count_matrix(fre_seq(j+1),1,i) = 1;
                end
            end
        end
        %count_matrix(fre_seq(1),1,i) = 1;
    end
end
% 
% 
% %////////////////////////显示计数结果////////////////////////////
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
% 
spare_label = []; %空闲类标签
blob_cell = {}; %每一聚落中包含：1.时间序号 2.[起始频率，持续长度] 3.宽度 4.平均高度
block_matrix = zeros(fre,time);
cluster_label = 1;

pre_s_fre = 0;
pre_b_count = 0;
pre_b_num = 0;

for i = 1:time
    [s_fre,b_count] = find(count_matrix(:,:,i)); %s_fre->start_frequency b_count->block_count
    b_count = b_count-1;
    b_num = length(s_fre); %b_num->blob_number
    
    if b_num > 0
        
        if i==1 %第一列的情况
            
            for j=1:b_num
                block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = cluster_label;
                blob_cell{cluster_label,1} = i;
                blob_cell{cluster_label,2} = [s_fre(j),b_count(j)];
                blob_cell{cluster_label,3} = 1;
                blob_cell{cluster_label,4} = b_count(j);
                cluster_label = cluster_label+1;
            end
            
        else
            
            if ~isempty(find(count_matrix(:,:,i-1),1))  %前一列不为空
            
            
            
            for j=1:b_num
                
                bot_cirt = s_fre(j)-2; %下部临界值 bottom_critical
                up_cirt = s_fre(j)+b_count(j)+2; %上部临界值 up_critical
                up_values = pre_s_fre+pre_b_count; %前一列的上部终结位置
                up_satis = find(up_values>=bot_cirt); %上部终结位置大于下部临界的前一列元素编号
                bot_satis = find(pre_s_fre<=up_cirt); %下部开始位置小于上部临界的前一列元素编号
                left_blob_pos = intersect(up_satis,bot_satis); %上面两个元素编号的交集，即位于本块左边的块编号
                left_blob_num = length(left_blob_pos);
                if left_blob_num>0
                    for k=1:left_blob_num
                        left_tem_label = block_matrix(pre_s_fre(left_blob_pos(k)),i-1);%获取左边白块的编号
                        
                        %heig_diff = b_count(j)-1.5*blob_cell{left_tem_label,4};%当前线与左边类别的高度差
                        short_blob = min(b_count(j),pre_b_count(left_blob_pos(k)));
                        long_blob = max(b_count(j),pre_b_count(left_blob_pos(k)));
                        heig_diff = long_blob-1.5*short_blob;
                        
                        if blob_cell{left_tem_label,3} >= 20 && heig_diff>0
                            if isempty(spare_label)
                                block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = cluster_label;
                                blob_cell{cluster_label,1} = i;
                                blob_cell{cluster_label,2} = [s_fre(j),b_count(j)];
                                blob_cell{cluster_label,3} = 1;
                                blob_cell{cluster_label,4} = b_count(j);
                                cluster_label = cluster_label+1;
                            else
                                last_label = length(spare_label);
                                tem_label = spare_label(1);
                                block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = tem_label;
                                blob_cell{tem_label,1} = i;
                                blob_cell{tem_label,2} = [s_fre(j),b_count(j)];
                                blob_cell{tem_label,3} = 1;
                                blob_cell{tem_label,4} = b_count(j);
                                spare_label(1:last_label-1) = spare_label(2:last_label);
                                spare_label(last_label) = [];
                            end
                        else
                            
                            if k==1
                               block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = left_tem_label;
                               blob_cell{left_tem_label,1} = [blob_cell{left_tem_label,1},i];
                               blob_cell{left_tem_label,2} = [blob_cell{left_tem_label,2};s_fre(j),b_count(j)];
                               clu_wid = blob_cell{left_tem_label,3};
                               blob_cell{left_tem_label,3} = clu_wid+1;
                               blob_cell{left_tem_label,4} = (blob_cell{left_tem_label,4}*clu_wid+b_count(j))/(clu_wid+1);
                            elseif blob_cell{left_tem_label,3} <20 && heig_diff<0
                               curr_label = block_matrix(s_fre(j),i);
                               if (curr_label~=left_tem_label)
                               blob_cell{curr_label,1} = [blob_cell{curr_label,1},blob_cell{left_tem_label,1}];
                               blob_cell{curr_label,2} = [blob_cell{curr_label,2};blob_cell{left_tem_label,2}];
                               blob_cell{curr_label,3} = max(blob_cell{curr_label,3},blob_cell{left_tem_label,3});
                               %blob_cell{curr_label,4} = b_count(j); %高度暂时是线长度的均值，与相对位置无关，需要改善
                               
                               %将左边的附着于右边的小聚类变为当前右边的类标签
                               tem_wid = length(blob_cell{left_tem_label,1});   
                               for tem = 1:tem_wid
                                   tem_count = length(blob_cell{left_tem_label,2}(tem,:))/2;
                                   for tem2 = 1:tem_count
                                       block_matrix(blob_cell{left_tem_label,2}(tem,tem2):blob_cell{left_tem_label,2}(tem,tem2)+...
                                           blob_cell{left_tem_label,2}(tem,tem2+tem_count),...
                                           blob_cell{left_tem_label,1}(tem)) = curr_label;
                                   end
                               end
                               
                               %将左边的小类内容全变为空并且将这个标签放入空闲标签数列中
                               blob_cell{left_tem_label,1} = [];
                               blob_cell{left_tem_label,2} = [];
                               blob_cell{left_tem_label,3} = [];
                               blob_cell{left_tem_label,4} = [];
                               spare_label = [spare_label,left_tem_label];
                               end
                            end
                            
                        end
                            
                    end
                else
                    %再前一列 先不写
                    
                    %建立新类
                    if isempty(spare_label)
                       block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = cluster_label;
                       blob_cell{cluster_label,1} = i;
                       blob_cell{cluster_label,2} = [s_fre(j),b_count(j)];
                       blob_cell{cluster_label,3} = 1;
                       blob_cell{cluster_label,4} = b_count(j);
                       cluster_label = cluster_label+1;
                    else
                       last_label = length(spare_label);
                       tem_label = spare_label(1);
                       block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = tem_label;
                       blob_cell{tem_label,1} = i;
                       blob_cell{tem_label,2} = [s_fre(j),b_count(j)];
                       blob_cell{tem_label,3} = 1;
                       blob_cell{tem_label,4} = b_count(j);
                       spare_label(1:last_label-1) = spare_label(2:last_label);
                       spare_label(last_label) = [];
                     end
                end
            end
            
            else   %前一列为空
                
                %再前一列 先不写
                %都建立为新类
                for j=1:b_num
                    if isempty(spare_label)
                       block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = cluster_label;
                       blob_cell{cluster_label,1} = i;
                       blob_cell{cluster_label,2} = [s_fre(j),b_count(j)];
                       blob_cell{cluster_label,3} = 1;
                       blob_cell{cluster_label,4} = b_count(j);
                       cluster_label = cluster_label+1;
                    else
                       last_label = length(spare_label);
                       tem_label = spare_label(1);
                       block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = tem_label;
                       blob_cell{tem_label,1} = i;
                       blob_cell{tem_label,2} = [s_fre(j),b_count(j)];
                       blob_cell{tem_label,3} = 1;
                       blob_cell{tem_label,4} = b_count(j);
                       spare_label(1:last_label-1) = spare_label(2:last_label);
                       spare_label(last_label) = [];
                    end
                end
            end
            
        end
        
        pre_s_fre = s_fre;
        pre_b_count = b_count;
        pre_b_num = b_num;
        
    end
    
end

%/////////////////////////20170606_统计////////////////////////////////

% section_num = 50;
% fre_co = zeros(section_num);
% mean_time_gap = zeros(section_num,1);
% fre_gap = floor(fre/section_num);
% center_diff = floor(fre_gap/2);
% 
% 
% for s_num = 1:section_num
%     fre_co(s_num) = fre_gap*s_num-center_diff;
%     STATS = regionprops(block_matrix(1+fre_gap*(s_num-1):fre_gap*s_num,:),'Centroid');
%     block_num2 = length(STATS);
%     centroid = [];
%     for b_num = 1:block_num2
%         if ~isnan(STATS(b_num).Centroid(1,2))
%             centroid = [centroid;STATS(b_num).Centroid(1,1),STATS(b_num).Centroid(1,2)];
%         end
%     end
%     [block_num3,~] = size(centroid);
%     total_gap = 0;
%     gap_count = 1;
%     for b_num = 1:block_num3-1
%         time_gap = centroid(b_num+1,2)-centroid(b_num,2);
%         if time_gap > 3
%             total_gap = total_gap+time_gap;
%             gap_count = gap_count+1;
%         end
%     end
%     mean_time_gap(s_num) = total_gap/gap_count;
% end
% 
% max_fre_gap = ceil(max(mean_time_gap)/9)*9;
% 
% 
% figure();
% plot(fre_co,mean_time_gap,'color','r');
% ylabel('Time gap (s)','fontsize',12);
% %axis([0 max_fre_gap 0 22050]);
% %set(gca,'YTick',0:max_fre_gap/20:max_fre_gap);
% set(gca,'yticklabel',0:max_fre_gap/10*0.003:max_fre_gap*0.003);
% xlabel('Frequency (Hz)','fontsize',12);
% set(gca,'xticklabel',0:2205:22050);
% set(gcf,'color','white');
% 
% STATS2 = regionprops(block_matrix,'BoundingBox');
% [block_num2,~] = size(STATS2);
% height_array = zeros(block_num2,1);
% for temp_h = 1:block_num2
%     height_array(temp_h) = STATS2(temp_h).BoundingBox(4);
% end
% max_height = max(height_array);
% hei_sec_num = 15;
% mean_hei_gap = zeros(hei_sec_num,1);
% hei_co = zeros(hei_sec_num);
% hei_gap = floor(max_height/hei_sec_num);
% hei_cent_diff = floor(hei_gap);
% 
% for h_num = 1:hei_sec_num
%     hei_co(h_num) = h_num*hei_gap-hei_cent_diff;
%     hei_sati_pos1 = find(height_array>1+(h_num-1)*hei_gap);
%     hei_sati_pos2 = find(height_array<h_num*hei_gap);
%     hei_sati_pos = intersect(hei_sati_pos1,hei_sati_pos2);
%     hei_sati_num = length(hei_sati_pos);
%     h_total_gap = 0;
%     h_gap_count = 1;
%     for h_sati_num = 1:hei_sati_num-1
%         hei_time_gap = STATS2(hei_sati_pos(h_sati_num+1)).BoundingBox(1)-...
%             STATS2(hei_sati_pos(h_sati_num)).BoundingBox(1);
%         if hei_time_gap > 3
%             h_total_gap = h_total_gap + hei_time_gap;
%             h_gap_count = h_gap_count + 1;
%         end
%     end
%     mean_hei_gap(h_num) = h_total_gap/h_gap_count;
% end
% 
% max_h_gap = ceil(max(mean_hei_gap)/9)*9;
% 
% max_h_gap2 = ceil(max(mean_hei_gap)/9)*9;
% 
% 
% figure();
% plot(hei_co,mean_hei_gap,'color','b');
% ylabel('Time gap (s)','fontsize',12);
% %axis([0 max_fre_gap 0 22050]);
% %set(gca,'YTick',0:max_fre_gap/20:max_fre_gap);
% set(gca,'yticklabel',0:max_h_gap/9*0.003:max_h_gap*0.003);
% xlabel('Line length (Hz)','fontsize',12);
% set(gca,'xticklabel',0:max_height/10*43:max_height*43);
% set(gcf,'color','white');
% 
% % figure();
% % [AX,H1,H2] =plotyy(mean_time_gap,fre_co,mean_hei_gap,hei_co,@plot);% 获取坐标轴、图像句柄
% % set(get(AX(1),'ylabel'),'string', 'Frequency (Hz)','fontsize',12);
% % set(gca,'yticklabel',0:4410:22050);
% % set(get(AX(2),'ylabel'),'string', 'Line length (Hz)','fontsize',12);
% % set(AX(2),'yticklabel',0:max_height/5*43:max_height*43);
% % xlabel('Time gap (s)','fontsize',12);
% % set(gca,'xticklabel',0:max_h_gap2/10*0.003:max_h_gap2*0.003);
% % set(H1,'Linestyle','-');
% % set(H1,'color','r');
% % set(H2,'Linestyle','-');
% % set(H2,'color','b');
% % set(gcf,'color','white');
% % set(gca,'linewidth',1);
% % %legend([H1,H2],'class1:train','class1:test');
% 
% figure();
% ax1 = plot(mean_time_gap,fre_co,'color','r');
% hold on
% ax2 = plot(mean_hei_gap,hei_co,'color','b');
% hold off
% set(gca,'yticklabel',0:2205:22050);
% set(gca,'xticklabel',0:max_h_gap2/9*0.003:max_h_gap2*0.003);
% legend([ax1(1),ax2(1)],'Time gap with frequency','Time gap with length');
% xlabel('Time gap (s)','fontsize',12);
% ylabel('Frequency (or Length) (Hz)','fontsize',12);
% set(gcf,'color','white');


%////////////////////////对每一类进行分析，继续细分(错误)////////////////////

% [cluster_size,dim] = size(blob_cell);
% for sz=1:cluster_size
%     time_seq = unique(blob_cell{sz,1});
%     time_sz = length(time_seq);
%     height = zeros(time_sz,1);
%     for p = 1:time_sz
%         pos = find(blob_cell{sz,1}==time_seq(p));
%         up = blob_cell{sz,2}(pos,1) + blob_cell{sz,2}(pos,2);
%         up_max = max(up);
%         bot_min = min(blob_cell{sz,2}(pos,1));
%         height(p) = up_max-bot_min;
%     end
%     hei_mean = mean(height);
%     change_time = find(height>=hei_mean*2);
%     sz2 = length(change_time);
%     for q = 1:sz2-1
%         change_pos = find(blob_cell{sz,1}==time_seq(change_time(q)));
%         sz3 = length(change_pos);
%         if isempty(spare_label)
%            for h = 1:sz3
%            block_matrix(blob_cell{sz,2}(change_pos(h),1):blob_cell{sz,2}(change_pos(h),1)+...
%                blob_cell{sz,2}(change_pos(h),2),...
%                time_seq(change_time(q))) = cluster_label;
%            end
%            if  time_seq(change_time(q+1))time_seq(change_time(q+1))>2
%                cluster_label = cluster_label+1;
%            end
%         else
%            
%            tem_label = spare_label(1);
%            for h = 1:sz3
%            block_matrix(blob_cell{sz,2}(change_pos(h),1):blob_cell{sz,2}(change_pos(h),1)+...
%                blob_cell{sz,2}(change_pos(h),2),...
%                time_seq(change_time(q))) = tem_label;
%            end
%            if  time_seq(change_time(q+1))time_seq(change_time(q+1))>2
%            last_label = length(spare_label);
%            spare_label(1:last_label-1) = spare_label(2:last_label);
%            spare_label(last_label) = [];
%            end
%         end
%         
%     end
%     
% end

%////////////////////////20160622_统计长宽频率//////////////

STATS = regionprops(block_matrix,'BoundingBox','Centroid');
a = length(STATS);
xx = zeros(a,1);
yy = zeros(a,1);
zz = zeros(a,1);


for i = 1:a
    xx(i) = STATS(i).BoundingBox(:,3);
    yy(i) = STATS(i).BoundingBox(:,4);
    zz(i) = STATS(i).Centroid(2);
end

figure(10);

plot3(xx*0.003,yy*43,zz*43,'.','MarkerSize',10,'color','g');
xlabel('width (s)');
ylabel('length (Hz)');
zlabel('center frequency (Hz)');
xlim([0,0.3]);
ylim([0,22050]);
zlim([0,22050]);
%set(gca, 'color', [0.8,0.8,0.8]);
set(gcf, 'color', 'w');
grid on
hold on;

%////////////////////////20160629_分大小统计分布规律//////////////

% STATS = regionprops(block_matrix,'BoundingBox','Centroid','ConvexHull');
% a = length(STATS);
% blob_width = zeros(a,1);
% blob_length = zeros(a,1);
% time_pos = zeros(a,1);
% 
% 
% for i = 1:a
%     blob_width(i) = STATS(i).BoundingBox(:,3);
%     blob_length(i) = STATS(i).BoundingBox(:,4);
%     time_pos(i) = STATS(i).Centroid(1);
% end
% 
% max_blob_width = max(blob_width);
% min_blob_width = min(blob_width);
% max_blob_length = max(blob_length);
% min_blob_length = min(blob_length);
% 
% separation_num = 20;
% time_frame_num = 50;
% time_span = floor(time/time_frame_num);
% frequentness = zeros(1,time_frame_num);
% 
% width_vector = linspace(min_blob_width,max_blob_width,10);
% length_vector = linspace(min_blob_length,max_blob_length,separation_num);
% 
% width_span = width_vector(2)-width_vector(1);
% length_span = length_vector(2)-length_vector(1);
% 
% temp1 = find(blob_length>=length_span*1 & blob_length<=length_span*20);
% temp2 = find(blob_width>=width_span*1 & blob_width<=width_span*10);
% temp = intersect(temp1,temp2);
% num_temp = length(temp);
% temp_back = zeros(fre,time);
% 
% figure(3);
% imshow(temp_back);
% hold on
% for ii = 1:num_temp
%     fill(STATS(temp(ii)).ConvexHull(:,1),STATS(temp(ii)).ConvexHull(:,2),[1,1,1]);
% end
% 
% %////////////////////////////2017_0706_分析大块///////////////////////////
% 
% xx = zeros(num_temp,1);
% yy = zeros(num_temp,1);
% zz = zeros(num_temp,1);
% 
% for i = 1:num_temp
%     xx(i) = STATS(temp(i)).BoundingBox(:,3);
%     yy(i) = STATS(temp(i)).BoundingBox(:,4);
%     zz(i) = STATS(temp(i)).Centroid(2);
% end
% 
% fre_count = zeros(1,fre);
% fre_count2 = 1:43:fre*43;
% 
% for ai = 1:num_temp
%     
%     fre_count(floor(zz(ai))) = fre_count(floor(zz(ai)))+yy(ai)*43;
%     
% end
% 
% figure(7);
% plot(fre_count2,fre_count);
% xlim([0,22050]);
% xlabel('Frequency (Hz)');
% ylabel('Sum of length (Hz)');
% set(gcf,'color','white');
% hold on

% figure(6);
% plot3(xx*0.003,yy*43,zz*43,'.','MarkerSize',10,'color','g');
% xlabel('width (s)');
% ylabel('length (Hz)');
% zlabel('center frequency (Hz)');
% xlim([0,0.3]);
% ylim([0,22050]);
% zlim([0,22050]);
% %set(gca, 'color', [0.8,0.8,0.8]);
% set(gcf, 'color', 'w');
% grid on
% hold on;



%///////////////////////////////////////////////////////////////////////

% for jj = 1:time_frame_num
%     temp_time = find(time_pos>=time_span*(jj-1) & time_pos<=time_span*jj);
%     frequentness(jj) = length(intersect(temp,temp_time));
% end
% 
% figure(4);
% bar(1:time_frame_num,frequentness);
% xlabel('number of time frame');
% ylabel('frequency');
% set(gcf,'color',[1,1,1]);
% 
% 
% lambda = mean(frequentness);
% max_fre = max(frequentness);
% min_fre = min(frequentness);
% discrete_num = 10;
% 
% fre_vector = linspace(min_fre,max_fre,discrete_num);
% fre_vector2 = zeros(1,discrete_num-1);
% fre_num = zeros(1,discrete_num-1);
% 
% for kk = 1:discrete_num-1
%     if kk<=discrete_num-2
%         fre_num(kk) = length(find(frequentness>=fre_vector(kk) & frequentness<fre_vector(kk+1)));
%     else
%         fre_num(kk) = length(find(frequentness>=fre_vector(kk) & frequentness<=fre_vector(kk+1)));
%     end
%     fre_vector2(kk) = fre_vector(kk)+(fre_vector(kk+1)-fre_vector(kk))/2;
% end
% 
% xx = 0:1:max_fre-min_fre;
% px = poisspdf(xx,lambda-min_fre);
% pxx = poisscdf(xx,lambda-min_fre);
% 
% fig = figure(1);
% plot(fre_vector2,fre_num/sum(fre_num));
% hold on
% plot(min_fre:1:max_fre,px);
% str = sprintf('lambda = %5.2f',lambda);
% xpos = 0.8*xlim;
% ypos = 0.8*ylim;
% text(xpos(2),ypos(2),str);
% 
% xlabel('K');
% ylabel('P(X=K)');
% legend('Data','Poisson');
% config = sprintf('time_frame = %6.3f s',time_span*0.003);
% file_name = [filename,' ',config,'.png'];
% print(fig,file_name,'-djpeg');
% 
% poisscdf(fre_num/sum(fre_num)',lambda);
% 
% [H,ss]=kstest(fre_num/sum(fre_num)',[xx',pxx']);


%/////////////////////////////////////////////////////////////

%///////////////////////计算区域属性///////////////////////
% figure();
% plot(total);

%result = bwareaopen(result,20);

%[L,num] = bwlabel(result,8);

STATS = regionprops(block_matrix,'ConvexHull','Centroid');
%STATS = regionprops(L,'ConvexHull','Centroid');



a = length(STATS);

figure();
imshow(result);
axis on;
hold on
for i = 1:a
    Draw_polygon(STATS(i).ConvexHull(:,1),STATS(i).ConvexHull(:,2));
    %plot(STATS(i).Centroid(1),STATS(i).Centroid(2),'.','markersize',20);
end
hold off
