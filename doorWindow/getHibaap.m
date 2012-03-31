% HIBAAP - HIstogram BAsed AProach, window detection
close all;
tic;
%Dataset.fileShort = 'OrtCrop1';
%load([startPath,'/doorWindow/mats/Dataset_',Dataset.fileShort,'_houghlinesVH.mat']);

disp('plotting houghlines');
	% fgHough = figure();imshow(Dataset.ImReader.imOriDimmed); hold on;
	% plotHoughlinesAll(Dataset.ImReader.imHeight,Dataset.HoughResult.Houghlines,Dataset.HoughResult.HoughlinesRot);
	fgHist= figure();imshow(Dataset.ImReader.imOriDimmed); hold on;

w = Dataset.ImReader.imWidth;
h = Dataset.ImReader.imHeight;

% calc histograms by summing rows/cols
XvHist = sum(HoughResult.V.Im);
YvHist = sum(HoughResult.V.Im, 2);
XhHist = sum(HoughResult.H.Im);
YhHist = sum(HoughResult.H.Im, 2);

% setup histograms bins
XvBins = 1:1:w;
YhBins = 1:1:h;
% 'unusable' histograms
YvBins = 1:1:h;
XhBins = 1:1:w;

% smooth histograms 
incrFactor = Dataset.HibaapParam.incrFactor; % TODO make perncent of avg image width height
incrFactor = 1;
XvHistSmooth = smoothNtimes(XvHist,6);
XhHistSmooth = smoothNtimes(XhHist,6);
YhHistSmooth = smoothNtimes(YhHist,6);
YvHistSmooth = smoothNtimes(YvHist,6);

% plot histograms
disp('plotting histograms');
%plot(incrFactor*XvHist,'y-');
plotHistX(Dataset.ImReader.imHeight-40, XvBins, (incrFactor*XvHist), 'g-');
plotHistX(Dataset.ImReader.imHeight, XhBins, (incrFactor*XhHist), 'r-');
plotHistY(incrFactor*YhHist, YhBins, 'g-');
plotHistY(incrFactor*YvHist, YvBins, 'r-');

% plot histograms smoothed
plot(XvBins, Dataset.ImReader.imHeight-40-(incrFactor*XvHistSmooth),'r-', 'LineWidth',2);
plot(XhBins, Dataset.ImReader.imHeight-(incrFactor*XhHistSmooth),'g-', 'LineWidth',2);
plot(incrFactor*YhHistSmooth, YhBins, 'r-', 'LineWidth',2);
plot(incrFactor*YvHistSmooth, YhBins, 'g-', 'LineWidth',2);

drawnow
err

% set histogram thresholds
XvThresh = Dataset.HibaapParam.XvThresh; YhThresh = Dataset.HibaapParam.YhThresh;

% plot horizontal threshold line
%plot([0 Dataset.ImReader.imWidth],[Dataset.ImReader.imHeight-(incrFactor*XvThresh), Dataset.ImReader.imHeight-(incrFactor*XvThresh)],'k--','LineWidth',2); 
% plot vertical threshold line
%plot([incrFactor*YhThresh,incrFactor*YhThresh], [0,Dataset.ImReader.imHeight],'k--','LineWidth',2);

% find peaks
plotme = 1;
XvHistMaxPeaks = getHistMaxPeaks(Dataset, XvHistSmooth, XvThresh, plotme,'Xv');
YhHistMaxPeaks = getHistMaxPeaks(Dataset, YhHistSmooth, YhThresh, plotme,'Yh');
% save result in dataset
Hibaap.XvHistMaxPeaks = XvHistMaxPeaks;
Hibaap.YhHistMaxPeaks = YhHistMaxPeaks;

% find and plot intersections of vertical and horizontal lines
EdgePeakCrossings = [];
for i=1:length(XvHistMaxPeaks)
	for j=1:length(YhHistMaxPeaks)
		[crossing,d,l1,l2] = getLineCrossing([XvHistMaxPeaks(i),0]',[XvHistMaxPeaks(i),Dataset.ImReader.imHeight]',[0,YhHistMaxPeaks(j)]',[Dataset.ImReader.imWidth,YhHistMaxPeaks(j)]');
		plot(crossing(1), crossing(2), '+k');
		EdgePeakCrossings = [EdgePeakCrossings;crossing'];
	end
end


saveImage = false;
if saveImage
	disp('saving images..');
	savePath 						= ['resultsHibaap/',Dataset.fileShort,'/'];
	% if dir doesnt exist make it 
	if exist(savePath) == 0
		mkdir(savePath);
	end
	% TODO
	% use hgexport for eps images report thesis !
	% save images
	saveas(fgHough 				,[savePath,'03_fgHough.png'],'png'); 
	saveas(fgHist 				,[savePath,'04_fgHist.png'],'png'); 
	disp('done!');
end


saveStr = [startPath,'/doorWindow/mats/Dataset_',Dataset.fileShort,'_Hibaap.mat'];
save(saveStr, 'Hibaap');
saveStr, disp('saved');


% RECTANGLE CLASSIFICATION by cCorner
%hibaapcCorner(Dataset)


% RECTANGLE CLASSIFICATION
%saveImage = false
%hibaapClassifyRectangles(Dataset,saveImage)



toc;
