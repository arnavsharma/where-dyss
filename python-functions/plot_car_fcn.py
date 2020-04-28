def plot_car(x_plot, y_plot, yaw_data):
    # Script used to generate vehicle box on fancy map

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
