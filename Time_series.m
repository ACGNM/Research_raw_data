x = cos(2*pi*(3*(1:1000)/1000).^2);
y = cos(2*pi*9*(1:399)/400);
figure();
dtw(x,y);

x1 = [0 1 0 0 0 0 0 0 0 0 0 1 0]*.95;
x2 = [0 1 0 1 0]*.95;

figure();
subplot(2,1,1)
plot(x1)
xl = xlim;
subplot(2,1,2)
plot(x2)
xlim(xl)

figure
dtw(x1,x2);