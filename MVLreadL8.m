function [ I_R,I_NIR,I_SWIR1,I_SWIR2,I_Cloud,x,y ] = MVLreadL8( landsatdir,folnum,meta )
%% read image
folname=[landsatdir folnum];
listing2=dir(folname);
name1=listing2(3,1).name;
name2=strsplit(name1,'.');
I_R=double(imread([folname '\' name2{1} '_sr_band' '4' '.TIF'])); %double to avoid rounding when dividing - see also http://stackoverflow.com/questions/3689575/matlab-division-should-29-128-return-0
I_NIR=double(imread([folname '\' name2{1} '_sr_band' '5' '.TIF']));
I_SWIR1=double(imread([folname '\' name2{1} '_sr_band' '6' '.TIF']));
I_SWIR2=double(imread([folname '\' name2{1} '_sr_band' '7' '.TIF']));
I_Cloud=double(imread([folname '\' name2{1} '_sr_cloud' '.TIF']));


%% read meta 4 coordinates

filename = meta;
delimiter = ' ';
startRow = 31;
endRow = 38;
formatSpec = '%*s%*s%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen([folname '\' filename],'r');
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow-1, 'ReturnOnError', false);
fclose(fileID);
L1_METADATA_FILE = dataArray{:, 1};
clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;

xmin=L1_METADATA_FILE(1);
xmax=L1_METADATA_FILE(3);
ymin=L1_METADATA_FILE(6);
ymax=L1_METADATA_FILE(2);

numx=numel(I_R(1,:));
numy=numel(I_R(:,1));

distx=xmax-xmin;
disty=ymax-ymin;

xres=round(distx/numx);
yres=round(disty/numy);

x=[1:1:numx];
y=[1:1:numy];

svx=x;
svx(:)=xmin;
svy=y;
svy(:)=ymin;

x=svx+(x*(xres-1));
y=svy+(y*(yres-1));
end

