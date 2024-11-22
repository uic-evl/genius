import os
import cv2

png_dir = '/LBM_images'

png_files = [f for f in os.listdir(png_dir) if f.endswith('.png')]

png_files.sort()

if not png_files:
    print("No .png files found in the directory.")
    exit()

first_image_path = os.path.join(png_dir, png_files[0])
frame = cv2.imread(first_image_path)
height, width, layers = frame.shape

video_path = 'outputs/lbm_sim.mp4'
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
video = cv2.VideoWriter(video_path, fourcc, 6.0, (width, height))

for file_name in png_files:
    file_path = os.path.join(png_dir, file_name)
    image = cv2.imread(file_path)
    video.write(image)

video.release()

print(f"Video created successfully and saved as {video_path}")