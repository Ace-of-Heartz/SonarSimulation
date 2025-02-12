import Base.+

struct Vec4
    x :: Number
    y :: Number
    z :: Number
    w :: Number

    function Vec4(
        x :: Number,
        y :: Number,
        z :: Number,
        w :: Number
    )
        new(x,y,z,w)
    end
end

struct Vec3
    x :: Number
    y :: Number
    z :: Number

    function Vec3(
        x :: Number,
        y :: Number,
        z ::Number
    )
        new(x,y,z)
    end

    function Vec3(
        v :: Vec4
    )
        new(v.x,v.y,v.z)
    end 
end

struct Vec2
    x :: Number
    y :: Number

    function Vec2(
        x :: Number,
        y :: Number
    )
        new(x,y)
    end

    function Vec2(
        v :: Vec4
    )
        new(v.x,v.y)
    end

    function Vec2(
        v :: Vec3
    )
        new(v.x,v.y)
    end
end

function Vec4(
    v :: Vec3,
    w :: Number
)
    Vec4(v.x,v.y,v.z,w)
end 

function Vec4(
    x :: Number,
    v :: Vec3
)
    Vec4(x,v.x,v.y,v.z)
end 

function Vec4(
    x :: Number,
    y :: Number,
    v :: Vec2
)
    Vec4(x,y,v.x,v.y)
end

function Vec4(
    x :: Number,
    v :: Vec2,
    w :: Number
)
    Vec4(x,v.x,v.y,w)
end

function Vec4(
    v :: Vec2,
    z :: Number,
    w :: Number
)
    Vec4(v.x,v.y,z,w)
end

function Vec3(
    v :: Vec2,
    z :: Number 
)
    Vec3(v.x,v.y,z)
end 

function Vec3(
    x :: Number,
    v :: Vec2
)
    Vec3(x,v.x,v.y)
end


(+)(u::Vec4,v::Vec4) = Vec4(u.x + v.x, u.y + v.y, u.z + v.z, u.w + v.w)

(+)(u::Vec3,v::Vec3) = Vec3(u.x + v.x, u.y + v.y, u.z + v.z)

(+)(u::Vec2,v::Vec2) = Vec2(u.x + v.x, u.y + v.y)



