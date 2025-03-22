include("raytypes.jl")

function initray3d(
    layer :: LayerData,
    formula :: Function,
    position :: SVector{3,<:Number},
    takeoffangle :: SVector{2,<:Number}
    ) :: Ray
    
    velocity = formula(layer);

    zeta = cos(takeoffangle[1]) / velocity; 
    xi = sin(takeoffangle[1]) / velocity;
    
    return Ray3D(position,SVector(zeta,xi),velocity)
end