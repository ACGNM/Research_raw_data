%test1();
test3();


function test3()

[y1,fs] = audioread('helicopter_3s_1.wav');
y1 = y1(:,1);

N = length(y1);
win = 256
window = rectwin(win);
noverlap = 0;
nfft = 1024;
time = double(length(y1)/fs);
[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
%Pxx = Pxx*fs;
logPxx = 10*log10(abs(Pxx)+eps);

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
        
        if logPxx(j,i)<avg
            result(j,i) = 0;
        else
            result(j,i) = 255;
        end
    end
end

[data_x data_y] = find(result);
figure();
imshow(result);

data = [data_x data_y];


class = DBscan(data,10);

class_label = unique(class);

class_num = length(class_label);

[m,n] = size(data);
y_db = zeros(m,1);
db_pic = zeros(height,width);

for i=1:class_num
    
    point = find(class==class_label(i));
    if length(point)>150
        y_db(point) = class_label(i);
        %db_pic(data(point,1),data(point,2)) = 255;
    else
        y_db(point) = 0;
    end
    
end

figure();
gscatter(data(:,1),data(:,2),y_db);
figure();
imshow(db_pic);

end

function test2()

[y1,fs] = audioread('helicopter_3s_1.wav');
y1 = y1(:,1);

N = length(y1);
win = 256
window = rectwin(win);
noverlap = 128;
nfft = 1024;
time = double(length(y1)/fs);
[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
Pxx = Pxx*fs;
logPxx = 10*log10(abs(Pxx)+eps);
%figure();
%mesh(logPxx);

[height,width] = size(logPxx);
bw_peak = double(zeros(height,width));
for i=1:width
    peak_sque = my_findpeak(Pxx(:,i));
    bw_peak(peak_sque,i) = 255.0;
end
%figure;imshow(bw_peak);

bw_peak2 = double(zeros(height,width));
for i=1:height
    peak_sque = my_findpeak(Pxx(i,:));
    bw_peak2(i,peak_sque) = 255.0;
end
%figure;imshow(bw_peak2);


bw_peak3 = bw_peak+bw_peak2-255;

for i=1:width
    for j=1:height
        if bw_peak3(j,i)<0
            bw_peak3(j,i)=0.0;
        end
    end
end

%figure();imshow(bw_peak3);

[data_x data_y] = find(bw_peak3);

data = [data_x data_y];

class = DBscan(data,1);

class_label = unique(class);

class_num = length(class_label);

[m,n] = size(data);
y_db = zeros(m,1);
for i=1:class_num
    
    point = find(class==class_label(i));
    y_db(point) = class_label(i);
    
end

figure();
gscatter(data(:,1),data(:,2),y_db);

end

function test1()

mu1 = [1 2];
Sigma1 = [0.3 0; 0 0.3];
mu2 = [-3 -5];
Sigma2 = [0.3 0;0 0.5];
mu3 = [-1 -2];
Sigma3 = [0.3 0;0 0.3];
rng(1);

X = [mvnrnd(mu1,Sigma1,30);mvnrnd(mu2,Sigma2,30);mvnrnd(mu3,Sigma3,30)];

figure();
y = [zeros(30,1);zeros(30,1);zeros(30,1)];
gscatter(X(:,1),X(:,2),y);

class = DBscan(X,5);

class_label = unique(class);

class_num = length(class_label);

[m,n] = size(X);
y_db = zeros(m,1);
for i=1:class_num
    
    point = find(class==class_label(i));
    y_db(point) = mod(class_label(i),3);
    
end

figure();
gscatter(X(:,1),X(:,2),y_db);

end
