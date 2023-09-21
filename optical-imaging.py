import matplotlib.pyplot as plt
import pco
import numpy as np
import time
from matplotlib.widgets import Button

class GUIcallback:
    ind = 0

    def stop(self,event):        
        global settingROI
        settingROI = False

try:
    settingROI = True
    figure, ax = plt.subplots()
    figure.subplots_adjust(bottom=0.2)
    plt.ion()
    cam = pco.Camera()
    cam.configuration = {'exposure time': 0.03}

    ROI = cam.configuration['roi']
    im = ax.imshow(np.random.normal(128, 20,(ROI[2],ROI[3])),vmin=0, vmax=1)
    im.set_cmap('gray')

    callback = GUIcallback()
    axstop = figure.add_axes([0.7, 0.9, 0.1, 0.075])
    bstop = Button(axstop, 'Stop')
    bstop.on_clicked(callback.stop)
    figure.canvas.draw()
    time.sleep(0.1)

    #cam.record(number_of_images=10,mode="ring buffer")
    #cam.wait_for_first_image()
    while settingROI:            
        cam.record(mode="sequence")
        image, meta = cam.image()
        im.set_data(image/np.max(image))            
        #figure.canvas.draw()
        figure.canvas.flush_events()
        #time.sleep(0.02)
        figure.show()

    #cam.stop()
    cam.close()

except (RuntimeError, KeyboardInterrupt):
    #cam.stop()
    cam.close()
    
