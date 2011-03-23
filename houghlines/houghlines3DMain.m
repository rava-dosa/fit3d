startPath = 'C:/Temp/tkosteli/fit3d/'
path(path,startPath);
path(path,[startPath, 'fit3d_includes']);

% todo give PcamX to function as a param
% if workspace vars are not loaded
if exist('PcamX') == 0
	disp('load PcamX and Walls');
	load '../mats/outputVars_scriptComputeCameraMotion.mat'
	load '../mats/WALLS.mat'
end


houghEndpointsFileName 	= 'hough-endpoints.obj';
houghLinesFileName     	= 'hough-lines.obj';
% flush and instantiate files
fp = fopen(houghEndpointsFileName, 'w'); fclose(fp);
fp = fopen(houghLinesFileName    , 'w'); fclose(fp);

imNr 					= 1;
load 					'imBWSkyline1.mat';
lines 					= houghlinesMain(imBWSkyline)


% loop through found houghlines endpoints and project to 3D
for i=1:length(lines)
	HoughLineEndpoint1 = get3Dfrom2D(lines(i).point1', imNr, PcamX,Kcanon10GOOD, WALLS);
	HoughLineEndpoint2  = get3Dfrom2D(lines(i).point2', imNr, PcamX,Kcanon10GOOD, WALLS);
	writeObjCube(houghEndpointsFileName, 1, HoughLineEndpoint1, 0.1);
	writeObjCube(houghEndpointsFileName, 1, HoughLineEndpoint2, 0.1);
	writeObjLineThick(houghLinesFileName, HoughLineEndpoint1,HoughLineEndpoint2,'black', 1);
end


