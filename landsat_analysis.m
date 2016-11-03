%% add your relevant directories
clc
clear all
close all

format long

addpath('C:\Data_Maarten\MATLAB codes')
addpath('C:\Data_Maarten\MATLAB codes\m_map')
addpath('C:\Data_Maarten\MATLAB codes\L8read')

%% Read the points: coordinates (utm)
%2015
filename = 'C:\Data_Maarten\Analysis\CY_15_16\Working_Folder\PythonLANDSAT\PyWorkFol\2015_utm_converted.txt';
delimiter = ' ';
formatSpec = '%f%f%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
fclose(fileID);
X2015 = dataArray{:, 1};
Y2015 = dataArray{:, 2};
plot2015 = dataArray{:, 3};
clearvars filename delimiter formatSpec fileID dataArray ans;

%2016
filename = 'C:\Data_Maarten\Analysis\CY_15_16\Working_Folder\PythonLANDSAT\PyWorkFol\2016_utm_converted.txt';
delimiter = ' ';
formatSpec = '%f%f%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
fclose(fileID);
X2016 = dataArray{:, 1};
Y2016 = dataArray{:, 2};
plot2016 = dataArray{:, 3};
clearvars filename delimiter formatSpec fileID dataArray ans;

%% calculations
%read in the shapefile using the M_map OS functions found at https://www.eoas.ubc.ca/~rich/map.html
M=m_shaperead('C:\Data_Maarten\Analysis\CY_15_16\Working_Folder\PythonLANDSAT\PyWorkFol\input_files\ter_poly');
clf;

%plot the shapefile
for k=1:length(M.ncst),
    line(M.ncst{k}(:,1),M.ncst{k}(:,2));
end;

%read the geotiff using OS function found at https://nl.mathworks.com/matlabcentral/fileexchange/29425-geotiff-reader
I=GEOTIFF_READ('C:\Data_Maarten\Analysis\CY_15_16\Working_Folder\PythonLANDSAT\PyWorkFol\input_files\LC81780342014280LGN00_B1.TIF');

%look for max and min values for mathcing shapefile and geoTIFF
max_x_co=I.x(end);
min_x_co=I.x(1);
max_y_co=I.y(end);
min_y_co=I.y(1);
max_x=numel(I.x);
min_x=1;
max_y=numel(I.y);
min_y=1;

%round the shapefile coordinates to 30m to match the resolution of the
%geoTIFF
rounded_poly=round(M.ncst{:,:}/30)*30;


%match shapefile coordinates to geoTIFF - find matrix indeces location
normx=(((rounded_poly(:,1)-min_x_co).*(max_x - min_x))./(max_x_co - min_x_co))+ min_x;
normy=(((rounded_poly(:,2)-min_y_co).*(max_y - min_y))./(max_y_co - min_y_co))+ min_y;


%rasterize the shapefile into mask
mask=roipoly(I.z,normx,normy);
mask=double(mask);
mask=int16(mask);

%clip out relevant part of raster
clip_rast=mask.*I.z;

%% Reading the LANDSAT8 images
landsatdir='E:\BigDataFolder\Landsat8\RAWfiles\';
listing=dir(landsatdir)
tik=0;

%% Unzip script
% for i=3:numel(listing)
%     tik=tik+1;
%     dirname=int2str(tik);
%     dirname=[landsatdir dirname];
%     filecheck=exist(dirname) ;
%     if filecheck==0
%         mkdir(dirname);
%     end
%     untar([landsatdir listing(i,1).name],dirname);
% end

%% Importing images
klokje=0;
% daynumber
for i=1:47
    folnum=int2str(i);
    dirname=[landsatdir folnum];
    meta_name=dir([dirname '\' '*.txt']);
    day_num=date2num(dirname,meta_name.name);
    day_num_store(i)=day_num;
    [I_R,I_NIR,I_SWIR1,I_SWIR2,I_Cloud,x,y ] = MVLreadL8( landsatdir,folnum,meta_name.name );
    if i==1
        num_plot=numel(X2016)+numel(X2015);
        NDVIstore=zeros(47,num_plot);
        SMstore=zeros(47,num_plot);
        cloudstore=zeros(47,num_plot);
    end
    
    [NDVIout,SMout,cloudout,normx_2015,normx_2016,normy_2015,normy_2016]=plot2value(I_NIR,I_R,X2015,X2016,Y2015,Y2016,I_Cloud,x,y);
    NDVIstore(i,:)=NDVIout;
    SMstore(i,:)=SMout;
    cloudstore(i,:)=cloudout;
    klokje=klokje+1
end

%% mask out cloud datapoints
NDVIstoreNoCl=NDVIstore;
NDVIstoreNoCl(cloudstore == 1 | cloudstore == 2 | cloudstore == 24)=NaN;

%% image_arrays
for i=1:num_plot
    NDVIarr{i}=NDVIstoreNoCl(:,i);
    [indx{i},indy{i}]=find(isnan(NDVIarr{i}));
    day_num_arr{i}=day_num_store;
    day_num_arr{1,i}(indx{1,i})=[];
    NDVIarr{1,i}(indx{1,i})=[];
end

%% months on the fig

month_array2014=[0 0 0 0 0 0 0 0 0 31 30 31];
month_array2015=[31 28 31 30 31 30 31 31 30 31 30 31];
month_array2016=[31 29 31 30 31 30 31 31 30 31 30 31];
months=[30 31 30 31 month_array2015 month_array2016];
monthsum=cumsum(months);
moname14={'S','O','N','D'};
moname15={'J','F','M','A','M','J','J','A','S','O','N','D'};
moname=[moname14 moname15 moname15];
%% plotting NDVI no cloud correction
for j=1:num_plot
    figure(j)
    plot(day_num_store,NDVIstore(:,j));
    hold on
    MM = smooth(NDVIstore(:,j),3);
    plot(day_num_store,MM,'--r');
    for i=1:numel(monthsum)
        monthlim=[monthsum(i) monthsum(i)];
        Ylim4line=get(gca,'Ylim');
        plot(monthlim,Ylim4line,':k')
        text(monthlim(1)-19,Ylim4line(2)-0.1,moname{i})
        
    end
end

%% plotting NDVI WITH cloud correction
for j=1:num_plot
    figure(j)
    plot(day_num_arr{1,j},NDVIarr{1,j});
    hold on
    MM = smooth(NDVIarr{1,j},3);
    plot(day_num_arr{1,j},MM,'--r');
    for i=1:numel(monthsum)
        monthlim=[monthsum(i) monthsum(i)];
        Ylim4line=get(gca,'Ylim');
        plot(monthlim,Ylim4line,':k')
        text(monthlim(1)-19,Ylim4line(2)-0.1,moname{i})
    end
end

%% plot map + coordinates
figure(1)
imagesc(clip_rast)
hold on
plot(normx_2015,normy_2015,'r.','MarkerSize',10)
hold on
plot(normx_2016,normy_2016,'k.','MarkerSize',10)


