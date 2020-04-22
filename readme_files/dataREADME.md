## Welcome to the Data README!

The data used in the project is from the publicly available source [NuScenes by Aptiv](https://www.nuscenes.org)]. It is a very large dataset (~500 GB) for development of autonomous driving. There are multiple situations (clear, rain, wet, straight driving, left/right turns, etc.) that seem very attractive for anyone studying autonomous driving. The semantic annotation is quite detailed and 20+ classes are provided. More detailed information about this dataset can be found at their website in the link above.

To download the data to use our project code, please follow the following steps:
1. Clone the NuScenes GitHub [repository]{https://github.com/nutonomy/nuscenes-devkit} into your $HOME directory. Then change directories into *nuscenes-devkit*. Install NuScenes by running the following code: and install it using `pip3 install nuscenes-devkit`.
2. In the project directory */where-dyss/data/sets/nuscenes/*, please [download]{https://www.nuscenes.org/download} the US (unless specified) versions of CAN bus expansion, Map expansion, Full dataset (v1.0) (Metadata, Trainval Zip folders: 1, 3, 4, 5, (Asia) 10). This will include all the data used in our project. To use other scenes that may be provided in other Zip folders, please download the other Zip folders as you see fit.
3. After all is downloaded, please go back to the *$HOME/nuscenes-devkit* directory in Terminal and run `pip3 install -r setup/requirements.txt`.

The final folder structure for the data should be as follows:
* */where-dyss/data/sets/nuscenes/can_bus/ * .json*
* */where-dyss/data/sets/nuscenes/maps/ * .json and * .png* 
* */where-dyss/data/sets/nuscenes/v1.0-trainval/ * .json*
* */where-dyss/data/sets/nuscenes/samples/*
* */where-dyss/data/sets/nuscenes/sweeps/*

The *samples* and *sweeps* folders will have the data files from all cameras, LiDAR, and RADAR. 

For our project, all data and necessary variables we used have been saved in .pickle (for Python) and .mat (for Matlab and Python plotting) files. So if you would like to run the algorithms on other scenes we have not analyzed, please leaf through the scripts/functions called and change variables as needed.
