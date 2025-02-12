using StaticArrays

include("commontypes.jl")

abstract type Ray end

struct Ray2D <: Ray
    position :: SVector{2, <:Number}
    direction :: SVector{2, <:Number}
    c :: Number
end 

struct Ray3D <: Ray
    position :: SVector{3,<:Number} 
    direction :: SVector{3,<:Number}
    c :: Number
end

