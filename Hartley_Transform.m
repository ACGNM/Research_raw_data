[y1,fs] = audioread(['./sound/cicada-',num2str(1),'.wav']);
y1 = y1(:,1);

frame_num = 100;
win = 30;
%overlap pass
result = zeros(win,frame_num);


for i=1:frame_num
    x = y1((i-1)*win+1:i*win);

%DHartleyT Summary of this function goes here  
%   Detailed explanation goes here  
%   x is the input single  
%   X is the discrete Hartley transform of x  

    N = length(x);  
    [x_rows,x_columns] = size(x); 

    %x should be a column vector
    if x_rows<x_columns  
        x = x';  
    end  
    [k,n] = meshgrid(0:N-1);  
    HN = sqrt(1/N)*(cos(2*pi/N*n.*k)+sin(2*pi/N*n.*k));  
    X = HN*x;
    %DHartleyT ends here
    
    result(:,i) = X;

end

log_result = 10*log10(abs(result)+eps);

imagesc(log_result);




