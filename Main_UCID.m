clear
clc
%% 产生二进制秘密数据
num_D = 2100000;
rand('seed',0); %设置种子
D = round(rand(1,num_D)*1); %产生稳定随机数
%% 图像数据集信息(ucid.v2),格式:TIFF,数量:1338；
I_file_path = 'D:\ImageDatabase\ucid.v2\'; %测试图像数据集文件夹路径
I_path_list = dir(strcat(I_file_path,'*.tif')); %获取该文件夹中所有tif格式的图像
img_num = length(I_path_list); %获取图像总数量
%% 记录每张图像的的相关信息
num_UCID = zeros(1,img_num); %记录每张图像的嵌入量 
bpp_UCID = zeros(1,img_num); %记录每张图像的嵌入率
over_UCID = zeros(1,img_num);%记录每张图像的溢出像素个数
room_UCID = zeros(8,img_num);%记录每张图像各个位平面的压缩空间
len_UCID = zeros(8,img_num); %记录每张图像各个位平面的压缩比特流长度
%% 设置密钥
K_en = 1; %图像加密密钥
K_sh = 2; %图像混洗密钥
K_hide=3; %数据嵌入密钥
%% 设置参数
Block_size = 4; %分块大小（存储分块大小的比特数需要调整，目前设为4bits）
L_fix = 3; %定长编码参数
L = 4; %相同比特流长度参数,方便修改
%% 图像数据集测试
ERROR = 0; %计数，统计无法存储信息的图像数
for i=1:img_num
    %-------------------------------读取图像-------------------------------%
    I_name = I_path_list(i).name; %图像名
    I = imread(strcat(I_file_path,I_name));%读取图像
    origin_I = double(I);
    %----------------空出图像空间并加密混洗图像（内容所有者）----------------%
    [ES_I,num_Of,PL_len,PL_room,total_Room] = Vacate_Encrypt(origin_I,Block_size,L_fix,L,K_en,K_sh);
    %--------净载荷空间大于num的情况下才进行数据嵌入（代表有压缩空间）--------%
    [row,col] = size(origin_I); %计算origin_I的行列值
    num = ceil(log2(row))+ceil(log2(col))+2; %记录净压缩空间大小需要的比特数
    if total_Room>=num %需要num比特记录净压缩空间大小
        %---------------在加密混洗图像中嵌入数据（数据嵌入者）---------------%
        [stego_I,emD] = Data_Embed(ES_I,K_sh,K_hide,D); 
        num_emD = length(emD);
        %-----------------在载密图像中提取秘密信息（接收者）-----------------%
        [exD] = Data_Extract(stego_I,K_sh,K_hide,num_emD);
        %-----------------------恢复载密图像（接收者）----------------------%
        [recover_I] = Image_Recover(stego_I,K_en,K_sh);
        %-----------------------------结果记录-----------------------------%
        [m,n] = size(origin_I);
        num_UCID(i) = num_emD;
        bpp_UCID(i) = num_emD/(m*n);
        over_UCID(i) = num_Of; %记录溢出预测误差个数
        for pl=1:8 %记录图像位平面压缩长度和压缩空间
            len_UCID(pl,i) = PL_len(pl);
            room_UCID(pl,i) = PL_room(pl);
        end
        %-----------------------------结果判断-----------------------------%
        check1 = isequal(emD,exD);
        check2 = isequal(origin_I,recover_I);
        if check1 == 1  
            disp('提取数据与嵌入数据完全相同！')
        else
            disp('Warning！数据提取错误！')
        end
        if check2 == 1
            disp('重构图像与原始图像完全相同！')
        else
            disp('Warning！图像重构错误！')
        end
        %-----------------------------结果输出-----------------------------%
        if check1 == 1 && check2 == 1
            bpp = bpp_UCID(i);
            disp(['Embedding capacity equal to : ' num2str(num_emD)])
            disp(['Embedding rate equal to : ' num2str(bpp)])
            fprintf(['第 ',num2str(i),' 幅图像-------- OK','\n\n']);
        else
            ERROR = ERROR+1;
            if check1 ~= 1 && check2 == 1
                bpp_UCID(i) = -1; %表示提取数据不正确
            elseif check1 == 1 && check2 ~= 1
                bpp_UCID(i) = -2; %表示图像恢复不正确
            else
                bpp_UCID(i) = -3; %表示提取数据和恢复图像都不正确
            end
            fprintf(['第 ',num2str(i),' 幅图像-------- ERROR','\n\n']);
        end 
    else %该图像太复杂，溢出预测误差太多，导致辅助信息大于压缩空间
        ERROR = ERROR+1;
        num_UCID(i) = -1; %表示不能嵌入秘密信息
        over_UCID(i) = num_Of; %记录溢出预测误差个数
        for pl=1:8 %记录图像位平面压缩长度和压缩空间
            len_UCID(pl,i) = PL_len(pl);
            room_UCID(pl,i) = PL_room(pl);
        end
        disp('辅助信息大于压缩空间（净压缩空间小于0），导致无法存储数据！') 
        fprintf(['该测试图像------------ ERROR','\n\n']);
    end  
end
%% 保存数据
% save('num_UCID')
% save('bpp_UCID')
% save('over_UCID')
% save('room_UCID')
% save('len_UCID')