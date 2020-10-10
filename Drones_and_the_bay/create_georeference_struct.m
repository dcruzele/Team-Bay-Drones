function [Georeference_Struct_config] = create_georeference_struct(video_fname, dt, time_limits, offset_home2water_Z, CopterCurrents_calibration_filename,CamPos_ST)

%%video_fname = 'video_over_elbe.MP4'
if exist('video_fname','var') == 0 || isempty(video_fname) 

    video_fname = [];

end


if exist('dt','var') == 0 || isempty(dt)

    dt = .034;

end



if exist('time_limits','var') == 0 || isempty(time_limits) 

     time_limits = [0 .5];

end

time_limits

if exist('offset_home2water_Z','var') == 0 || isempty(offset_home2water_Z)

    offset_home2water_Z = .8;

end

% check dt => must be multiple of 1/v.FrameRate

if ~isempty(video_fname)
    
  %%  video_fname = 'video_over_elbe.MP4';

    v = VideoReader(video_fname);
    
 
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    dt_gap_video =  1/v.FrameRate;

   if rem(dt,dt_gap_video) ~= 0
a = round(dt/dt_gap_video);
        closes_dt = round(dt/dt_gap_video)*dt_gap_video;

        warning(['create_georeference_struct: dt = ' num2str(dt) '  exchanged by: ' num2str(closes_dt)]);

        dt = closes_dt;

    end

end



% check time_limits(1)

if time_limits(1) < 0

    time_limits(1) = 0;

    warning('create_georeference_struct: time_limits(1) < 0');

    disp('time_limits(1) set to 0 seconds');

end



 %check time_limits(2)

 %max_duration_limit = v.Duration;
v.Duration;

max_duration_limit = v.Duration - (1/v.FrameRate);


% max_duration_limit = v.Duration - (2/(v.FrameRate));

if time_limits(2) > max_duration_limit

    time_limits(2) = max_duration_limit;

    warning('create_georeference_struct: time_limits(2) > Video duration');

    disp(['time_limits(2) set to ' num2str(max_duration_limit) ' seconds.']);

end


CopterCurrents_calibration_filename = 'Phantom3_v1_FOV_3840x2160.mat';
% load calibration data


 

if isfile(CopterCurrents_calibration_filename)

    load(CopterCurrents_calibration_filename,'CopterCurrents_CamCalib');

    if exist('CopterCurrents_CamCalib','var') == 0

        error('create_georeference_struct: CopterCurrents_calibration_filename data not valid.'); 

    end

    

else

    disp(CopterCurrents_calibration_filename);

    error('create_georeference_struct: CopterCurrents_calibration_filename not found.'); 

end



% check frame size



% crete video object

v = VideoReader(video_fname);



if isfield(CopterCurrents_CamCalib,'ny') == 1

    ny = CopterCurrents_CamCalib.ny;

else

    ny = CopterCurrents_CamCalib.size_Y;

end



if isfield(CopterCurrents_CamCalib,'nx') == 1

    nx = CopterCurrents_CamCalib.nx;

else

    nx = CopterCurrents_CamCalib.size_X;

end



% Check image size; Used in debugging
num2str(ny);

if v.Height ~= ny

    disp(['CopterCurrents_CamCalib Height: ' num2str(ny)]);

    disp(['video Height: ' num2str(v.Height)]);

    error('video Height => Y axis (vertical) does not match with CopterCurrents_CamCalib');

end



if v.Width ~= nx

    disp(['CopterCurrents_CamCalib Width: ' num2str(nx)]);

    disp(['video Width: ' num2str(v.Width)]);

    error('video Width => X axis (horizontal) does not match with CopterCurrents_CamCalib');

end





% save data to struct

Georeference_Struct_config.video_fname = video_fname;

Georeference_Struct_config.dt = dt;

Georeference_Struct_config.time_limits = time_limits;

Georeference_Struct_config.video_ts =  time_limits(1):dt:time_limits(2);

Georeference_Struct_config.offset_home2water_Z = offset_home2water_Z;

Georeference_Struct_config.CopterCurrents_CamCalib = CopterCurrents_CamCalib;

Georeference_Struct_config.CamPos_ST = get_Camera_Position_Struct_mavicmini(video_fname);

Georeference_Struct_config.CamPos_ST.yaw;


end
%% Georeference_Struct_config = create_georeference_struct()
