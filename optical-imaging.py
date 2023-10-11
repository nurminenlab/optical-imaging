import matplotlib.pyplot as plt
import pco
import numpy as np
from skimage.measure import block_reduce
import time

def im_norm(IM):
    IM = 2 * ((IM - np.min(IM)) / (np.max(IM) - np.min(IM))) - 1
    return IM

try:
    plt.ion()
    images_per_block = 660
    n_blocks = 200
    bsx = 2
    bsy = 2
    bst = 1
    bsl_end = 60
    roi_x_size = 512
    roi_y_size = 512
    roi_x_strt = 1
    roi_y_strt = 1

    IM_vertical   = np.zeros((int(roi_x_size/bsx),int(roi_y_size/bsy),int(n_blocks/2)))
    IM_horizontal = np.zeros((int(roi_x_size/bsx),int(roi_y_size/bsy),int(n_blocks/2)))

    figure, ax = plt.subplots()
    plt.ion()
    im = ax.imshow(np.random.normal(128, 20,(int(roi_x_size/bsx),int(roi_y_size/bsy))), vmin=-1, vmax=1)
    

    cam = pco.Camera()
    cam.configuration = {'exposure time': 0.005, 
                         'roi':(roi_x_strt,roi_y_strt,roi_x_size,roi_y_size),
                         'trigger': 'external exposure start & software trigger'}


    n = 0
    a = 0
    b = 0
    while n < n_blocks:
        cam.record(number_of_images=images_per_block,mode='sequence')
        images,meta = cam.images()
        IM = np.dstack(images)
        IM = block_reduce(IM, block_size=(bsx,bsy,bst),func=np.mean)
        IM_bsl = np.mean(IM[:,:,0:bsl_end+1],axis=2)
        IM_evk = np.mean(IM[:,:,bsl_end+1:-1],axis=2)
        IM = (IM_evk - IM_bsl) /  IM_bsl
        IM = im_norm(IM)

        if (n % 2) == 0:
            IM_vertical[:,:,a] = IM                
            a = a + 1
        else:
            IM_horizontal[:,:,b] = IM            
            b = b + 1

        vertical = np.mean(IM_vertical[:,:,0:a],axis=2)
        horizontal = np.mean(IM_horizontal[:,:,0:b],axis=2)
        IM = vertical - horizontal
        im.set_data(IM)
        im.set_cmap('gray')



        figure.canvas.draw()
        figure.canvas.flush_events()
        time.sleep(0.05)
        plt.show()
        n = n + 1
        print('Processed data for block', n)         
    

except (RuntimeError, KeyboardInterrupt):
    #cam.stop()
    cam.close()
    
