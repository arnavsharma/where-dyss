def plot_car(x_plot, y_plot, yaw_data):

    # EECS 568, Winter 2020, Ford Team 1
    #
    # To bring this function into another function/script, please modify/run the following every time you make a change:
    # exec(open("plot_car.py").read())
    #
    # Script used to generate vehicle box on fancy map
    #
    # Inputs:
    #   x_plot          - center point of ego_vehicle in x
    #   y_plot          - center point of ego_vehicle in y
    #   yaw_data        - yaw (heading) of ego_vehicle in global frame
    #
    # Outputs:
    #   Xrot            - array of rotated vehicle x coordinates for plotting
    #   Yrot            - array of rotated vehicle y coordinates for plotting

    import math

    # Renault Zoe dimensions in meters
    L = 4.084 # Zoe length in meters
    W = 1.730 # Zoe width in meters

    # Specify vehicle center
    Xc = x_plot
    Yc = y_plot

    # Plot 4 corners of vehicle [RR, FR, FL, RL, RR] Extra RR to complete the rectangle
    X = [-L/2, L/2, L/2, -L/2, -L/2]
    Y = [-W/2, -W/2, W/2, W/2, -W/2]

    # Set rotation parameter for yaw in radians (Positive is CCW)
    theta = yaw_data

    c_th = math.cos(theta)
    s_th = math.sin(theta)

    # Set up rotation of vehicle around vehicle center
    Xrot = np.asarray(X)*c_th - np.asarray(Y)*s_th
    Yrot = np.asarray(X)*s_th + np.asarray(Y)*c_th


    return Xrot, Yrot
