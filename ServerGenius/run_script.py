import subprocess
from ssh import *
import time

def run_script(density, speed, length, viscosity, time_par, freq):
    start_time = time.time()
    #removes old images
    run_command("rm -r ~/Desktop/Argonne2024/ServerGenius/LBM_images")
    
    #runs command on polaris to run simulation with parameters
    run_command(f'ssh polaris -t "ssh fmassa1@x3005c0s7b0n0 -t \'./lbm-cfd_script.sh {density} {speed} {length} {viscosity} {time_par} {freq}\'"')
    
    #gets images from polaris
    run_command("scp -r fmassa1@polaris:/home/fmassa1/lbm-cfd-ascent/build/ ~/Desktop/Argonne2024/ServerGenius/LBM_images")
    #turns pictures to a video
    run_command("python3 video_maker.py")
    

    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Script executed in {elapsed_time:.2f} seconds")
