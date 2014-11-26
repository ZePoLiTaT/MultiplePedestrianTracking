%% work out homography for CAVIAR dataset
%lab exercise for b31xn
%calum blair 29/1/12
clear all
close all
%get tracks
try
	load tracks_cor_fro_wh;
catch
	caviar_data_extraction;
end
[s1 s2 s3] = size(tracks_cor);
if s3<4
	warning('need to extract width & height from XML or point transforms wont work');
	warning('do this then re-save in tracks_cor_mat');
end
%open videos
vc = VideoReader('../../data/OneLeaveShop1cor.mpg');
vf = VideoReader('../../data/OneLeaveShop1front.mpg');
%set time difference between cameras
td = 77;

%registration points from CAVIAR page
%note y-coordinates are reversed from the matlab standard
%and also that point 5 is at (0,0)
regpoints = [91,163,0,975;
241,163,290,975;
98,266,0,-110;
322,265,290,-110;
60,153,0,0;
359,153,0,975;
50,201,382,098;
367,200,382,878];
%set ground plane extent (see diagram)
yb = 4700;
xb = 1920;

%set offsets to move control points onto new base
%ie where is point 5 in our coordinate system?
%in our system, y increases as we move down the image and towards the
%corridor camera
xo = 1110;
yo = 410;
%move control points to this new standard
regpoints(:,3) = regpoints(:,3) + xo;
regpoints(:,4) = yb - (regpoints(:,4) + yo);

%% do transforms
%transform corridor onto base plane
c2b = cp2tform(regpoints(1:4,1:2),regpoints(1:4,3:4),'projective');
%transform front onto base plane
f2b = cp2tform(regpoints(5:8,1:2),regpoints(5:8,3:4),'projective');
save('caviar_homography.mat','c2b','f2b');

%% check transform by transforming images onto base plane

%if we transform the original images, bits of them will fall outside our
%base plane. When this happens, MATLAB shrinks the output image to an
%unreadable mess. So we only work on the parts of the image we know are on
%the ground plane
%define these rectangles
%these could poss be improved but watch for the assertion below
rF = [50 95 300 115];
rC = [50 60 240 205];
t=105;
imgC = vc.read(t);
imgF = vf.read(t+td);
%plot rectangles
iC=1; iF=2; iB=3;
figure(iC),imshow(imgC); drawnow
hold on; rectangle('Position',rC,'EdgeColor','red');
figure(iF),imshow(imgF); drawnow
hold on; rectangle('Position',rF,'EdgeColor','red');

%crop the images
patchF = imcrop(imgF,rF);
patchC = imcrop(imgC,rC);

%transform them - extra options needed here. dont use whole images either
[fBase fbx fby] = imtransform(patchF,f2b,'XYScale',1,'UData',[rF(1) rF(1)+rF(3)],'VData',[rF(2) rF(2)+rF(4)]);
[cBase cbx cby] = imtransform(patchC,c2b,'XYScale',1,'UData',[rC(1) rC(1)+rC(3)],'VData',[rC(2) rC(2)+rC(4)]);
assert(cbx(1)>0); assert(cby(1)>0);
cbx=ceil(cbx); cby=ceil(cby);
assert(fbx(1)>0); assert(fby(1)>0);
fbx=ceil(fbx); fby=ceil(fby);

%[fbx fby] tells us where images go on base plane
base = zeros(yb,xb,3);
base(cby(1):cby(2),cbx(1):cbx(2),:) = im2double(cBase(1:cby(2)-cby(1)+1,1:cbx(2)-cbx(1)+1,:));
%front overwrites corridor...
base(fby(1):fby(2),fbx(1):fbx(2),:) = im2double(fBase(1:fby(2)-fby(1)+1,1:fbx(2)-fbx(1)+1,:));
figure(iB),imshow(base)
	
%% check transform of GT points too
%get points for a specfic frame
gtC = squeeze(tracks_cor(t,:,1:2));
gtF = squeeze(tracks_fro(t+td,:,1:2));
x=1;y=2;
%transform them to base plane
baseGTC = tformfwd(c2b,gtC(:,x),gtC(:,y));
baseGTF = tformfwd(f2b,gtF(:,x),gtF(:,y));
%plot
figure(iB),hold on;
plot(baseGTC(:,x),baseGTC(:,y),'bo')
plot(baseGTF(:,x),baseGTF(:,y),'go')
%% match a specific person id and plot with dot
idF=2; idC = 6;
plot(baseGTF(idF,x),baseGTF(idF,y),'g.')
plot(baseGTC(idC,x),baseGTC(idC,y),'b.')
%% hmm. points transform ok but don't match up. try again using the feet
%or bottom of bbox,anyway
w=3;h=4;
gtCfeet = squeeze(tracks_cor(t,:,:));
gtCfeet(:,y) = ceil(gtCfeet(:,y) + gtCfeet(:,h)/2);
gtFfeet = squeeze(tracks_fro(t+td,:,:));
gtFfeet(:,y) = ceil(gtFfeet(:,y) + gtFfeet(:,h)/2);
%transform and plot
baseGTCfeet = tformfwd(c2b,gtCfeet(:,x),gtCfeet(:,y));
baseGTFfeet = tformfwd(f2b,gtFfeet(:,x),gtFfeet(:,y));
plot(baseGTCfeet(:,x),baseGTCfeet(:,y),'yo')
plot(baseGTFfeet(:,x),baseGTFfeet(:,y),'ro')
%% can we find the same person?
plot(baseGTCfeet(idC,x),baseGTCfeet(idC,y),'y*')
plot(baseGTFfeet(idF,x),baseGTFfeet(idF,y),'r*')

%% transfer GTs from one image to the other
figure(iC),hold on;
plot(gtCfeet(:,x),gtCfeet(:,y),'bo')
%now transform front points from base to corridor
CfromFfeet = tforminv(c2b,baseGTFfeet(:,x),baseGTFfeet(:,y));
plot(CfromFfeet(:,x),CfromFfeet(:,y),'r*')
%and the other way
figure(iF),hold on;
plot(gtFfeet(:,x),gtFfeet(:,y),'yo')
%% now transform corridor  points from base to front
FfromCfeet = tforminv(f2b,baseGTCfeet(:,x),baseGTCfeet(:,y));
plot(FfromCfeet(:,x),FfromCfeet(:,y),'r*')

