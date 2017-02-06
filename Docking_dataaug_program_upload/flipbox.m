function flippedbox= flipbox( box,imgw,imgh )
%box is defined by lefttop point and rightdown point
%   
  boxw=abs(box(1)-box(3))+1;
  boxh=abs(box(4)-box(2))+1;
  righttop=[box(1)+boxw-1 box(2)];
  leftdown=[box(1) box(4)];
  flippedbox=[imgw-righttop(1) righttop(2) imgw-leftdown(1) leftdown(2)];

end

