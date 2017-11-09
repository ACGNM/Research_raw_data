path_name = './sound/';

win = 256;
window = rectwin(win);
noverlap = 128;
nfft = 1024;
count = 0;
total = zeros(513,601);

for i = 1:32
   
[y,fs] = audioread([path_name,'wind/wind-',num2str(i),'.wav']);
y1 = y(:,1);
y2 = y(:,2);

[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
[s2,f2,t2,Pxx2,fcorr2,tcorr2] = spectrogram(y2,window,noverlap,nfft,fs,'yaxis');

logPxx = 10*log10(abs(Pxx)+eps);
logPxx2 = 10*log10(abs(Pxx2)+eps);

result = Binary_Wellner(logPxx);
result2 = Binary_Wellner(logPxx2);
% result = bwareaopen(result,10);
% result2 = bwareaopen(result2,10);
result = imbinarize(result);
result2 = imbinarize(result2);

add = sum(result,1);
add2 = sum(result2,1);

pos = find(add>=60);
pos2 = find(add2>=60);

section  = result(:,pos(1):pos(1)+600);
section2  = result2(:,pos2(1):pos2(1)+600);

[m,n] = size(result);
if n == 1032
total = total+section+section2;
count = count+2;
end

end


total = total/count;
% total = Binary_Wellner(total);

[test,fs] = audioread('./sound/wind/wind-20.wav');
test = test(:,1);

[s,f,t,Pxx3,fcorr,tcorr] = spectrogram(test,window,noverlap,nfft,fs,'yaxis');

logPxx3 = 10*log10(abs(Pxx3)+eps);



result = Binary_Wellner(logPxx3);
result = imbinarize(result);

test_add = sum(result,1);

pos = find(test_add>=80);

r = corr2(total,result(:,pos(1):pos(1)+600));


imshow(total);


