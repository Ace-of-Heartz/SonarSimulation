include("src/sonarui.jl")
include("src/simulationtypes.jl")
include("src/layertypes.jl")
include("src/utils.jl")

fig = initfigure()

input :: SonarInput = initcontrols(fig)


layer = LayerData(2.0,34.7,input.start[2])

simconfig = SimulationConfig(initray3d(layer,input.))

return fig
