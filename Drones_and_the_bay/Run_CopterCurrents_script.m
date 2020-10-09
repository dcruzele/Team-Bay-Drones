%% Step 1

clc;
clear; 
clear all;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read Drone video - step 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% video to be analysed

% video_fname = '/path2thevideo/Drone_video.MP4';

video_fname = 'C:\Seth\MATLAB\MATLAB\MATLAB_SURF\Operation_Drone\Necessary_MATLAB_files_github\Necessary_MATLAB_files\video_over_elbe.mp4';

isfile('video_over_elbe.mp4');
% get video position in DJI drone

[CamPos_ST] = get_Camera_Position_Struct_mavicmini(video_fname);



% % Add data manually if is not a DJI drone 

% CamPos_ST = struct('LONE',LON,'LATITUDE',LAT,'Height',Height,...

%                    'timestamp',timestamp,'yaw',yaw,'pitch',pitch,...

%                    'roll',roll,'extra',mediainfo_string);



% time stamps to be used in the video [initial_time  end_time]

time_limits = [0 1];

time_limits;

% time between frames in seconds

dt = 0.10;



% distance between the home point and the water surface in meters

offset_home2water_Z = 0.8;



% FOV calibration structure to be used

% CopterCurrents_calibration_filename = '/path2CameraCalibration_folder/Phantom3_v1_FOV_3840x2160.mat';

CopterCurrents_calibration_filename = 'C:\Seth\MATLAB\MATLAB\MATLAB_SURF\Necessary_MATLAB_files-20200930T023240Z-001\Necessary_MATLAB_files\Phantom3_v1_FOV_3840x2160.mat';

% CopterCurrents_calibration_filename = '/path2CameraCalibration_folder/Phantom3_v1_OpenCV_3840x2160.mat';





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Rectify video and obtain REAL WORLD coordenates - step 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       



% Create a Georeference configuration structure

[Georeference_Struct_config] = create_georeference_struct(video_fname, dt, time_limits, offset_home2water_Z, CopterCurrents_calibration_filename,CamPos_ST);



% Apply Georeference_Struct_config and retrieve the Image sequence

% corrected

IMG_SEQ = run_Georeference_Struct_config(Georeference_Struct_config);

time_limits

% save('IMG_SEQ.mat','IMG_SEQ','-v7.3','-nocompression');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Slice Rectified sequence and define fit parameters - step 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  



% generate fit structure



% square fit size in meters

sq_size_m = []; 



% distance between square fit in meters

sq_dist_m = []; 



% 2D mask inidication the valid points for the fit

mask_2D = []; 



% percentage of area to nan to do not use the square to fit

nan_percentage_thr = 5;



% Ux current range to fit [m/s]

Ux_limits_FG = [-2.0 2.0];



% Uy current range to fit [m/s]

Uy_limits_FG = [-2.0 2.0];



% First guess step [m/s]

U_FG_res = 0.1;



% First guess filter width [rad/s]

w_width_FG = 1;



% Second guess step [m/s]

U_SG_res = U_FG_res/10;



% Second guess filter width [rad/s]

w_width_SG = w_width_FG/2;



% wavelength limits to be used in the fit 

% [shorter_waveLength longer_waveLength] in meters

waveLength_limits_m = []; 



% wave Period limits to be used in the fit 

% [smaller_wavePeriod longer_wavePeriod] in seconds

wavePeriod_limits_sec = []; 



% water depth mask in meters

% water depth in meters of every pixels in 

% water_depth_mask_2D(IMG_SEQ.gridX,IMG_SEQ.gridY)

%

% Note: if water_depth_mask_2D is a scalar, the same depth will be applied

% for the complete grid.

water_depth_mask_2D = 10; % 10 meters





% generate structure with the fit structure

STCFIT = generate_STCFIT_from_IMG_SEQ(IMG_SEQ, sq_size_m, sq_dist_m,mask_2D,nan_percentage_thr,water_depth_mask_2D, Ux_limits_FG,Uy_limits_FG,U_FG_res,w_width_FG,U_SG_res,w_width_SG,waveLength_limits_m, wavePeriod_limits_sec);



     

% plot STCFIT structure

[h] = plot_STCFIT(STCFIT);   

saveas(h,'STCFIT_squares_distribution.png');

close(h);



% % display  spectrum in window 'n_window'

% n_window = 38;

% display_fit_guess(IMG_SEQ,STCFIT,n_window)     





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run current fit  - step 4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



% run current fit in every square

STCFIT = run_current_fit(IMG_SEQ,STCFIT);



% save data

save('paper_FOV.mat','STCFIT','IMG_SEQ','-v7.3','-nocompression');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get current maps and plot results - step 5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



% filter with SNR

% choose going to direction for currents

currentdir_flag = 1;

% set Signal to Noise Ratio threshold 

SNR_thr = 0; 

% set Signal to Noise Ratio density threshold 

SNR_density_thr = 6; 



% retrieve current maps

[UTM_currents, Camera_currents] = get_currents_from_STCFIT(STCFIT,SNR_thr,SNR_density_thr,currentdir_flag);



% plot in camera coordenates

% scale factor for arrows

arrow_scale = 20; 



% plot current maps in camera coordenate system

h1  = plot_currents_map(Camera_currents,STCFIT,arrow_scale);

saveas(h1,'Current_map_camera_grid.png')

close(h1);



% plot in UTM coordenates (deg2utm library needed)

if ~isempty(UTM_currents)

    h2  = plot_currents_map(UTM_currents,STCFIT,arrow_scale);

    saveas(h2,'Current_map_UTM_grid.png');

    close(h2);

end