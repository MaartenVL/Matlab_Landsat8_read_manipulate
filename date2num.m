function [ day_num ] = date2num(dirname,textinput)
%start= 1-09-2014
month_array2014=[0 0 0 0 0 0 0 0 0 31 30 31];
month_array2015=[31 28 31 30 31 30 31 31 30 31 30 31];
month_array2016=[31 29 31 30 31 30 31 31 30 31 30 31];

month_array2014=cumsum(month_array2014);
month_array2015=cumsum(month_array2015);
month_array2016=cumsum(month_array2016);


month_array2014=[0 month_array2014];
month_array2015=[0 month_array2015];
month_array2016=[0 month_array2016];

month_array2014(end)=[];
month_array2015(end)=[];
month_array2016(end)=[];


year2014=0;
year2015=122;
year2016=122+366;

%% import meta-info
filename = [dirname '\' textinput];
delimiter = ' ';
startRow = 21;
endRow = 21;
formatSpec = '%*s%*s%s%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow-1, 'ReturnOnError', false);
fclose(fileID);
date_string = dataArray{:, 1};
clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;

%% convert date to day_num
date_split=strsplit(date_string{1,1},'-'); % cell2str, then split it

if str2num(date_split{1})==2014
    month=month_array2014;
    year=year2014;
elseif str2num(date_split{1})==2015
    month=month_array2015;
    year=year2015;
else
    month=month_array2016;
    year=year2016;
end
day_num=year+month(str2num(date_split{2}))+str2num(date_split{3});
end
