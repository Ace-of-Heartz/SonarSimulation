using StaticArrays

include("commontypes.jl")

abstract type Ray end

struct Ray2D <: Ray
    position :: SVector{2, <:Number}
    direction :: SVector{1, <:Number}
    c :: Number
end 

struct Ray3D <: Ray
    position :: SVector{3,<:Number} 
    direction :: SVector{2,<:Number} 
    velocity :: Number
end
#= Index 1 of direction matters for the RK methods!
|~-_
| . \
|____|_____
|
|
=#
 


