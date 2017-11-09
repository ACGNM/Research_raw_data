function squence = my_findpeak(source)

length_s = length(source);
diff = [];

avg = sum(source)*1.5/length_s;

for i = 1:length_s-1
    if source(i+1)-source(i)>0
        diff(i) = 1;
    elseif source(i+1)-source(i)<0
        diff(i) = -1;
    else
        diff(i) = 0;
    end
end

diff_length = length(diff);

for i = diff_length:-1:1
    if diff(i)==0 & i==diff_length
        diff(i) = 1;
    elseif diff(i)==0
        if diff(i+1)>=0
            diff(i) = 1;
        else
            diff(i) = -1;
        end
    end
end

result = zeros(1,length_s);

for i=1:diff_length-1
    if diff(i+1)-diff(i)==-2 & source(i+1)>=avg
        result(i+1) = source(i+1);
    end
end

squence = find(result);


end