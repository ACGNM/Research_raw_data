%==============显示滤波器单位冲击响应波形(时域)=====================
% t = 0:1/14400:3200/14400;
% y = t.^ 3 .* exp(- 2 * pi * 1.019 * 20 * t).* cos(2 * pi * 100 * t);
% 
% plot(t,y);
%========================================================


[x fs] = audioread(['./sound/water/water-',num2str(20),'.wav']);
x = x(:,1);
n = length(x);
n_channel = 128;


c = make_erb_freqs(44100, n_channel);
[B1, B2, B3, B4, A] = make_erb_bank_polezero_cascade(fs, c);
y = gtf_polezero(B1, B2, B3, B4, A, x);


for i = 1:n_channel
    % 和一个[1 1 1 ... 1]卷积，相当于做移动平均，以求得短时能量
    Y(:, i) = conv(y(:, i) .^ 2, ones(200, 1) / 200);
end

Y = Y*100;
Y = (Y - min(Y(:)))/(max(Y(:)) - min(Y(:)));

imagesc(Y'); % 在每个输出信号中均匀地取400个采样，获得对数谱，绘制
set(gca,'YTicklabel',c(1:21:128));
result = Binary_Wellner(Y);
figure();
imagesc(result');
colormap(gray);
set(gca,'YTicklabel',c(1:21:128));


function CF = make_erb_freqs(fs, n_channel)
    SF = 1 / n_channel * 9.26 * (log(fs + 228.7) - log(20 + 228.7));
    CF = - 228.7 + (fs + 228.7) ./ exp(0.108 * (1:n_channel)' * SF);
end

function ERB = erb_bandwidth(f0)
    ERB = 24.7 * (0.00437 * f0 + 1);
end

function [B, A] = make_erb_pass_polezero_cascade( ...
  fs, pass_freq, pass_band, zero_func)
    T = 1 / fs;
    f0 = pass_freq;
    BW = 1.019 * 2 * pi * pass_band;
    E = exp(BW * T);
    n_channel = length(pass_freq);
    
    B = zeros(n_channel, 2);
    A = zeros(n_channel, 3);
    B(:, 1) = T;
    B(:, 2) = zero_func(T, f0, E);
    A(:, 1) = 1;
    A(:, 2) = - 2 * cos(2 * f0 * pi * T) ./ E;
    A(:, 3) = E .^ (-2);
    cz = exp(- 2 * j * pi * f0 * T);
    g = (T + B(:, 2) .* cz) ./ ...
        (1 + A(:, 2) .* cz + A(:, 3) .* cz .^ 2);
    B(:, 1) = B(:, 1)./abs(g);
    B(:, 2) = B(:, 2)./abs(g);
end

function [B1, B2, B3, B4, A] = make_erb_bank_polezero_cascade( ...
  fs, bank_freq)
    BW = erb_bandwidth(bank_freq);
    f0 = bank_freq;
    zcoef1 = @(T, cf, E) - (T * cos(2 * f0 * pi * T) ./ E ...
                         + sqrt(3 + 2 ^ 1.5) * T * sin(2 * f0 * pi * T) ./ E);
    zcoef2 = @(T, cf, E) - (T * cos(2 * f0 * pi * T) ./ E ...
                         - sqrt(3 + 2 ^ 1.5) * T * sin(2 * f0 * pi * T) ./ E);
    zcoef3 = @(T, cf, E) - (T * cos(2 * f0 * pi * T) ./ E ...
                         + sqrt(3 - 2 ^ 1.5) * T * sin(2 * f0 * pi * T) ./ E);
    zcoef4 = @(T, cf, E) - (T * cos(2 * f0 * pi * T) ./ E ...
                         - sqrt(3 - 2 ^ 1.5) * T * sin(2 * f0 * pi * T) ./ E);
    
    [B1 A] = make_erb_pass_polezero_cascade(fs, bank_freq, BW, zcoef1);
    B2     = make_erb_pass_polezero_cascade(fs, bank_freq, BW, zcoef2);
    B3     = make_erb_pass_polezero_cascade(fs, bank_freq, BW, zcoef3);
    B4     = make_erb_pass_polezero_cascade(fs, bank_freq, BW, zcoef4);
end

function y = gtf_polezero(B1, B2, B3, B4, A, x)

    
    [n_channel,~] = size(A);
    y = zeros(length(x), n_channel);
    for i = 1:n_channel
        y(:, i) = filter(B1(i, :), A(i, :), x);
        y(:, i) = filter(B2(i, :), A(i, :), y(:, i));
        y(:, i) = filter(B3(i, :), A(i, :), y(:, i));
        y(:, i) = filter(B4(i, :), A(i, :), y(:, i));
    end
end


