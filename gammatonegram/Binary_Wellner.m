function [result] = Binary_Wellner(logPxx)

logPxx = double(logPxx);

[height,width] = size(logPxx);
integralImg = zeros(height,width);
result = zeros(height,width);
aa = ceil((width/8));
T = 10;
alpha = (100-T)/100;

if mod(aa,2)==0
    s = aa/2;
else
    s = (aa+1)/2;
end

for i=1:width
    
    sum1 = 0;
    for j=1:height
        sum1 = sum1 + logPxx(j,i);
        if i == 1
            integralImg(j,i) = sum1;
        else
            integralImg(j,i) = integralImg(j,i-1)+sum1;
        end
        %integralImg(j,i) = sum(sum(data(1:j,1:i)));
    end
end

for i=1:width
    for j=1:height
        x1 = i-s;
        y1 = j-s;
        x2 = i+s;
        y2 = j+s;
        if x1<1
            x1 = 1;
        end
        if y1<1
            y1 = 1;
        end
        if x2>width
            x2 = width;
        end
        if y2>height
            y2 = height;
        end
        
        count = (x2-x1+1)*(y2-y1+1);
        
        if x1-1<1 && y1-1>=1
            UR = integralImg(y1-1,x2);
            LL = 0;
            UL = 0;
        elseif x1-1>=1 && y1-1<1
            UR = 0;
            LL = integralImg(y2,x1-1);
            UL = 0;
        elseif x1-1<1 && y1-1<1
            UR = 0;
            LL = 0;
            UL = 0;
        else
            UR = integralImg(y1-1,x2);
            LL = integralImg(y2,x1-1);
            UL = integralImg(y1-1,x1-1);
        end
        
        LR = integralImg(y2,x2);
        %disp(LR-UR-LL+UL);
        avg = (LR-UR-LL+UL)*alpha/count;
        
        if logPxx(j,i)<avg*1.7
            result(j,i) = 0;
        else
            result(j,i) = 255;
        end
    end
end

%result = im2bw(result);

end