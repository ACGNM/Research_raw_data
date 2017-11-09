function [block_matrix,blob_cell] = blob_separation(BWIM)
[fre,time] = size(BWIM);
count_matrix = zeros(fre,fre,time); %������������Ŀ�ʼ�������೤
start_fre = 0;

for i=1:time
    fre_seq = find(BWIM(:,i));
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
% %////////////////////////��ʾ�������////////////////////////////
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
spare_label = []; %�������ǩ
blob_cell = {}; %ÿһ�����а�����1.ʱ����� 2.[��ʼƵ�ʣ���������] 3.��� 4.ƽ���߶�
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
        
        if i==1 %��һ�е����
            
            for j=1:b_num
                block_matrix(s_fre(j):s_fre(j)+b_count(j),i) = cluster_label;
                blob_cell{cluster_label,1} = i;
                blob_cell{cluster_label,2} = [s_fre(j),b_count(j)];
                blob_cell{cluster_label,3} = 1;
                blob_cell{cluster_label,4} = b_count(j);
                cluster_label = cluster_label+1;
            end
            
        else
            
            if ~isempty(find(count_matrix(:,:,i-1),1))  %ǰһ�в�Ϊ��
            
            
            
            for j=1:b_num
                
                bot_cirt = s_fre(j)-2; %�²��ٽ�ֵ bottom_critical
                up_cirt = s_fre(j)+b_count(j)+2; %�ϲ��ٽ�ֵ up_critical
                up_values = pre_s_fre+pre_b_count; %ǰһ�е��ϲ��ս�λ��
                up_satis = find(up_values>=bot_cirt); %�ϲ��ս�λ�ô����²��ٽ��ǰһ��Ԫ�ر��
                bot_satis = find(pre_s_fre<=up_cirt); %�²���ʼλ��С���ϲ��ٽ��ǰһ��Ԫ�ر��
                left_blob_pos = intersect(up_satis,bot_satis); %��������Ԫ�ر�ŵĽ�������λ�ڱ�����ߵĿ���
                left_blob_num = length(left_blob_pos);
                if left_blob_num>0
                    for k=1:left_blob_num
                        left_tem_label = block_matrix(pre_s_fre(left_blob_pos(k)),i-1);%��ȡ��߰׿�ı��
                        
                        %heig_diff = b_count(j)-1.5*blob_cell{left_tem_label,4};%��ǰ����������ĸ߶Ȳ�
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
                               %blob_cell{curr_label,4} = b_count(j); %�߶���ʱ���߳��ȵľ�ֵ�������λ���޹أ���Ҫ����
                               
                               %����ߵĸ������ұߵ�С�����Ϊ��ǰ�ұߵ����ǩ
                               tem_wid = length(blob_cell{left_tem_label,1});   
                               for tem = 1:tem_wid
                                   tem_count = length(blob_cell{left_tem_label,2}(tem,:))/2;
                                   for tem2 = 1:tem_count
                                       block_matrix(blob_cell{left_tem_label,2}(tem,tem2):blob_cell{left_tem_label,2}(tem,tem2)+...
                                           blob_cell{left_tem_label,2}(tem,tem2+tem_count),...
                                           blob_cell{left_tem_label,1}(tem)) = curr_label;
                                   end
                               end
                               
                               %����ߵ�С������ȫ��Ϊ�ղ��ҽ������ǩ������б�ǩ������
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
                    %��ǰһ�� �Ȳ�д
                    
                    %��������
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
            
            else   %ǰһ��Ϊ��
                
                %��ǰһ�� �Ȳ�д
                %������Ϊ����
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