path_name = './sound/';
outpath = './mat/';
isdouble = 1;

class = {'water','motorcycle','wind'};
feat_num = [400,0];
cross_vali_count = 1;

trainclasses = cell(0);
testclasses = cell(0);


for i = 1:cross_vali_count
    trainclasses(i,:,:)  = textread([path_name,'/trainclasses.txt'],'%s');
    testclasses(i,:,:)   = textread([path_name,'/testclasses.txt'],'%s');
end

%/////////////////Feature_extraction///////////////////////////////////

for i = 1:cross_vali_count
    
    trainclass_num = length(trainclasses(i,:,:));
    testclass_num = length(testclasses(i,:,:));
    
    for k = 1:3
        
        if isdouble == 1
            train_matrix = zeros(feat_num(1)+1,trainclass_num*2);
            test_matrix = zeros(feat_num(1)+1,testclass_num*2);
        else
            train_matrix = zeros(feat_num(1)+1,trainclass_num);
            test_matrix = zeros(feat_num(1)+1,testclass_num);
        end
    
        for j = 1:trainclass_num
        
            [vector1, vector2] = Audio_process([path_name,class{k},'/',class{k},'-',...
            trainclasses{i,j},'.wav'],isdouble);
            fprintf('train_%s-%s\n',class{k},trainclasses{i,j});
            if isdouble == 1
                train_matrix(2:feat_num(1)+1,j*2-1) = vector1;
                train_matrix(1,j*2-1) = k;
                train_matrix(2:feat_num(1)+1,j*2) = vector2;
                train_matrix(1,j*2) = k;
            else
                train_matrix(2:feat_num(1),j) = vector1;
                train_matrix(1,j) = k;
            end
        
        end
        
        save(sprintf('%s/%s_train_%d.mat',outpath,class{k},i),'train_matrix');
        
        for p = 1:testclass_num
        
            [vector1, vector2] = Audio_process([path_name,class{k},'/',class{k},'-',...
            testclasses{i,p},'.wav'],isdouble);
            if isdouble == 1
                fprintf('test_%s-%s\n',class{k},testclasses{i,p});
                test_matrix(2:feat_num(1)+1,p*2-1) = vector1;
                test_matrix(1,p*2-1) = k;
                test_matrix(2:feat_num(1)+1,p*2) = vector2;
                test_matrix(1,p*2) = k;
            else
                test_matrix(2:feat_num(1)+1,p) = vector1;
                test_matrix(1,p) = k;
            end
        
        end
        
        save(sprintf('%s/%s_test_%d.mat',outpath,class{k},i),'test_matrix');
    
    end

end


