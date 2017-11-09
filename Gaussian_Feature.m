[y1,fs] = audioread('./sound/water/water-1.wav');
y1 = y1(:,1);

N = length(y1);
win = 256;
window = rectwin(win);
noverlap = 128;
nfft = 1024;
time = double(length(y1)/fs);
[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
logPxx = 10*log10(abs(Pxx)+eps);

result = Binary_Wellner(logPxx);
result = bwareaopen(result,50);

figure();
imshow(result(1:100,1:100));
[x,y] = find(result(1:100,1:100));

X = [x/30 y/30];

figure();
scatter(X(:,1),X(:,2));

GMModel = fitgmdist(X,3);
figure();
ezsurf(@(x1,x2)pdf(GMModel,[x1 x2]));