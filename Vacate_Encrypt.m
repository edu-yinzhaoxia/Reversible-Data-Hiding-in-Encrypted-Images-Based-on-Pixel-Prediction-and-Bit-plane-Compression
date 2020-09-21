function [ES_I,num_Of,PL_len,PL_room,total_Room] = Vacate_Encrypt(origin_I,Block_size,L_fix,L,K_en,K_sh)
% 函数说明：空出图像空间并加密原始图像，得到空出嵌入空间的加密图像
% 输入：origin_I（原始图像）,Block_size（分块大小）,L_fix（定长编码参数）,L（相同比特流长度参数）,K_en（图像加密密钥）,K_sh（图像混洗密钥）
% 输出：ES_I（压缩之后的加密混洗图像）,Overflow（溢出预测误差的位置信息）,PL_len（各个位平面压缩比特流的长度）,PL_room（各位平面压缩空间大小）,total_Room（净压缩空间）

[row,col] = size(origin_I); %计算origin_I的行列值
num = ceil(log2(row))+ceil(log2(col))+3; %记录净压缩空间大小需要的比特数（+3代表最大嵌入率不超过8bpp）
%% 计算原始图像origin_I的预测误差图像
[PE_I,num_Of,Overflow] = Prediction_Error(origin_I);
%% 在预测误差图像PE_I中空出可以嵌入秘密信息的空间
[vacate_I,PL_len,PL_room,total_Room] = Vacate_Room(PE_I,Block_size,L_fix,L,num_Of,Overflow);
%% 根据图像加密密钥K_en加密图像vacate_I
rand('seed',K_en); %设置种子
E = round(rand(row,col)*255); %生成大小为row*col的伪随机数矩阵
encrypt_I = vacate_I;
for i=1:row  %根据伪随机数矩阵E对图像vacate_I进行bit级加密
    for j=1:col
        encrypt_I(i,j) = bitxor(vacate_I(i,j),E(i,j));
    end
end
%% 净载荷空间大于num的情况下才进行记录（代表有压缩空间）
transition_I = encrypt_I;
if total_Room>=num %需要num比特记录净压缩空间大小
    %% 将净压缩空间大小转换成二进制数组 
    bits_room = zeros(1,num);
    bin2_room = dec2bin(total_Room)-'0';
    len = length(bin2_room);
    bits_room(num-len+1:num) = bin2_room;
    %% 在图像的LSB位平面最后num比特记录净压缩空间大小(bits_room)
    for i=1:num %将空出空间大小记录在图像最低位平面的最后一行的最后num比特
        j = col-num+i; %净空间记录的纵坐标
        value = transition_I(row,j);
        bit = bits_room(i);
        value_1 = (floor(value/2))*2 + bit;
        transition_I(row,j) = value_1;
    end  
end
%% 根据图像混洗密钥K_sh混洗图像transition_I（提高安全性）
rand('seed',K_sh); %设置种子
SH = randperm(row*col); %生成大小为row*col的伪随机序列
[shuffle_I] = Image_Shuffle(transition_I,SH);
%% 记录含有嵌入空间的加密混洗图像
ES_I = shuffle_I;
