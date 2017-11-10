function Draw_polygon(X,Y)

xsize = length(X);
ysize = length(Y);

for i = 1:xsize-1
    line([X(i),X(i+1)],[Y(i),Y(i+1)],'color','r','linewidth',1);
end

%line([X(1),X(xsize)],[Y(1),Y(ysize)],'color','r','linewidth',1);

end