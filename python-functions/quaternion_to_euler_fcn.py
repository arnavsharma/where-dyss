def quaternion_to_euler(q):

    # EECS 568, Winter 2020, Ford Team 1
    #
    # To bring this function into another function/script, please modify/run the following every time you make a change:
    # exec(open("quaternion_to_euler_fcn.py").read())
    #
    # Use this script to convert a quaternion rotation vector to yaw, pitch, and roll
    
    # Inputs:
    #   q           - quaternion rotation vector (4-dim)
    #
    # Outputs:
    #   None
    
    import math
    
    (w, x, y, z) = (q[0], q[1], q[2], q[3])
    
    t0 = +2.0 * (w * x + y * z)
    t1 = +1.0 - 2.0 * (x * x + y * y)
    roll = math.atan2(t0, t1)
    
    t2 = +2.0 * (w * y - z * x)
    t2 = +1.0 if t2 > +1.0 else t2
    t2 = -1.0 if t2 < -1.0 else t2
    pitch = math.asin(t2)
    
    t3 = +2.0 * (w * z + x * y)
    t4 = +1.0 - 2.0 * (y * y + z * z)
    yaw = math.atan2(t3, t4)
    
    return [yaw, pitch, roll]
