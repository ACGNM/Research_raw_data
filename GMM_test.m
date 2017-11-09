%һ�������������
mu1 = [1 2];
Sigma1 = [0.05 0; 0 2];
mu2 = [-3 -5];
Sigma2 = [1 0;0 1];
rng(1); % For reproducibility
%mvnrnd�������ɶ�ά��̬���� muΪ��ֵ 
%Sigma��Э�������Э��������ʾ����ά��֮��Ĺ�ϵ
%(��10��3ά�����������γ�һ��10*3������������Э����������������ά֮��Ĺ�ϵ����Э�������Ϊ3*3�ľ���
% .* �Ǹ���Ԫ�صĳ˷������Ǿ���˷�
X = [mvnrnd(mu1,Sigma1,1000);mvnrnd(mu2,Sigma2,1000)];

GMModel = fitgmdist(X,2);

figure
y = [zeros(1000,1);ones(1000,1)];
h = gscatter(X(:,1),X(:,2),y);
hold on
%@��ʾ����������@��ģ�����Ϊ����������������е��Ƕ�ά��ʱ�򣬴���x1��x2���������ͻ���ݸ����ܶȺ��������һ�����ʽ����
%�������ͼ����Χ�ڵ����е㶼������һ��������ĸ�����Ϊ�ȸ��ߵĲ�����ֵ
%��Ϊ���ӿ�����������Ĵ��룬���Կ�����Щ���ֱ�õ�ʲô
%Var1 = get(gca,{'XLim','YLim'});
%Var2 = @(x1,x2)pdf(GMModel,[x1 x2]);
%var_y = Var2(1,3);
ezsurf(@(x1,x2)pdf(GMModel,[x1 x2]),get(gca,{'XLim','YLim'}))
%ezsurf��ezcontour�����ڶ�������һ���Ƿ�Χ��[xmin,xmax,ymin,ymax]�������ϻ�ȡ��Χ���������������һ�������ʾĬ�Ϸ�Χ�ڻ�ͼ���õ���
%ezsurf(@(x1,x2)pdf(GMModel,[x1 x2]))
title('{\bf Scatter Plot and Fitted Gaussian Mixture Contours}')
legend(h,'Model 0','Model1')
hold off