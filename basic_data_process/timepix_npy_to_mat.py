import os #it lets the python code interact with diles and directories
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from scipy.io import savemat

# THIS IS THE CODE THAT TRANSFORMS THE RAW .NPY DATA INTO .MAT WITH TOT MAPS

# Configuration
save_dir = "B7_W0016\meas" # directory for saving the .png files and reading data
base_name = "test.npy" # how the data files are named
FRAMES_PER_BUNCH = 2000
bunch_counter = 0

# here you can put check if the path to save_dir exists

name, ext = os.path.splitext(base_name)
files = [f for f in os.listdir(save_dir) if f.startswith(name) and f.endswith(ext)]
files.sort()
# files is a list of data files, fname is a single filename in them

# here you can put check if there were any files found (if not files)

# initialize the totmap
totMap = np.zeros((256, 256))
total_frames = 0
total_hits = 0
hits_in_time = []

for fname in files:
    fpath = os.path.join(save_dir, fname)
    print(f"Reading frames from: {fpath}")
    try:
        with open(fpath, "rb") as f:
            frame_idx = 1 #  MATLAB indexes from 1 xd
            batch_dict = {} # dictionary that will be saved to .mat file
            bunch_frames = []
            while True:
                try: # because the end of the file returns an error
                    save_data = np.load(f, allow_pickle=True).item()
                    # savemat('test_matlab.mat', {'save_data': save_data}) # to save the data in .mat (MATLAB)
                    # print('MATLAB data saved to test_matlab.mat')
                    hits_array = save_data.get("hits", None)
                    # a map for the frame
                    if hits_array is not None and hits_array.dtype.names == ('x', 'y', 'tot', 'toa'):
                        for hit in hits_array:
                            x, y, tot, toa = hit
                            if 0 <= x < 256 and 0 <= y < 256:
                                totMap[int(x), int(y)] = tot
                        total_hits += len(hits_array)
                        total_frames += 1
                        print(f"Processing frame {frame_idx}, hits in this frame: {total_hits}")

                        hits_in_time.append(total_hits)
                        total_hits = 0

                        batch_dict[f'totMap_{frame_idx}'] = totMap
                        totMap = np.zeros((256, 256))
                        frame_idx += 1

                        if len(batch_dict) >= FRAMES_PER_BUNCH:
                            print("Creating .mat file....")
                            savemat(f'totMaps_{frame_idx-FRAMES_PER_BUNCH}_{frame_idx-1}.mat', batch_dict)
                            print(f'Saved totMaps_{frame_idx-FRAMES_PER_BUNCH}_{frame_idx-1}.mat')
                            bunch_counter += 1
                            batch_dict = {} # reset for next batch
                    else:
                        print(f"file format not recognised as hits_array in {fname}")
                        break
                except EOFError: # end of file error
                    if bunch_frames:
                        bunch_counter += 1
                    break
                except Exception as e:
                    print(f"error reading frame: {e}")
                    break
    except Exception as e:
        print(f"Error opening file {fpath}: {e}")
        continue

print(f"Saved {bunch_counter} bunches as .mat files in {save_dir}/bunches")

savemat('hits_in_frames.mat', {'hits_in_time': hits_in_time})
print(f'Hits number array saved to hits_in_frames.mat')


