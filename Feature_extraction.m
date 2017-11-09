function [vector] = Feature_extraction(BWIM)

[X,Y] = find(BWIM);
statistics_re = tabulate(Y);
temp_pos = find(statistics_re(:,2)>20);
start = temp_pos(1);

%/////////////////////Statistics_Feature/////////////////////////////////
[proportion,variance,vector] = Statistics_Feature(BWIM,start,10,51,20,20);


result2 = flip(BWIM,1);


%figure();
%imshow(result2);
%figure();
%imshow(result2);

end