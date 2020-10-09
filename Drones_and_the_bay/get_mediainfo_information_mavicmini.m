function [LON, LAT, Height, timestamp, mediainfo_string, yaw, pitch, roll] = get_mediainfo_information_mavicmini(video_filename)
%video_filename = 'video_over_elbe.MP4';

%mediainfo '
command_media_info = ['mediainfo ' video_filename];

% read mediainfo information




[status,mediainfo_string] = system(command_media_info);
  

pwd;

if status == 0
    
    % get lon lat
    
    
    
    [C, matches] = strsplit(mediainfo_string, {'\n'});
    
    Index = find(contains(C, 'xyz'));
    
    [C2, matches] = strsplit(C{Index}, {':','+','-'});
    
    LON = str2double([matches{3} C2{4}]);
    
    LAT = str2double([matches{2} C2{3}]);
    
    %Height = str2double([matches{4} C2{5}]);
    Height = 8.5;
    
    %Code for height must be input here, height must be inserted manually,
    %DJI mavic mini does not
    
    Index = find(contains(C, 'Encoded date'));
    
     [C3,matches] = strsplit(C{Index(1)},{': UTC '});
   
    
    timestamp = datenum(C3{2});
    
    
    
    %get orientation   
 %confused on below code
    Index = find(contains(C,'fyw '));
    [C4, matches] = strsplit(C{Index(1)}, {':'});
    yaw = str2double(C4{2});
    
    
    %get pitch
    Index = find(contains(C, 'gpt '));
    [C5, matches] = strsplit(C{Index(1)}, {':'});
    pitch = str2double(C5{2});
    
    
    %get roll
    Index = find(contains(C,'grl '));
    [C6, matches] = strsplit(C{Index(1)}, {':'});
    roll = str2double(C6{2});
    
    
    else

    % probably media info is not installed

    %  add values manually

    disp('Install Mediainfo: https://mediaarea.net/en/MediaInfo/Download/Ubuntu');

    disp('Install Mediainfo: https://mediaarea.net/en/MediaInfo/Download/Windows');

    warning('get_mediainfo_information: Mediainfo does not return valid data');



    LON = [];

    LAT = [];

    Height = [];

    timestamp = [];

    mediainfo_string = [];

    yaw = [];

    pitch = [];

    roll = [];

    

end
    
  
     
end