function [sh_I] = Image_Shuffle(I,SH)
% 函数说明：将图像I根据混洗序列SH进行混洗
% 输入：I（原始图像矩阵）,SH（混洗序列）
% 输出：sh_I（混洗后的图像矩阵）

[m,n] = size(I);
Shuffle = reshape(SH,m,n); %换成矩阵,以列排序
x_I = zeros(1,numel(Shuffle)); %构建一维混洗容器
for j=1:n
    for i=1:m
        x = Shuffle(i,j); %（i,j）置乱的位置坐标为x
        x_I(x) = I(i,j);
    end
end
sh_I = reshape(x_I,m,n);
end