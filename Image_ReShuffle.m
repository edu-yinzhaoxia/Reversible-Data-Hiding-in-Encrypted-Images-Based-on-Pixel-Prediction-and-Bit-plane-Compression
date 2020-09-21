function [re_I] = Image_ReShuffle(sh_I,SH)
% 函数说明：将图像I根据混洗序列SH进行混洗
% 输入：sh_I（混洗的图像矩阵）,SH（混洗序列）
% 输出：re_I（恢复后的图像矩阵）

[m,n] = size(sh_I);
num = numel(SH);
I1 = reshape(sh_I,1,m*n); %将sh_I转换成一维矩阵
x_I = zeros(1,m*n); %构建一维恢复容器
for i=1:num
    x = SH(i); %置乱的坐标
    x_I(i) = I1(x);
end
re_I = reshape(x_I,m,n);
end