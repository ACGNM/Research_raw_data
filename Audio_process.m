function [vector1, vector2] = Audio_process(filename,isdouble)

[y,fs] = audioread(filename);
y2 = y(:,1);


%N = length(y2);
win = 256;
window = rectwin(win);
noverlap = 128;
nfft = 1024;
%time = double(length(y2)/fs);
[s,f,t,Pxx,fcorr,tcorr] = spectrogram(y2,window,noverlap,nfft,fs,'yaxis');
logPxx = 10*log10(abs(Pxx)+eps);

result = Binary_Wellner(logPxx);
result = bwareaopen(result,20);

vector1 = Feature_extraction(result);

if isdouble == 1
    y2 = y(:,2);


    %N = length(y2);
    [s,f,t,Pxx,fcorr,tcorr] = spectrogram(y2,window,noverlap,nfft,fs,'yaxis');
    logPxx = 10*log10(abs(Pxx)+eps);

    result2 = Binary_Wellner(logPxx);
    result2 = bwareaopen(result2,20);

    vector2 = Feature_extraction(result2);
else
    vector2 = [];
end

end