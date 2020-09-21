function P=GetHis(I)
P=zeros(1,256);
for i=1:numel(I)
    P(I(i)+1)=P(I(i)+1)+1;
end
% plot(P);