function  [NDVIout,SMout,cloudout,normx_2015,normx_2016,normy_2015,normy_2016] = plot2value(I_NIR,I_R,X2015,X2016,Y2015,Y2016,cloud,x,y)

%look for max and min values for mathcing shapefile and geoTIFF
max_x_co=x(end);
min_x_co=x(1);
max_y_co=y(end);
min_y_co=y(1);
max_x=numel(x);
min_x=1;
max_y=numel(y);
min_y=1;

%round the shapefile coordinates to 30m to match the resolution of the
%geoTIFF
rounded_x2015=round(X2015/30)*30;
rounded_x2016=round(X2016/30)*30;
rounded_y2015=round(Y2015/30)*30;
rounded_y2016=round(Y2016/30)*30;

%match shapefile coordinates to geoTIFF - find matrix indeces location
normx_2015=round((((rounded_x2015-min_x_co)*(max_x - min_x))/(max_x_co - min_x_co))+ min_x);
normy_2015=round((((rounded_y2015-min_y_co)*(max_y - min_y))/(max_y_co - min_y_co))+ min_y);
normx_2016=round((((rounded_x2016-min_x_co)*(max_x - min_x))/(max_x_co - min_x_co))+ min_x);
normy_2016=round((((rounded_y2016-min_y_co)*(max_y - min_y))/(max_y_co - min_y_co))+ min_y);
all_plots_x=[normx_2015;normx_2016];
all_plots_y=[normy_2015;normy_2016];

NIRmatrix=I_NIR(all_plots_x,all_plots_y);
NIRall=diag(NIRmatrix);

Rmatrix=I_R(all_plots_x,all_plots_y);
Rall=diag(Rmatrix);

NDVIout(:,:)=(NIRall-Rall)./(NIRall+Rall);
SMout(:,:)=1-((1/(sqrt((1.4042^2)+1))).*(NIRall+(1.40426*Rall)));


cloudmatrix=cloud(all_plots_x,all_plots_y);
cloudout=diag(cloudmatrix);


end

