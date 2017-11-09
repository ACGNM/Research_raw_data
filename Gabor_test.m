[y1,fs] = audioread(['./sound/wind/wind-',num2str(20),'.wav']);
y1 = y1(:,1);

N = length(y1);
win = 256;
window = rectwin(win);
noverlap = 128;
nfft = 1024;
time = double(length(y1)/fs);

figure();
[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y1,window,noverlap,nfft,fs,'yaxis');
logPxx = 10*log10(abs(Pxx)+eps);
imagesc(logPxx);

theta = 0;
f0 = 0.05;     
x = 0;
for i = linspace(-10,10,11)
    x = x + 1;  
    y = 0;  
    for j = linspace(-10,10,11)  
        y = y + 1;
        z(y,x)=compute_Gabor(i,j,f0,theta);
    end
end
figure();
filtered = filter2(z,logPxx,'valid');
f = abs(filtered);
imagesc(f/max(f(:)));

result = Binary_Wellner(f/max(f(:)));
figure();
imshow(result);