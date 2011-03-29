close all;
load ../3dObjModels/Walls.mat

%for wall=1:3:12
for wall=1:12
	X = []
	Y = []
	Z = []
	for coord=1:3:12
		X = [X;WALLS(wall,coord)]
		Y = [Y;WALLS(wall,coord+1)]
		Z = [Z;WALLS(wall,coord+2)]
	end
	C = ones(1,4)
	fill3(X,Y,Z,C)
	hold on;
	pause;
end
%C = ones(1,12*4)


