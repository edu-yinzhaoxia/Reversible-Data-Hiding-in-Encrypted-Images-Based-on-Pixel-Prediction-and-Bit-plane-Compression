function [vacate_I,PL_len,PL_room,total_Room] = Vacate_Room(PE_I,Block_size,L_fix,L,num_Of,Overflow)
% 函数说明：利用BMPR算法压缩原始图像，以空出可以嵌入秘密信息的空间
% 输入：PE_I（预测误差图像）,Block_size（分块大小）,L_fix（定长编码参数）,L（相同比特流长度参数）,num_Of（溢出预测误差个数）,Overflow（溢出信息）
% 输出：vacate_I（空出空间的图像）,PL_len（各个位平面压缩比特流的长度）,PL_room（各个位平面的压缩空间）,total_Room（净压缩空间）

[row,col] = size(PE_I); %计算PE_I的行列值
num = ceil(log2(row)) + ceil(log2(col));
%% 统计需要记录的辅助信息（相关参数，溢出信息）
Side = zeros(); %用来记录辅助信息
num_Side = 0; %计数
%---------------------记录相关参数（Block_size,L_fix）---------------------%
[bin28_Bs] = BinaryConversion_10_2(Block_size); %将分块大小Block_size转换成8位二进制
Side(num_Side+1:num_Side+4) = bin28_Bs(5:8); %用4bit表示分块大小Block_size
num_Side = num_Side + 4;
[bin28_Lf] = BinaryConversion_10_2(L_fix); %将参数L_fix转换成8位二进制
Side(num_Side+1:num_Side+3) = bin28_Lf(6:8); %用3bit表示参数L_fix
num_Side = num_Side + 3;
%---------------------------记录溢出预测误差信息----------------------------%
len_num_Of = zeros(1,num); %用num比特表示溢出预测误差个数
bin2_num_Of = dec2bin(num_Of)-'0'; %将溢出预测误差个数转换成二进制
len = length(bin2_num_Of);
len_num_Of(num-len+1:num) = bin2_num_Of;
Side(num_Side+1:num_Side+num) = len_num_Of; %用num比特表示溢出预测误差个数
num_Side = num_Side + num;    
if num_Of>0
    for i=1:num_Of
        x = Overflow(1,i); 
        y = Overflow(2,i);
        pos = (x-1)*col + y; %溢出预测误差的位置
        len_pos = zeros(1,num); %用num比特表示溢出预测误差的位置
        bin2_pos = dec2bin(pos)-'0'; %将溢出预测误差的位置转换成二进制
        len = length(bin2_pos);
        len_pos(num-len+1:num) = bin2_pos;
        Side(num_Side+1:num_Side+num) = len_pos; %用num比特表示溢出预测误差的位置
        num_Side = num_Side + num; 
    end
end
%% 构建容器：存储图像的最终压缩比特流及相关辅助信息
Image_Bits = zeros(); 
t = 0; %计数
Image_Bits(t+1:t+num_Side) = Side; %存储辅助信息
t = t+num_Side;
%% 从高到低依次压缩图像的位平面比特流（8:MSB→1:LSB）
PL_room = zeros(1,8); %用来记录位平面压缩后空出的空间大小
PL_len = zeros(1,8); %用来记录位平面压缩后的位平面比特流长度
num_pl = 0; %用来记录可压缩位平面数
for pl=8:-1:1 %MSB→LSB
    %% ----------------------提取第pl个位平面----------------------%
    [Plane] = BitPlanes_Extract(PE_I,pl);
    %% ----------------------压缩第pl个位平面----------------------%
    [CBS,type] = BitPlanes_Compress(Plane,Block_size,L_fix,L);
    %% -------------------记录最终的位平面比特流--------------------%
    len_CBS = length(CBS); %压缩位平面比特流的长度
    len_comp_PL = len_CBS+num+2+1; %压缩位平面的最终长度（+num:压缩比特流长度信息，+2:位平面重排列方式，+1：压缩标记）
    if len_comp_PL <= row*col %判断第pl个位平面是否可以压缩，即压缩长度要小于原始长度
        %---------------------记录位平面的压缩标记（1 bit）-----------------%
        num_pl = num_pl+1;
        Image_Bits(t+1) = 1; %1表示该位平面可以压缩
        t = t+1;
        %----------------记录位平面的重排列方式type（2 bit）----------------%
        bin2_type = dec2bin(type)-'0'; %将位平面重排列方式转换成二进制
        if length(bin2_type) == 1  %位平面重排列方式用2bit表示
            tem = bin2_type(1);
            bin2_type(1) = 0;
            bin2_type(2) = tem;   
        end
        Image_Bits(t+1:t+2) = bin2_type; %存储当前位平面的重排列方式
        t = t+2;
        %----------------记录位平面压缩比特流CBS及其长度信息-----------------%
        len_CBS_bits = zeros(1,num); 
        bin2_len_CBS = dec2bin(len_CBS)-'0'; %将压缩位平面比特流的长度信息转换成二进制
        len = length(bin2_len_CBS);
        len_CBS_bits(num-len+1:num) = bin2_len_CBS;
        Image_Bits(t+1:t+num) = len_CBS_bits; %用num比特来表示压缩位平面比特流的长度
        t = t + num;
        Image_Bits(t+1:t+len_CBS) = CBS; %记录压缩位平面比特流
        t = t + len_CBS;
        %-------------记录该位平面比特流的压缩长度及空出的空间大小------------%
        PL_len(pl) = len_CBS;
        room = row*col - len_comp_PL; %空出的空间大小
        PL_room(pl) = room; 
    else
        Image_Bits(t+1) = 0; %0表示该位平面不可压缩
        t = t+1;
        T_Plane = Plane'; %将矩阵转置,保证最终的比特流是按行遍历的
        PL_bits = reshape(T_Plane,1,row*col);%将Plane转换成一维矩阵，按列遍历 
        Image_Bits(t+1:t+row*col) = PL_bits; %记录原始比特流
        t = t + row*col;
    end
end
%% 将最终的位平面比特流放回原始图像中
vacate_I = PE_I;
num_t = 0; %计数
for pl=8:-1:1
    re = t - num_t; %剩余的压缩图像比特流
    if re >= row*col    
        PL_bits = Image_Bits(num_t+1:num_t+row*col); %最终位平面比特流
        num_t = num_t + row*col;
    else
        PL_bits = zeros(1,row*col);
        PL_bits(1:re) = Image_Bits(num_t+1:num_t+re); %嵌入剩下的比特流
        num_t = num_t+re;    
    end
    Plane = reshape(PL_bits,col,row); %换成矩阵,以列排序
    T_Plane = Plane'; %将矩阵转置
    [RI] = BitPlanes_Embed(vacate_I,T_Plane,pl); %将最终位平面矩阵放回图像中
    vacate_I = RI;
end
%% 计算总压缩空间大小
total_Room = row*col*8 - t; %总比特数减去存储压缩比特流数目及辅助信息
end
