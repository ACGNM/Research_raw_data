%����ÿһ��ľ����ǩ
%data:mxn��mΪ��ĸ�����nΪ���ά��
%MinPts:���ĵ㷶Χ����С����

function [class] = DBscan(data,MinPts)

Eps = region(data,MinPts);

[m,n] = size(data);

new_data = [(1:m)' data];
[m,n] = size(new_data);

type = zeros(1,m); %���ĵ��־Ϊ1���߽��Ϊ0��������Ϊ-1
visit = zeros(m,1); %�жϵ��Ƿ񱻷��ʹ������ʹ�Ϊ1��δ������Ϊ0
distance = calDistance(new_data(:,2:n));

class = zeros(1,m);
label = 1; %����ǩ���

h = waitbar(0,'Please wait...');

for i=1:m
    
    if visit(i) == 0
        point = new_data(i,:);
        dis_temp = distance(i,:);
        Eps_points = find(dis_temp<=Eps);
        
        point_num = length(Eps_points);
        
        if point_num > 1 && point_num < MinPts+1
            
            type(i) = 0;
            
        elseif point_num<=1
            
            type(i) = -1;
            class(i) = -1;
            visit(i) = 1;
            
        else
            
            type(i) = 1;
            class(Eps_points) = label;
            
            while ~isempty(Eps_points)
                
                E_point = new_data(Eps_points(1),:);
                visit(Eps_points(1)) = 1;
                Eps_points(1) = [];
                
                dis_temp2 = distance(E_point(1,1),:);
                Eps_point2 = find(dis_temp2<=Eps);
                point_num2 = length(Eps_point2);
                
                %����������չ
                if point_num2>1
                    
                    class(Eps_point2) = label;
                    if point_num2 >= MinPts+1
                        type(E_point(1,1)) = 1;
                    else
                        type(E_point(1,1)) = 0;
                    end
                    
                    for j=1:point_num2
                        
                        if visit(Eps_point2(j)) == 0
                            visit(Eps_point2(j)) = 1;
                            class(Eps_point2(j)) = label;
                            Eps_points = [Eps_points, Eps_point2(j)];
                        end
                        
                    end
                    
                end
                
            end
            
            label = label + 1;
            
        end
        
         
    end
    waitbar(i/m);

end

noise_point = find(class==0);
class(noise_point) = -1;
type(noise_point) = -1;
close(h);


end

%�����֮��ľ���
function [distance] = calDistance(data)

[m,n] = size(data);
distance = zeros(m,m);

for i = 1:m
    for j = i:m
        temp = 0;
        for k = 1:n
            temp = temp+(data(i,k)-data(j,k))^2;
        end
        distance(i,j) = sqrt(temp);
        distance(j,i) = distance(i,j);
    end
end

end

%ȷ����Χ����
function [Eps] = region(data,MinPts)

[m,n] = size(data);

Eps = ((prod(max(data)-min(data))*MinPts*gamma(.5*n+1))/(m*sqrt(pi^n)))^(1/n);

end