% this file extract rectangles based on hough transform
%
% new plan
% transform edge image to rectangular image
%	apply hough rectangul detection based on hough transform (paper)
% make dummy image where some rectangles are present

% compose mail to frans with results send on sunday
% other dataset
% a priori theta ratio 
	% for vertical and horizontal lines differently
% perform hough on rotated image
% unrotate results
% set results in unrotated image
% houghlines must be spread
% unblurr or something like that to make edgelines more thick
% apply a houghline length range (max and min), 
% use a height-width ratio for windows
% transform edge image to rectangular image
% detect cornerpoints by houghline intersection
% 	detect exact intersections
% 	stretch exact intersection by making all lines just a little bit longer
%		search old paper for auto connect line parts
% play with a (harris?) cornerdetector
% read paper about implicite shape of window
%	use assumptions, like average width height ratio of the window
%
% report: say something about angle interval that should depend on height in image but doesnt


close all;
tic;
imNr = 5435; file = sprintf('../dataset/FloriandeSet1/medium/undist__MG_%d.jpg', imNr); load('XYangleFilter_floriande_5447.mat');
%imNr = 5447; file = sprintf('../dataset/FloriandeSet1/medium/undist__MG_%d.jpg', imNr); load('XYangleFilter_floriande_5447.mat');
%imNR = 6; file = sprintf('../dataset/datasetSpil/datasetSpilRect/P_rect6.jpg')
% imNr = 6680; file = sprintf('../dataset/fullDatasets/aalsmeer/undist__MG_%d.jpg', imNr); load('XYangleFilter_aalsmeer6680.mat');


plotme							= 1;
savePath 						= 'results/';
%fileShort 						= 'aalsmeer6680';
fileShort 						= 'floriande5435';
colorModel						= 'HSV_Vchannel';
%colorModel						= 'RGB';
HSVmode							= true;
% rotates image 90 degrees clockwise
edgeDetectorParam.type 			= 'canny';
loadEdgeFromCache 				= true;
%edgeDetectorParam.typePost 		= 'vertical_horizontal_Combined';
edgeDetectorParam.typePost 		= '';
%edgeDetectorParam.thresh		= 0.50;%0.45
edgeDetectorParam.thresh		= 0.55;%0.45
% perform different threshold test?
edgeTest 						= 0;
HoughParam.ThetaStretchAngle	= 30;
HoughParam.ThetaStart 			= 0;
HoughParam.ThetaStart 			= HoughParam.ThetaStart - HoughParam.ThetaStretchAngle;
HoughParam.ThetaEnd 			= 0;
HoughParam.ThetaEnd 			= HoughParam.ThetaEnd + HoughParam.ThetaStretchAngle;
HoughParam.ThetaResolution  	= 0.5;
HoughParam.thresh 				= 0;
% sets the max nr of lines hough finds:
HoughParam.nrPeaks 				= 200;
%HoughParam.fillGap 			= 30;
% the bigger this value the more lines are found
HoughParam.fillGap 				= 10;

% select smallest windowglas width from left to right
%[Xwin,Ywin] = ginput(2); XYwin1 = [Xwin(1),Ywin(1)]; XYwin2 = [Xwin(2),Ywin(2)];norm(XYwin1,XYwin2)
HoughParam.minLength 			= 45; 

% todo transfer to sprintf 
paramStr = ['src_',fileShort,'_colorModel_',colorModel,'__edgeDetectorParams_',edgeDetectorParam.type,edgeDetectorParam.typePost,'_thresh_',num2str(edgeDetectorParam.thresh),'__HoughParams_', 'thresh_',num2str(HoughParam.thresh) , '_nrPeaks_',num2str(HoughParam.nrPeaks) , '_fillGap_',num2str(HoughParam.fillGap) , '_minLength_',num2str(HoughParam.minLength),'__ThetaRange',num2str(HoughParam.ThetaStart),':',num2str(HoughParam.ThetaResolution),':',num2str(HoughParam.ThetaEnd),'.png'];

if loadEdgeFromCache == false
	imRGB = imread(file);
	if(HSVmode)
		imHSV = rgb2hsv(imRGB);
		imBW     = imHSV(:,:,3);
	else
		%imBW = imRGB(:,:,3);
		imBW = imadjust(rgb2gray(imRGB));
		%fgRGB = figure();imshow(imRGB);
	end
end
%fgBW = figure();imshow(imBW);
h = size(imBW,1);


load('XYcropRegionFloriande5435.mat');
imBW = cropImage(imBW, X,Y);
figure; imshow(imBW)

if edgeTest
	for thresh=0.1:0.05:0.8
		thresh
		imEdge = im2double(edge(imBW, edgeDetectorParam.type, thresh));
		figure(round(thresh*100));
		imshow(imEdge);
	end
	error('edge test done, ending program')
end

% EDGE DETECTION 
if loadEdgeFromCache == false
	imEdge = im2double(edge(imBW, edgeDetectorParam.type, edgeDetectorParam.thresh));
end
fgEdge = figure();imshow(imEdge);



fgHough = figure();imshow(imEdge);hold on

% HOUGHLINES:
[H,Theta,Rho] = hough(imEdge,'Theta',HoughParam.ThetaStart:HoughParam.ThetaResolution:HoughParam.ThetaEnd);
Peaks  = houghpeaks(H,HoughParam.nrPeaks,'threshold',ceil(HoughParam.thresh*max(H(:))));
x = Theta(Peaks(:,2)); y = Rho(Peaks(:,1));
Houghlines = houghlines(imEdge,Theta,Rho,Peaks,'FillGap',HoughParam.fillGap,'MinLength',HoughParam.minLength);
%Houghlines = addLengthToHoughlines(Houghlines);

for k = 1:length(Houghlines)
	xy = [Houghlines(k).point1; Houghlines(k).point2];
	plotHoughline(xy, plotme,'green')
end


% HOUGHLINES ROTATED (HORIZONTAL):
if loadEdgeFromCache == false
	imEdgeRot    = rot90(imEdge,-1);
end
[H,Theta,Rho] = hough(imEdgeRot,'Theta',HoughParam.ThetaStart:HoughParam.ThetaResolution:HoughParam.ThetaEnd);
Peaks  = houghpeaks(H,HoughParam.nrPeaks,'threshold',ceil(HoughParam.thresh*max(H(:))));
x = Theta(Peaks(:,2)); y = Rho(Peaks(:,1));
Houghlines = houghlines(imEdgeRot,Theta,Rho,Peaks,'FillGap',HoughParam.fillGap,'MinLength',HoughParam.minLength);
%Houghlines = addLengthToHoughlines(Houghlines);

for k = 1:length(Houghlines)
	%xy = [Houghlines(k).point1; Houghlines(k).point2];
	% TODO get xy from Theta(..) above, calc as matrix
	xy = [invertCoordFlipY(Houghlines(k).point2,h); invertCoordFlipY(Houghlines(k).point1,h)];
	plotHoughline(xy, plotme,'red')
end


toc;
reply = input('Save result as images? y/n [n]: ', 's');
if isempty(reply)
	reply = 'n';
end
if reply=='y'
	disp('saving images..');
	% save images
	%saveas(fgBW,[savePath,'result_raw__',paramStr],'png');
	saveas(fgEdge,[savePath,'result_edge__',paramStr],'png');
	saveas(fgHough,[savePath,'result_hough__',paramStr],'png');
	disp('done');
end



% OLD CODE:
%
% FILTER HOUGHLINES
% 1---2
% |   |
% 4---3
% '../dataset/FloriandeSet1/medium/undist__MG_%d.jpg', 5432
% X = [679.5000, 871.5000, 871.5000, 677.5000];
% Y = [185.5000, 301.5000, 675.5000, 699.5000];
% use [X,Y] =  ginput(4) and store XY in a mat format
% calculates the angle of the upper and bottom wallline segment
% (in orde to provide the angle interval)
% theta1 = calcHoughTheta(X(1),Y(1),X(2),Y(2),h)
% theta2 = calcHoughTheta(X(3),Y(3),X(4),Y(4),h)
