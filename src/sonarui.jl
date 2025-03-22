using GLMakie 
using StaticArrays

include("butscher.jl")
include("soundpropagation.jl")

mutable struct SonarInput
    
    start :: SVector{3,<:Number} 

    topdownlimits :: Tuple # Angle 
    sideviewlimits :: Tuple # Angle
    
    raynumber :: Integer 

    maxstep :: Integer 
    maxdistance :: Number 
    
    stepsize :: Number 
    butscher :: Function 

    formula :: AbstractFormula
end

function initfigure() :: Figure 
    fig = Figure()

    return fig
end


function initcontrols(fig :: Figure) :: SonarInput

    input :: SonarInput = SonarInput(
        SVector(0,0,0),
        (0,30),(0,75),
        16,
        120, 8500,
        10,
        get_euler_tableau,
        Formula3D(mackenzie,mackenzie_dr,mackenzie_dz,0) # TODO Fix the 3rd derivative
    )

    #TODO: Fix layout sizing
    other_gl = fig[2,1] = GridLayout()
    topdown_gl = fig[2,2] = GridLayout()
    sideview_gl = fig[2,3] = GridLayout()

    topdown_slider = addsliderwithpolaraxis("Sonar Top-down Angle",1,(0,2pi),topdown_gl,"Top-down starting angle", "Top-down closing angle")
    sideview_slider = addsliderwithpolaraxis("Sonar Sideview Angle",-1,(0,pi),sideview_gl,"Side-view starting angle", "Side-view closing angle")

    input = addtextboxinputs(other_gl,input)

    return input
end


function addtextboxinputs(gl :: GridLayout,input :: SonarInput) :: SonarInput
    Label(gl[1,1],"Number of Rays to Launch:",halign = :left)
    raynuminput = Textbox(gl[1,2],validator = Int16,placeholder = "16",halign = :left)

    Label(gl[2,1],"Maximum Number of Steps:",halign = :left)
    maxstepsinput = Textbox(gl[2,2],validator = Int16, placeholder = "120",halign = :left)

    Label(gl[3,1],"Maximum Distance:",halign = :left)
    maxdistanceinput = Textbox(gl[3,2],validator = Float32, placeholder = "6000",halign = :left)

    Label(gl[4,1],"Starting Stepsize:",halign = :left)
    startingstepsizeinput = Textbox(gl[4,2],validator = Float32, placeholder = "2.5",halign = :left)

    funcs = [get_euler_tableau,get_midpoint_tableau,get_rk4_tableau,get_rkf45_tableau]

    Label(gl[5,1],"RK Method:",halign = :left)
    rkmenu = Menu(gl[5,2],options = zip(["Euler","Midpoint","RK4","RKF45"],funcs),default = "Euler",halign = :left)

    pos_gl = gl[6,1:2] = GridLayout(halign = :left)

    Label(pos_gl[1,1],"Starting Position (X,Y,Z):")
    startingposinput_x = Textbox(pos_gl[1,2],validator = Float32, placeholder = "2.5",halign = :left)
    startingposinput_y = Textbox(pos_gl[1,3],validator = Float32, placeholder = "2.5",halign = :left)
    startingposinput_z = Textbox(pos_gl[1,4],validator = Float32, placeholder = "2.5",halign = :left)

    on(raynuminput.stored_string) do val
        input.raynumber = parse(Int16,val);
    end

    on(maxstepsinput.stored_string) do val
        input.maxstep = parse(Int16,val);
    end

    on(maxdistanceinput.stored_string) do val
        input.maxdistance = parse(Float32,val);
    end

    on(startingstepsizeinput.stored_string) do val
        input.stepsize = parse(Float32,val);
    end

    on(rkmenu.selection) do sel
        input.butscher = sel;
    end

    on(startingposinput_x.stored_string) do x
        input.start[1] = parse(Float32,x);
    end

    on(startingposinput_y.stored_string) do y 
        input.start[2] = parse(Float32,y);
    end

    on(startingposinput_z.stored_string) do z
        input.start[3] = parse(Float32,z);
    end


    return input;
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