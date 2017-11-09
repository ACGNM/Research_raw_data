robj = audiorecorder(44100,16,1);  %设置采样频率、采样位数、通道数  
recordblocking(robj,1);            %采集初步数据（1s长度）  
rdata = getaudiodata(robj);        %获取音频数据  
plot(rdata);                       %绘制波形  
axis([1,22050,-0.1,0.1]);          %设置固定坐标轴  
drawnow                            %刷新显示  
n = 100;                           %设定后续的采样更新次数，n与m可联合计算后续更新时间长度  
m = 0.1;                           %设定更新间隔，m越小波形越连续  
while n>1  
    recordblocking(robj,m);  
    rlen = length(rdata);          %获取数据长度  
    olddata = rdata(floor(rlen*m):rlen,1);     %保留的旧数据  
    rdata = [olddata ; getaudiodata(robj)];    %待显示的数据 = 旧数据 + 新数据  
    plot(rdata);  
    axis([1,22050,-0.1,0.1]);  
    drawnow  
    n = n-1;  
end  