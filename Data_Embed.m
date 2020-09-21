function [stego_I,emD] = Data_Embed(ES_I,K_sh,K_hide,D)
% 函数说明：在加密混洗图像ES_I中嵌入秘密信息
% 输入：ES_I（加密混洗图像）,K_sh（图像混洗密钥）,K_hide（数据嵌入密钥）,D（待嵌入的秘密信息）
% 输出：stego_I（载密图像）,emD(嵌入的秘密信息)

[row,col] = size(ES_I); %计算ES_I的行列值
%% 根据图像混洗密钥K_sh恢复图像像素的原始位置
rand('seed',K_sh); %设置种子
SH = randperm(row*col); %生成大小为row*col的伪随机序列
[reshuffle_I] = Image_ReShuffle(ES_I,SH);
%% 在图像的LSB位平面提取压缩空间大小
num = ceil(log2(row))+ceil(log2(col))+3; %记录净压缩空间大小需要的比特数（+3代表最大嵌入率不超过8bpp）
bits_room = zeros(1,num); %记录空间大小的比特流
for i=1:num  %将空出空间大小记录在图像最低位平面的最后一行的最后num比特
    j = col-num+i; %净空间记录的纵坐标
    value = reshuffle_I(row,j);
    bit = mod(value,2);
    bits_room(i) = bit;
end
[total_Room] = BinaryConversion_2_10(bits_room);
%% 根据数据嵌入密钥K_hide对原始秘密信息D进行加密
[encrypt_D] = Data_Encrypt(D,K_hide);
%% 在空出的空间中嵌入秘密信息
marked_I = reshuffle_I;
num_D = length(D);
num_emD = 0; %计数，嵌入秘密信息数
for pl=1:8 
    if num_emD==num_D || num_emD==total_Room %秘密信息已嵌完||已达到最大嵌入量
        break;
    end
    index = 8-pl+1; %像素第pl个位平面的索引
    for i=row:-1:1  %从后往前嵌入，保证最后的压缩空间不会混淆
        for j=col:-1:1
            if num_emD==num_D || num_emD==total_Room %秘密信息已嵌完||已达到最大嵌入量
                break;
            end
            value = marked_I(i,j); %当前像素值
            [bin2_8] = BinaryConversion_10_2(value); %转换成8位二进制
            num_emD = num_emD+1;
            bin2_8(index) = encrypt_D(num_emD);
            [value] = BinaryConversion_2_10(bin2_8);
            marked_I(i,j) = value; %含有秘密信息的像素值
        end
    end
end
%% 将含有秘密信息的标记图像marked_I进行混洗
rand('seed',K_sh); %设置种子
SH = randperm(row*col); %生成大小为row*col的伪随机序列
[stego_I] = Image_Shuffle(marked_I,SH);
%% 统计嵌入的秘密信息
emD = D(1:num_emD);
end