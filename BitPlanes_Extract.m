function [Plane] = BitPlanes_Extract(I,pl)
% 函数说明：从图像I中提取第pl个位平面
% 输入：I（图像矩阵）,pl（位平面）
% 输出：Plane（位平面矩阵）

[row,col] = size(I);
Plane = zeros(row,col);
index = 8 - pl + 1; %像素第pl个位平面的索引
for i=1:row
    for j=1:col
        value = I(i,j); %当前位置的像素值
        [bin2_8] = BinaryConversion_10_2(value); %将像素值value转换成8位二进制数
        Plane(i,j) = bin2_8(index); %几录第pl个位平面的值
    end
end