% extract the person tracks from the CAVIAR data sequence

% this is not very subtle code ...
% you need to know in advance how many people there are by looking at the xml file

function tracks = get_tracks_from_xml(t)

% replace this with sizeof or something

no_frames = length(t.dataset.frame)

% drill down to the 'bounding box level' in the particular data structure
% here we have height (h), width (w), centroid (xc,yc)
% so for every person, extract their position

%figure(1), imshow(imread('OneLeaveShop1cor0000.jpg'));

% for every frame
for j=1:no_frames

    if isfield(t.dataset.frame{j}.objectlist,'object')
        no_people = length(t.dataset.frame{j}.objectlist.object);
    else
        no_people = 0;
        tracks(j,1,1) = 0;
    end
    
    % for every person in the frame
    
    for i=1:no_people
   
        % pick out the centroids
      if no_people>1
        x = str2num(t.dataset.frame{j}.objectlist.object{i}.box.Attributes.xc);
        y = str2num(t.dataset.frame{j}.objectlist.object{i}.box.Attributes.yc);
        w = str2num(t.dataset.frame{j}.objectlist.object{i}.box.Attributes.w);
        h = str2num(t.dataset.frame{j}.objectlist.object{i}.box.Attributes.h);
        person_id = str2num(t.dataset.frame{j}.objectlist.object{i}.Attributes.id)+1;
      else % if object has only 1 entry it is not a cell!
        x = str2num(t.dataset.frame{j}.objectlist.object.box.Attributes.xc);
        y = str2num(t.dataset.frame{j}.objectlist.object.box.Attributes.yc);
        w = str2num(t.dataset.frame{j}.objectlist.object.box.Attributes.w);
        h = str2num(t.dataset.frame{j}.objectlist.object.box.Attributes.h);
        person_id = str2num(t.dataset.frame{j}.objectlist.object.Attributes.id)+1;
      end
        % populate the array using person ID
        % note this will add zeros where the person is not visible and then
        % re-appears!
        
        tracks(j,person_id,1) = x;
        tracks(j,person_id,2) = y;
        tracks(j,person_id,3) = w;
        tracks(j,person_id,4) = h;
        
        % see evolution of tracks in image plane
        % figure(1), hold on, plot(x,y, '.');
        %figure(1), hold on, rectangle('Position',[x-w/2,y-h/2,w,h]);
         
        
    end
    
end