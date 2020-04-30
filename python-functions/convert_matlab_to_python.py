def convert_matlab_to_python(filter_string, scene_choice):

    # EECS 568, Winter 2020, Ford Team 1
    #
    # To bring this function into another function/script, please modify/run the following every time you make a change:
    # exec(open("convert_matlab_to_python.py").read())
    #
    # Use this to convert Matlab data to be used in Python
    #
    # Inputs:
    #   filter_string           - either 'PF' or 'IEKF'
    #   scene_choice            - scene number .mat file to be converted
    #
    # Outputs:
    #   arrays                  - dictionary of data from .mat file

    import h5py
    import numpy as np

    if filter_string == 'PF':
        filepath = '../output/Matlab/PF_To_Python/Variable_Landmarks/' + scene_choice + '_2py.mat'
    elif filter_string == 'IEKF':
        filepath = '../output/Matlab/IEKF_To_Python/data/' + scene_choice + '_iekf_2py.mat'

    arrays = {}

    f = h5py.File(filepath, 'r')

    for k, v in f.items():
        arrays[k] = np.array(v)

    return arrays
