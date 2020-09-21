function [origin_bits] = BitPlanes_Rearrange(Plane,Block_size,type)
% 函数说明：根据BMPR算法重排列位平面矩阵Plane
% 输入：Plane（位平面矩阵）,Block_size（分块大小）,type（重排列方式）
% 输出：origin_bits（重排列之后的位平面比特流）

[row,col] = size(Plane);
m = floor(row/Block_size); %m*n完整分块的个数
n = floor(col/Block_size);
origin_bits = zeros(); %用来记录位平面重排列的比特流
num = 0; %计数
%-------------------分块内按行遍历，分块间按行遍历（行-行）------------------%
if type==0 %0→00
    for i=1:m  %分块之间按行遍历
        for j=1:n
            begin_x = (i-1)*Block_size+1; %对应分块的起始坐标
            begin_y = (j-1)*Block_size+1;
            end_x = i*Block_size; %对应分块的结束坐标
            end_y = j*Block_size;
            for x=begin_x:end_x  %分块之内按行遍历
                for y=begin_y:end_y
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end 
        end
        if col-n*Block_size>=1  %有剩余列
            begin_y = n*Block_size+1;
            end_y = col;
            for x=begin_x:end_x  %分块之内按行遍历
                for y=begin_y:end_y
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end
        end  
    end
    if row-m*Block_size>=1 %有剩余行
        begin_x = m*Block_size+1; 
        end_x = row;
        for j=1:n
            begin_y = (j-1)*Block_size+1;
            end_y = j*Block_size;
            for x=begin_x:end_x  %分块之内按行遍历
                for y=begin_y:end_y
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end  
        end  
    end
    if row-m*Block_size>=1 && col-n*Block_size>=1 %最后的剩余行列
        begin_x = m*Block_size+1;
        begin_y = n*Block_size+1;
        end_x = row;
        end_y = col;
        for x=begin_x:end_x  %分块之间按行遍历
            for y=begin_y:end_y
                num = num+1;
                origin_bits(num) = Plane(x,y);
            end
        end  
    end
%-------------------分块内按行遍历，分块间按列遍历（行-列）------------------%
elseif type==1 %1→01
    for j=1:n  %分块之间按列遍历
        for i=1:m
            begin_x = (i-1)*Block_size+1; %对应分块的起始坐标
            begin_y = (j-1)*Block_size+1;
            end_x = i*Block_size; %对应分块的结束坐标
            end_y = j*Block_size;
            for x=begin_x:end_x  %分块之内按行遍历
                for y=begin_y:end_y
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end 
        end
        if row-m*Block_size>=1  %有剩余行
            begin_x = m*Block_size+1;
            end_x = row;
            for x=begin_x:end_x  %分块之内按行遍历
                for y=begin_y:end_y
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end
        end  
    end
    if col-n*Block_size>=1 %有剩余列
        begin_y = n*Block_size+1; 
        end_y = col;
        for i=1:m
            begin_x = (i-1)*Block_size+1;
            end_x = i*Block_size;
            for x=begin_x:end_x  %分块之内按行遍历
                for y=begin_y:end_y
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end  
        end  
    end
    if row-m*Block_size>=1 && col-n*Block_size>=1 %最后的剩余行列
        begin_x = m*Block_size+1;
        begin_y = n*Block_size+1;
        end_x = row;
        end_y = col;
        for x=begin_x:end_x  %分块之间按行遍历
            for y=begin_y:end_y
                num = num+1;
                origin_bits(num) = Plane(x,y);
            end
        end  
    end
%-------------------分块内按列遍历，分块间按行遍历（列-行）------------------%
elseif type==2 %2→10
    for i=1:m  %分块之间按行遍历
        for j=1:n
            begin_x = (i-1)*Block_size+1; %对应分块的起始坐标
            begin_y = (j-1)*Block_size+1;
            end_x = i*Block_size; %对应分块的结束坐标
            end_y = j*Block_size; 
            for y=begin_y:end_y  %分块之内按列遍历
                for x=begin_x:end_x  
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end 
        end
        if col-n*Block_size>=1  %有剩余列
            begin_y = n*Block_size+1;
            end_y = col;
            for y=begin_y:end_y  %分块之内按列遍历
                for x=begin_x:end_x  
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end 
        end  
    end
    if row-m*Block_size>=1 %有剩余行
        begin_x = m*Block_size+1; 
        end_x = row;
        for j=1:n
            begin_y = (j-1)*Block_size+1;
            end_y = j*Block_size;
            for y=begin_y:end_y  %分块之内按列遍历
                for x=begin_x:end_x  
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end   
        end  
    end
    if row-m*Block_size>=1 && col-n*Block_size>=1 %最后的剩余行列
        begin_x = m*Block_size+1;
        begin_y = n*Block_size+1;
        end_x = row;
        end_y = col;
        for y=begin_y:end_y  %分块之内按列遍历
            for x=begin_x:end_x  
                num = num+1;
                origin_bits(num) = Plane(x,y);
            end
        end   
    end
%-------------------分块内按列遍历，分块间按列遍历（列-列）------------------%
else %type==3，3→11
    for j=1:n  %分块之间按列遍历
        for i=1:m
            begin_x = (i-1)*Block_size+1; %对应分块的起始坐标
            begin_y = (j-1)*Block_size+1;
            end_x = i*Block_size; %对应分块的结束坐标
            end_y = j*Block_size;
            for y=begin_y:end_y  %分块之内按列遍历
                for x=begin_x:end_x  
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end  
        end
        if row-m*Block_size>=1  %有剩余行
            begin_x = m*Block_size+1;
            end_x = row;
            for y=begin_y:end_y  %分块之内按列遍历
                for x=begin_x:end_x  
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end
        end  
    end
    if col-n*Block_size>=1 %有剩余列
        begin_y = n*Block_size+1; 
        end_y = col;
        for i=1:m
            begin_x = (i-1)*Block_size+1;
            end_x = i*Block_size;
            for y=begin_y:end_y  %分块之内按列遍历
                for x=begin_x:end_x  
                    num = num+1;
                    origin_bits(num) = Plane(x,y);
                end
            end  
        end  
    end
    if row-m*Block_size>=1 && col-n*Block_size>=1 %最后的剩余行列
        begin_x = m*Block_size+1;
        begin_y = n*Block_size+1;
        end_x = row;
        end_y = col;
        for y=begin_y:end_y  %分块之内按列遍历
            for x=begin_x:end_x  
                num = num+1;
                origin_bits(num) = Plane(x,y);
            end
        end  
    end 
end