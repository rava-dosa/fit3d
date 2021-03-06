%function hibaapclassifyRectangles(Dataset,saveImage);
% RECTANGLE CLASSIFICATION

% load hibaap values

% clear;
% cd ..
% setup
% cd doorWindow
% 
saveImage = true;
savePath 						= ['resultsHibaap/',Dataset.fileShort,'/'];
% %Dataset.fileShort='Ort1'
% %Dataset.fileShort='OrtCrop1'
% Dataset.fileShort='Spil1TransCrop1';
% load([startPath,'/doorWindow/mats/Dataset_',Dataset.fileShort,'_hibaap.mat']);
% 
% if exist('Dataset')==0
% 	error('tj:Dataset not loaded')
% end

%fgHough = figure();imshow(Dataset.ImReader.imOriDimmed); hold on;
%plotHoughlinesAll(Dataset.ImReader.imHeight,Dataset.HoughResult.Houghlines,Dataset.HoughResult.HoughlinesRot);
[Dataset.HoughResult.V.LinesIm,Dataset.HoughResult.H.LinesIm] = houghlinesToImOrt(Dataset,0)

% show image
%fgPeaklines = figure();imshow(Dataset.ImReader.imEdge);hold on;
%plotHoughlinesAll(Dataset.ImReader.imHeight,Dataset.HoughResult.Houghlines,Dataset.HoughResult.HoughlinesRot);
%plotPeakLines(Dataset);

% add origin and endpoint to peak array so it can be used as a range
XvHistMaxPeaks = [1,Dataset.Hibaap.XvHistMaxPeaks, Dataset.ImReader.imWidth];
YhHistMaxPeaks = [1,Dataset.Hibaap.YhHistMaxPeaks,Dataset.ImReader.imHeight];

% declare vars
tempIm = zeros(Dataset.ImReader.imHeight,Dataset.ImReader.imWidth,1);
imHoughPxCountX = tempIm;
imHoughPxCountY = tempIm;


% SUM UP HOUGHLINE PICS 
% loop through vertical strokes
for i=2:length(XvHistMaxPeaks)
	x1 = XvHistMaxPeaks(i-1); x2 = XvHistMaxPeaks(i);
	houghStroke	= Dataset.HoughResult.H.LinesIm(:,x1:x2);
	houghStrokeTotal= sum(sum(houghStroke));
	houghStrokeNorm=houghStrokeTotal/(size(houghStroke,1)*size(houghStroke,2));
	imHoughPxCountX(:,x1:x2) = houghStrokeNorm;
	WindowsColVote(i) = houghStrokeNorm;
end
% loop through horizontal strokes
for j=2:length(YhHistMaxPeaks)
	y1 = YhHistMaxPeaks(j-1); y2 = YhHistMaxPeaks(j);
	houghStroke	= Dataset.HoughResult.V.LinesIm(y1:y2,:);
	houghStrokeTotal= sum(sum(houghStroke));
	houghStrokeNorm=houghStrokeTotal/(size(houghStroke,1)*size(houghStroke,2));
	imHoughPxCountY(y1:y2,:) = houghStrokeNorm;
	WindowsRowVote(j) = houghStrokeNorm;
end

figure;
barh(WindowsRowVote/max(WindowsRowVote))
export_fig -eps w_Spil1TransCrop1_ImClassRectBarh.eps
pause;
%figure;
%bar(WindowsColVote/max(WindowsColVote))
%export_fig -eps w_Spil1TransCrop1_ImClassRectBar.eps
figure;

% CLUSTERING hough 
% use 2 clusters and transfor 211121 into 100010
[WindowsColVoteBin, Clusters] = kmeans(WindowsColVote,2);
[t_, maxClusterIdx] = max(Clusters);
% set a 1 at the clusters associated with highest bin
WindowsColVoteBin = WindowsColVoteBin'==maxClusterIdx;

[WindowsRowVoteBin, Clusters] = kmeans(WindowsRowVote,2);
[t_, maxClusterIdx] = max(Clusters);
WindowsRowVoteBin = WindowsRowVoteBin'==maxClusterIdx;


% PLOT VERTICAL HOUGHLINE amounts
fgimHoughLinesImV = figure();imshow(imdilate(Dataset.HoughResult.V.LinesIm,ones(5,5))); hold on;
voteGraphWidth = (Dataset.ImReader.imWidth/10); voteGraphFactor = voteGraphWidth/max(WindowsRowVote);
for j=2:length(WindowsRowVote)
	y1 = YhHistMaxPeaks(j-1); y2 = YhHistMaxPeaks(j);
	x = voteGraphFactor*WindowsRowVote(j);
	if WindowsRowVoteBin(j)
		%plot([x,x],[y1,y2],'g-','lineWidth', 3);
		fill([0,x,x,0,0],[y1,y1,y2,y2,y1], 'g');
	else
		%plot([x,x],[y1,y2],'r-','lineWidth', 3);
		fill([0,x,x,0,0],[y1,y1,y2,y2,y1], 'r');
	end
end
% PLOT HORIZONTAL HOUGHLINE amounts
fgimHoughLinesImH = figure();imshow(imdilate(Dataset.HoughResult.H.LinesIm,ones(5,5))); hold on;
h=Dataset.ImReader.imHeight;
voteGraphHeight = (Dataset.ImReader.imHeight/10); voteGraphFactor = voteGraphHeight/max(WindowsColVote);
for i=2:length(WindowsColVote)
	x1 = XvHistMaxPeaks(i-1); x2 = XvHistMaxPeaks(i);
	y = (Dataset.ImReader.imHeight-(voteGraphFactor*WindowsColVote(i)));
	if WindowsColVoteBin(i)
		%plot([x1,x2],[y,y],'g-','lineWidth', 3);
		fill([x1,x1,x2,x2,x1],[h,y,y,h,h], 'g');
	else
		%plot([x1,x2],[y,y],'r-','lineWidth', 3);
		fill([x1,x1,x2,x2,x1],[h,y,y,h,h], 'r');
	end
end


% drawing the windows
fgimWindows=figure();imshow(Dataset.ImReader.imOriDimmed);hold on;

% plot small green windows
for i=2:length(XvHistMaxPeaks)
	%WindowsColVote(i)
	for j=2:length(YhHistMaxPeaks)
		%WindowsColVote(j)
		X = [XvHistMaxPeaks(i),XvHistMaxPeaks(i), XvHistMaxPeaks(i-1),XvHistMaxPeaks(i-1),XvHistMaxPeaks(i)];
		Y = [YhHistMaxPeaks(j),YhHistMaxPeaks(j-1), YhHistMaxPeaks(j-1),YhHistMaxPeaks(j),YhHistMaxPeaks(j)];

		probV = WindowsColVote(i)/max(WindowsColVote);
		probH = WindowsRowVote(j)/max(WindowsRowVote);
		probVH = (probV+probH)/2;
		probStr = sprintf('%0.1f', probVH);
		%text(XvHistMaxPeaks(i-1)+10, YhHistMaxPeaks(j-1)+30, probStr, 'BackgroundColor',[1 1 1]);

		if WindowsColVoteBin(i) && WindowsRowVoteBin(j)
			colorStr = 'g-';
			plot(X,Y, colorStr, 'LineWidth',2);
		elseif WindowsColVoteBin(i) 
			colorStr = 'b-';
			plot(X,Y, colorStr, 'LineWidth',1);
		elseif WindowsRowVoteBin(j)
			colorStr = 'b-';
			plot(X,Y, colorStr, 'LineWidth',1);
		else
		 	colorStr = 'b--';
		 	plot(X,Y, colorStr, 'LineWidth',1);
		end

	end
	%	pause;
end



% exctract big rectangles base upon change 01 or 10 in colbin
k=1
for i=2:length(WindowsColVoteBin)
	if ~WindowsColVoteBin(i-1) && WindowsColVoteBin(i)  
		WindowsColVoteBig(k)= WindowsColVote(i-1)
		WindowsColVoteBinBig(k) = 0;
		XvHistMaxPeaksBig(k) = XvHistMaxPeaks(i-1)
		k=k+1;
	end
	if WindowsColVoteBin(i-1) && ~WindowsColVoteBin(i)  
		WindowsColVoteBinBig(k) = 1;
		WindowsColVoteBig(k)= WindowsColVote(i-1)
		XvHistMaxPeaksBig(k) = XvHistMaxPeaks(i-1)
		k=k+1;
	end
end
k=1
for i=2:length(WindowsRowVoteBin)
	if ~WindowsRowVoteBin(i-1) && WindowsRowVoteBin(i)  
		WindowsRowVoteBinBig(k) = 0;
		WindowsRowVoteBig(k)= WindowsRowVote(i-1)
		YhHistMaxPeaksBig(k) = YhHistMaxPeaks(i-1)
		k=k+1;
	end
	if WindowsRowVoteBin(i-1) && ~WindowsRowVoteBin(i)  
		WindowsRowVoteBinBig(k) = 1;
		WindowsRowVoteBig(k)= WindowsRowVote(i-1)
		YhHistMaxPeaksBig(k) = YhHistMaxPeaks(i-1)
		k=k+1;
	end
end


for i=2:length(XvHistMaxPeaksBig)
	for j=2:length(YhHistMaxPeaksBig)
		if WindowsColVoteBinBig(i) && WindowsRowVoteBinBig(j)
			margin = 5;
			xOffset = margin*[1 1 -1 -1 1];
			yOffset = margin*[1 -1 -1 1 1];
			X = [XvHistMaxPeaksBig(i),XvHistMaxPeaksBig(i), XvHistMaxPeaksBig(i-1),XvHistMaxPeaksBig(i-1),XvHistMaxPeaksBig(i)];
			Y = [YhHistMaxPeaksBig(j),YhHistMaxPeaksBig(j-1), YhHistMaxPeaksBig(j-1),YhHistMaxPeaksBig(j),YhHistMaxPeaksBig(j)];
			colorStr = 'r-';
			plot(X+xOffset,Y+yOffset, colorStr, 'LineWidth',3);
		end
	end
end


if false

	% draw binary stroke images 
	fgimOri 					= figure();imshow(Dataset.ImReader.imOri,[]);
	fgimEdge 					= figure();imshow(Dataset.ImReader.imEdge,[]);
	fgimHoughPxCountX 			= figure();imshow(imHoughPxCountX,[]);
	fgimHoughPxCountY 			= figure();imshow(imHoughPxCountY,[]);
	fgimHoughPxCountSumXY  		= figure();imshow(imHoughPxCountX+imHoughPxCountY,[]);

	if saveImage
		disp('saving images..');
		% save images
		saveas(fgimOri 				,[savePath,'00_fgimOri.png'],'png'); 
		saveas(fgimEdge 			,[savePath,'02_fgimEdge.png'],'png'); 
		%saveas(fgimHoughPxCountX 		,[savePath,'05_ClassRect_fgimHoughPxCountX.png'],'png'); 
		%saveas(fgimHoughPxCountY 		,[savePath,'15_ClassRect_fgimHoughPxCountY.png'],'png'); 
		saveas(fgimHoughPxCountSumXY	,[savePath,'25_ClassRect_fgimHoughPxCountSumXY.png'],'png'); 
		saveas(fgimHoughLinesImV 		,[savePath,'30_ClassRect_fgimHoughLinesImV.png'],'png'); 
		saveas(fgimHoughLinesImH 		,[savePath,'31_ClassRect_fgimHoughLinesImH.png'],'png'); 
		saveas(fgimWindows				,[savePath,'40_ClassRect_fgimWindows.png'],'png');
		disp('done!');
	end

end

ClassRect.imGrayscaleProb = imHoughPxCountX+imHoughPxCountY;
% quickfix for classRectI and II
evalCode = [module,' = ClassRect;'];eval(evalCode);


figure(fgimWindows)

