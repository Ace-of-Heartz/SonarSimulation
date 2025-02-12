
include("layertypes.jl")
include("simulationtypes.jl")
include("butscher.jl")


function calculate_raypath(
    config :: SimulationConfig
)
    ray0 = config.ray;

    rays = Array{Ray}(undef,config.maxstep)

    
    
    #while end # TODO: Adaptive 
    stepsize = config.stepsize

    for t = 1 : stepsize : config.maxstep
        rays[s] = ray;

        ray = rk_step(config.stepsize,t,ray,config.formula,config.butscher);

        # TODO: Check for bounces
    end

    return rays;
end

"""
Function responsible for calculating the ray's attributes at the i-th step using Runge-Kutta methods

# Arguments
- `h :: Number`: step size of the Runge-Kutta method
- `t_i :: Number`: i-th time step 
- `r_i :: Ray`: ray attributes calculated at i-th step 
- `formulas :: AbstractFormula` formulas used for the numerical integration
- `butscher :: ButscherTableau` Butscher tableau of the Runge-Kutta method used  
"""
function rk_step(
    stepsize :: Number, # stepsize
    t_i :: Number, # arclength
    r_i :: Ray, # ray attributes
    formulas :: AbstractFormula,
    butscher :: ButscherTableau
) :: Ray

    (n,s) = typeparams(butscher);

    ks = SVector{n,<:Number}();


    layer = LayerData(2.0,34.7,r_i.position.y);
    d_ray = integrate(stepsize,r_i,formulas,layer);

    ks[1] = d_ray;

    for i = 2:n
        k_i = r_i;
        for j = 1:(i-1)
            k_i += ks[i] * butscher.y_steps[i,j] * stepsize;
        end

        ks[i] = integrate(stepsize,k_i,formulas,layer)
    end

    u_iplus1 = u_i;

    if (s == 1)
        for i in eachindex(butscher.weights)
            u_iplus1 += ks[i] * butscher.weights[1,i] * stepsize;
        end
    else # ADAPTIVE
        u_test = u_i;

        for i in eachindex(butscher.weights)
            u_iplus1 += ks[i] * butscher.weights[1,i] * stepsize;
            u_test += ks[i] * butscher.weights[2,i] * stepsize;
        end

        if (u_test - u_iplus1 > 0.1)
            println("ADAPTIVE")
        end
    end

    return u_iplus1;
end 



using StaticArrays

function integrate(
    stepsize :: Number,
    r_i :: Ray2D,
    formula :: Formula2D,
    layer :: LayerData,
) :: Ray3D
    _, dir_i, c_i = r_i;

    alpha = -1 / (c_i^2)

    c = formula.f(layer); 

    d_ray = Ray(
        dir_i * c,
        SVector{2,<:Number}(
            alpha * formula.f_dlat(layer),
            alpha * formula.f_dz(layer)
            ),
        c
    )


    return d_ray;
end 

function integrate(
    stepsize :: Number,
    r_i :: Ray3D,
    formula :: Formula3D,
    layer :: LayerData,
) :: Ray3D
    _, dir_i, c_i = r_i;

    alpha = -1 / (c_i^2)

    c = formula.f(layer); 

    d_ray = Ray(
        dir_i * c,
        SVector{3,<:Number}(
            alpha * formula.f_dlat(layer),
            alpha * formula.f_dz(layer),
            alpha * formula.f_dlon(layer)
            ),
        c
    )
    return d_ray;
end 

