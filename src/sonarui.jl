using GLMakie 
using StaticArrays

include("src/butscher.jl")

struct SonarInput
    start :: SVector{3,<:Number} 
    topdownlimits :: Tuple # Angle
    sideviewlimits :: Tuple # Angle
    raynumber :: Integer
    maxstep :: Integer
    maxdistance :: Number
    stepsize :: Number
    butscher :: Function
end

function initfigure() :: Figure 
    fig = Figure()

    return fig
end

function initcontrols(fig :: Figure)

    #TODO: Fix layout sizing
    other_gl = fig[2,1] = GridLayout()
    topdown_gl = fig[2,2] = GridLayout()
    sideview_gl = fig[2,3] = GridLayout()

    topdown_slider = addsliderwithpolaraxis("Sonar Top-down Angle",1,(0,2pi),topdown_gl,"Top-down starting angle", "Top-down closing angle")
    sideview_slider = addsliderwithpolaraxis("Sonar Sideview Angle",-1,(0,pi),sideview_gl,"Side-view starting angle", "Side-view closing angle")

    Label(other_gl[1,1],"Number of Rays to Launch:",halign = :left)
    Textbox(other_gl[1,2],validator = Int16,placeholder = "16",halign = :left)

    Label(other_gl[2,1],"Maximum Number of Steps:",halign = :left)
    Textbox(other_gl[2,2],validator = Int16, placeholder = "120",halign = :left)

    Label(other_gl[3,1],"Maximum Distance:",halign = :left)
    Textbox(other_gl[3,2],validator = Float32, placeholder = "6000",halign = :left)

    Label(other_gl[4,1],"Starting Stepsize:",halign = :left)
    Textbox(other_gl[4,2],validator = Float32, placeholder = "2.5",halign = :left)

    funcs = [get_euler_tableau,get_midpoint_tableau,get_rk4_tableau,get_rkf45_tableau]

    Label(other_gl[5,1],"RK Method:",halign = :left)
    Menu(other_gl[5,2],options = zip(["Euler","Midpoint","RK4","RKF45"],funcs),default = "Euler",halign = :left)

    pos_gl = other_gl[6,1:2] = GridLayout()

    Label(pos_gl[1,1],"Starting Position (X,Y,Z):")
    Textbox(pos_gl[1,2],validator = Float32, placeholder = "2.5",halign = :left)
    Textbox(pos_gl[1,3],validator = Float32, placeholder = "2.5",halign = :left)
    Textbox(pos_gl[1,4],validator = Float32, placeholder = "2.5",halign = :left)

end

function addsliderwithpolaraxis(
    axistitle :: String,
    axisdir :: Integer,
    (s_angle,f_angle) :: Tuple,
    gl :: GridLayout,
    startinglabel :: String,
    closinglabel :: String
    ) :: IntervalSlider

    top_gl = gl[1,1]

    angle_h = IntervalSlider(top_gl[1,2], range = LinRange(s_angle, f_angle,361),startvalues = (s_angle, f_angle/2), horizontal = false, height = 200)
    
    angletext = lift(angle_h.interval) do (start,finish)
        "$(round.(start/ (2pi) * 360, digits = 0) )° : $(round.(finish / (2pi) * 360,digits = 0) )°"
    end

    bottom_gl = gl[2,1] = GridLayout()
    bbottom_gl = bottom_gl[1,1] = GridLayout()
    s = Textbox(bbottom_gl[1,1],validator = Int16,placeholder = "$(s_angle / 2pi * 360)")
    f = Textbox(bbottom_gl[1,2],validator = Int16,placeholder = "$(f_angle/2 / 2pi * 360)")

    on(s.stored_string) do val 
        println(val)
        set_close_to!(angle_h,s_angle + parse(Int16,val) / (f_angle/2pi * 360 - s_angle/2pi * 360) * f_angle,angle_h.interval[][2])
    end

    on(f.stored_string) do val
        println(val)
        set_close_to!(angle_h,angle_h.interval[][1],s_angle + parse(Int16,val) / (f_angle/2pi * 360 - s_angle/2pi * 360) * f_angle )
    end
    
    Label(bottom_gl[2, 1], angletext, tellwidth = false)
    
    pax = PolarAxis(
        top_gl[1,1],
        title = axistitle,
        thetalimits = (s_angle,f_angle),
        width = 300,
        thetazoomlock = true, rzoomlock = true,
        direction = axisdir
        )
    
    rlims!(pax,0,1)
    p = lift(angle_h.interval) do (start,finish)
        empty!(pax)
        rs = 0:10
        phis = range(start,finish, 37)
        cs = [r+cos(4phi) for phi in phis, r in rs]

        surface!(pax,  start..finish, 0..1, zeros(size(cs)), color = cs, shading = NoShading, colormap = :seaborn_flare_gradient)

    end

    return angle_h;
end