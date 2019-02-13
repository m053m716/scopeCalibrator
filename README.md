# scopeCalibrator #

Basic Matlab code to perform color calibration on image stacks from the MBF scope.



## Installation ##

1. Open Sourcetree (or comparable Git interface)
2. Click the + button:
    ![1550082202245](doc\img\1550082202245.png)
3. Click the Clone button:
    ![1550082251282](doc\img\1550082251282.png)
4. Paste the URL from the main repository as shown, and select the place to clone your local repository. You may wish to make a new folder to keep the local repository in: ![1550082419399](doc\img\1550082419399.png)
5. Click the blue Clone button.
6. The history of commits should populate in the Sourcetree interface:
   ![1550082564633](doc\img\1550082564633.png)
7. To check for subsequent updates, click Fetch and if a number appears next to Pull, click Pull.



## Running Calibration ##

1. Open Matlab, and navigate to the local repository that you created by Cloning from GitHub:
   ![1550082669687](doc\img\1550082669687.png)
2. In the command window, type:
   ![1550082726439](doc\img\1550082726439.png)
3. Follow instructions on the popup boxes to run the calibration.



## Other info ##

* Images can be generally saved as .png, .jpeg, .svg, etc. it shouldn't matter too much. 
* You must have a calibration image that is the same dimensions (height x width) as the images in the stack you wish to apply the correction to. Otherwise it won't run.
* Once you have run the calibration for a given image size once, it saves the correction image and does not need to extract it in subsequent runs. If you want to re-do the calibration for that same image size using a different set of calibration images, run the following from the command window in Matlab:
  ![1550082889903](doc\img\1550082889903.png)

