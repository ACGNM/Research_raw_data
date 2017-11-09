%一个二分类的例子
mu1 = [1 2];
Sigma1 = [0.05 0; 0 2];
mu2 = [-3 -5];
Sigma2 = [1 0;0 1];
rng(1); % For reproducibility
%mvnrnd用来生成多维正态数据 mu为均值 
%Sigma是协方差矩阵，协方差矩阵表示各个维度之间的关系
%(如10个3维的特征向量形成一个10*3的样本矩阵，则协方差计算的是向量三维之间的关系，即协方差矩阵为3*3的矩阵）
% .* 是各个元素的乘法，不是矩阵乘法
X = [mvnrnd(mu1,Sigma1,1000);mvnrnd(mu2,Sigma2,1000)];

GMModel = fitgmdist(X,2);

figure
y = [zeros(1000,1);ones(1000,1)];
h = gscatter(X(:,1),X(:,2),y);
hold on
%@表示匿名函数，@后的（）内为变量名，这个例子中点是二维的时候，传入x1，x2两个参数就会根据概率密度函数计算出一个概率结果，
%而这里绘图将范围内的所有点都计算了一遍用输出的概率作为等高线的参照数值
%作为例子可以运行下面的代码，可以看到这些语句分别得到什么
%Var1 = get(gca,{'XLim','YLim'});
%Var2 = @(x1,x2)pdf(GMModel,[x1 x2]);
%var_y = Var2(1,3);
ezsurf(@(x1,x2)pdf(GMModel,[x1 x2]),get(gca,{'XLim','YLim'}))
%ezsurf和ezcontour函数第二个参数一般是范围（[xmin,xmax,ymin,ymax]或者如上获取范围），但是如果输入一个数则表示默认范围内画图所用点数
%ezsurf(@(x1,x2)pdf(GMModel,[x1 x2]))
title('{\bf Scatter Plot and Fitted Gaussian Mixture Contours}')
legend(h,'Model 0','Model1')
hold off