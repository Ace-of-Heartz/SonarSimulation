include("raytypes.jl")

"""
    Used for specifying the starting config of one ray's simulation
"""

abstract type AbstractFormula 
end

struct Formula2D <: AbstractFormula
    f      :: Function # Function for calculating sound propagation 
    f_dlat :: Function # Partial derivative function on latitude
    f_dz   :: Function # Partial derivative function on depth 
end 

struct Formula3D <: AbstractFormula 
    f      :: Function # Function for calculating sound propagation 
    f_dlat :: Function # Partial derivative function on latitude
    f_dz   :: Function # Partial derivative function on depth 
    f_dlon :: Function # Partial derivative function on longitude
end


struct SimulationConfig
    ray :: Ray
    
    stepsize :: Number
    maxstep :: Integer
    
    formula :: AbstractFormula

    butscher :: ButscherTableau
end




