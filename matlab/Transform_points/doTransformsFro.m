%% work out homography for CAVIAR dataset
%lab exercise for b31xn
%calum blair 29/1/12

%close all

%folder = 'NTOneLeaveShop1';
folder = 'NTOneLeaveShop1TM';
folder = sprintf('../../data/%s/',folder);

% Ground Truth and NTracks file names
gt_fro_file = strcat( folder, 'tracks_cor_fro.mat' );
nt_path = strcat( folder, 'NTracks_front.txt' );

% Ground Truth and NTracks transformed to the Ground Plane file names
GP_gt_fro_file = strcat(folder, 'GP_tracks_front.mat' );
GP_nt_fro_file = strcat(folder, 'GP_NTracks_front.txt' );

load(gt_fro_file);

%--------------------------------------------------------------------------
% Person id correspondence
%--------------------------------------------------------------------------
% ID NTOneLeaveShop1
%id_nt = 2; id_gt = 2;

% ID NTOneLeaveShop1NT
id_nt = 1; id_gt = 2;

% try
%     % --------------------------------------------------------
%     % OneLeaveShop1
%     % --------------------------------------------------------
% 	load tracks_cor_fro_wh;
%     % --------------------------------------------------------
%     % OneLeaveShop2
%     % --------------------------------------------------------
%     %load tracks2_cor_fro;
% catch
% 	caviar_data_extraction;
% end
[s1 s2 s3] = size(tracks_cor);
if s3<4
	warning('need to extract width & height from XML or point transforms wont work');
	warning('do this then re-save in tracks_cor_mat');
end

% --------------------------------------------------------
% OneLeaveShop1
% --------------------------------------------------------
%open videos
vc = VideoReader('OneLeaveShop1cor.mpg');
vf = VideoReader('OneLeaveShop1front.mpg');
%set time difference between cameras
td = 77;

% --------------------------------------------------------
% OneLeaveShop2
% --------------------------------------------------------
%open videos
% vc = VideoReader('OneLeaveShop2cor.mpg');
% vf = VideoReader('OneLeaveShop2front.mpg');
%set time difference between cameras
% td = 77;

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

%--------------------------------------------------------------------------
% CONVERT TO GROUND PLANE
%--------------------------------------------------------------------------
gt_ori = tracks_fro;
T = f2b;

% extract the naive tracker data in matlab format
[ nt_frames, nt_ppl, nt_ori ] = read_data( nt_path );
nt_center = nt_ori;
gt_center = gt_ori;

%--------------------------------------------------------------------------
% GET THE POINT OF THE FEET INSTEAD OF THE CENTER
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% GET THE POINT OF THE FEET INSTEAD OF THE CENTER
%--------------------------------------------------------------------------
x=1;y=2;w=3;h=4; % columns in the ground truth
% GT: get the average only in the bottom of the rectangle
gt_feet = gt_ori;
gt_feet(:,:,y) = ceil(gt_ori(:,:,y) + gt_ori(:,:,h)/2);

% NT: set the last 2 columns as the x (col3) y center (col 8)
x=7;y=8;w=5;h=6; % columns in the ground truth
nt_feet = nt_ori;
nt_feet(:,y) = ceil(nt_ori(:,y) + nt_ori(:,h)/2);

% use center
% gt = gt_center;
% nt = nt_center;

% use the feet
gt = gt_feet;
nt = nt_feet;

%--------------------------------------------------------------------------
% PROJECT ONTO THE GROUND PLANE
%--------------------------------------------------------------------------

% save the naive tracker projections on ground plane
[ nt_gp, tracks_fro, nt ] = save_gp_projection( nt, gt, T, GP_nt_fro_file);

% naiver tracker projection of test person
idx_pt = nt(:,2) == id_nt;
pt = nt(idx_pt,:);
pt_gp = nt_gp(idx_pt,:);

% ground truth projection of test person
pt_gt_gp = tracks_fro(:,id_gt,1:2);

%--------------------------------------------------------------------------
% PLOT FRONT, CORRIDOR AND GROUND PLANE
%--------------------------------------------------------------------------
t=105; %
%pt = pt(1,1);
rF = [50 95 300 115];
rC = [50 60 240 205];
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

%--------------------------------------------------------------------------
% PLOT TRACKS
%--------------------------------------------------------------------------
% person naive tracks on ground plane
figure(iB),hold on;
plot(pt_gp(:,1),pt_gp(:,2),'mo')

% person naive tracks on corridor image
figure(iF),hold on;
plot(pt(:,7),pt(:,8),'ro')

% person ground truth on ground plane
figure(iB),hold on;
plot(pt_gt_gp(:,:,1),pt_gt_gp(:,:,2),'g.')

% person ground truth on corridor image
figure(iF),hold on;
plot(gt(:,id_gt,1),gt(:,id_gt,2),'y.')

save(GP_gt_fro_file,'tracks_fro');
imwrite(base,strcat(folder,'gp.png'));

