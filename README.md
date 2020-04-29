## Welcome to our project page! [Click Here for Website](https://arnavsharma.github.io/where-dyss/)

We are Where-DYSS (Ford Team No. 1) and this is our project page for Mobile Robotics (EECS 568).

![where-dyss logo](where-dyss-logo.png)

### Team members:

* Arnav Sharma (arnavsha@umich.edu)
* Benjamin Dion (bedion@umich.edu)
* Eric Yu (ericyu@umich.edu)
* Saurabh Sinha (sinhasau@umich.edu)

### Course link:

[Mobile Robotics](http://robots.engin.umich.edu/mobilerobotics/)

### Project Information

In this project, we will compare two different probabilistic filters on the nuScenes by Aptiv dataset. The two filters include an Invariant Extended Kalman Filter utilizing Inertial Measurement Unit (IMU) data for prediction and a pseudo-GPS datastream for correction. The second filter is a Particle Filter which utilizes the semantic annotations/landmarks in the dataset. The paper and presentation can be found in */where-dyss/latex_paper/* directory. Enjoy!

### Python Dependencies
There are quite a few libraries needed for the project code to run. The most important dependency (NuScenes, NuScenesMap, etc.) is explained in */where-dyss/readme_files/dataREADME.md*.

The other ones include:
* numpy
* matplotlib
* h5py
* math
* scipy
* os
* sys
* pickle
* pandas
* warnings
* time

### MATLAB Dependencies
In this project, we used MATLAB R2019b. No special add-on toolboxes are required.

### Step-by-step Instructions
1. Read and complete all steps listed in [dataREADME](readme_files/dataREADME.md). It is very crucial that the resulting folder structure be exactly how it is stated in that README file.
2. Git clone this project! `git clone https://github.com/arnavsharma/where-dyss.git`
3. Running the Particle Filter code
    1. Make sure to read the [pfREADME](readme_files/pfREADME.md) file to get an idea of how the particle filter works.
    2. Follow the steps in there for some particle filter greatness.
4. Running the Invariant Extended Kalman Filter code
    1. Make sure to read the [iekfREADME](readme_files/iekfREADME.md) file to get an idea of how the invariant extended Kalman filter works.
    2. Follow the steps in there for some even more filter greatness.
5. Fork this repository and enjoy!
