using StaticArrays

struct ButscherTableau{N,S}
    x_steps :: SVector{N,<:Number}   # "a"
    y_steps :: SMatrix{N,N,<:Number} # "b"
    weights :: SMatrix{S,N,<:Number} # "c" 
    # TODO: Checks for type of N and S parameters
end

""" 
    Returns the Butscher tableau of the fourth degree Runge-Kutta (RK4) method
"""
function get_rk4_tableau() :: ButscherTableau
    x_steps :: SVector{4,<:Number} = [0, 1/2, 1/2, 1 ];
    y_steps :: SMatrix{4,4,<:Number} = [
        0    0   0 0;
        1/2  0   0 0;
        0   1/2  0 0;
        0    0   1 0
    ];
    weights :: SMatrix{1,4,<:Number} = [ 1/6  1/3  1/3  1/6];

    return ButscherTableau{4,1}(x_steps, y_steps,weights);
end 

"""
    Returns the Butscher tableau of the Euler's method
"""
function get_euler_tableau() :: ButscherTableau
    x_steps :: SVector{1,<:Number} = [0];
    y_steps :: SMatrix{1,1,<:Number} = [0] ;
    weights :: SMatrix{1,1,<:Number} = [1];

    return ButscherTableau{1,1}(x_steps,y_steps,weights);
end

"""
    Returns the Butscher tableau of Heune's method
"""
function get_midpoint_tableau() :: ButscherTableau
    x_steps :: SVector{2<:Number} = [0, 1/2];
    y_steps :: SMatrix{2,2<:Number} = [0 0; 1/2 0];
    weights :: SMatrix{2,1<:Number} = [0, 1];

    return ButscherTableau{2,1}(x_steps,y_steps,weights);
end


"""
    Returns the Butscher tableau of Runge-Kutta-Fehlberg's method
"""
function get_rkf45_tableau() :: ButscherTableau
    x_steps :: SVector{6,<:Number} = [0, 1/4, 3/8, 12/13, 1, 1/2];
    y_steps :: SMatrix{6,6,<:Number} = [
        0          0         0           0        0      0;
        1/4        0         0           0        0      0;
        3/32       9/32      0           0        0      0;
        1932/2197 -7200/2197 7296/2197   0        0      0;
        439/216   -8         3680/513   -845/4104 0      0;
        -8/27      2         -3544/2565 1859/4104 -11/40 0;
    ];
    weights :: SMatrix{6,2,<:Number} = [
        16/135 0 6656/12825 28561/56430 -9/50 2/55;
        25/216 0 1408/2565  2197/4104   -1/5 0;
    ];

    return ButscherTableau{6,2}(x_steps,y_steps,weights);
end
