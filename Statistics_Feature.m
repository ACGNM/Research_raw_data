function [proportion,variance,vector] = Statistics_Feature(BwIm,start_pos,fre_num,fre_seg,time_num,time_seg)

proportion = cal_proportion(BwIm,start_pos,fre_num,fre_seg,time_num,time_seg);
variance = cal_variance(BwIm,start_pos,fre_num,fre_seg,time_num,time_seg);

vector = constract_vector(proportion,variance);

end

%计算高点占比
function proportion = cal_proportion(BwIm,start_pos,fre_num,fre_seg,time_num,time_seg)

proportion = zeros(fre_num,time_num);
total_point = fre_seg*time_seg;


fre_start = 1;
fre_end = fre_seg-1;
time_start = start_pos;
time_end = start_pos+time_seg-1;

for i=1:time_num
    for j=1:fre_num
        proportion(j,i) = length(find(BwIm(fre_start:fre_end,time_start:time_end)))/total_point;
        fre_start = fre_start+fre_seg;
        fre_end = fre_end+fre_seg;
    end
    time_start = time_start+time_seg;
    time_end = time_end+time_seg;
    fre_start = 1;
    fre_end = fre_seg+1;
end

proportion = proportion*10;

end

%计算分散度（方差）
function variance = cal_variance(BwIm,start_pos,fre_num,fre_seg,time_num,time_seg)

variance = zeros(fre_num,time_num);

fre_start = 1;
fre_end = fre_seg-1;
time_start = start_pos;
time_end = start_pos+time_seg-1;

for i=1:time_num
    
    for j=1:fre_num
        [X,Y] = find(BwIm(fre_start:fre_end,...
            time_start:time_end));
        if ~isempty(X)
            data = [X Y];
            distance = calDistance(data);
            variance(j,i) = var(distance);
            fre_start = fre_start+fre_seg;
            fre_end = fre_end+fre_seg;
        end
    end
    time_start = time_start+time_seg;
    time_end = time_end+time_seg;
    fre_start = 1;
    fre_end = fre_seg+1;
end


end

function vector = constract_vector(proportion,variance)

count = 1;
[pro_m,pro_n] = size(proportion);
[var_m,var_n] = size(variance);

total_count = pro_m*pro_n+var_m*var_n;
total_row = pro_m+var_m;
new_data = zeros(total_row,pro_n);
pro_count = 1;
var_count = 1;

for i=1:total_row
    if mod(i,2)==1
        new_data(i,:) = proportion(pro_count,:);
        pro_count = pro_count+1;
    else
        new_data(i,:) = variance(var_count,:);
        var_count = var_count+1;
    end
end

vector = reshape(new_data,total_count,1);


end


function [distance] = calDistance(data)

data_mean = mean(data);
[m,n] = size(data);
distance = zeros(1,m);

for i = 1:m
    distance(1,i) = sqrt(sum((data(i,:)-data_mean).^2));
end

end

