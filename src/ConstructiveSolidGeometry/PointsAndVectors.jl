abstract type AbstractCoordinatePoint{T, S} <: StaticArrays.FieldVector{3, T} end
abstract type AbstractCoordinateVector{T, S} <: StaticArrays.FieldVector{3, T} end


"""
    struct CartesianPoint{T} <: AbstractCoordinatePoint{T, Cartesian}

* `x`: x-coordinate in meter
* `y`: y-coordinate in meter
* `z`: z-coordinate in meter
"""
struct CartesianPoint{T} <: AbstractCoordinatePoint{T, Cartesian}
    x::T
    y::T
    z::T
end

@inline (*)(r::RotMatrix, p::CartesianPoint) = CartesianPoint(r.mat * p)

@inline _in_r(p::CartesianPoint, r::Real) = hypot(p.x, p.y) <= r
@inline _in_r(p::CartesianPoint, r::AbstractInterval) = hypot(p.x, p.y) in r

@inline _in_φ(p::CartesianPoint{T}, φ::AbstractInterval) where {T} = mod(atan(p.y, p.x), T(2π)) in φ    

@inline _in_z(p::CartesianPoint, z::Real) = abs(p.z) <= z
@inline _in_z(p::CartesianPoint, z::AbstractInterval) = p.z in z

# have to add _in_x & _in_y

"""
    struct CartesianVector{T} <: AbstractCoordinateVector{T, Cartesian}

* `x`: x-component in meter
* `y`: y-component in meter
* `z`: z-component in meter
"""
struct CartesianVector{T} <: AbstractCoordinateVector{T, Cartesian}
    x::T
    y::T
    z::T
end

"""
    struct CylindricalPoint{T} <: AbstractCoordinatePoint{T, Cylindrical}

* `r`: Radius in meter
* `φ`: Polar angle in radiance. φ == 0 <=> Parallel to x-axis of cartesian coordinate system."
* `z`: z-coordinate in meter
"""
struct CylindricalPoint{T} <: AbstractCoordinatePoint{T, Cylindrical}
    r::T
    φ::T
    z::T
    CylindricalPoint{T}(r::T, φ::T, z::T) where {T} = new(r, mod(φ,2π), z)
end

function CylindricalPoint(pt::CartesianPoint{T})::CylindricalPoint{T} where {T}
    return CylindricalPoint{T}(hypot(pt.x, pt.y), atan(pt.y, pt.x), pt.z)
end

function CartesianPoint(pt::CylindricalPoint{T})::CartesianPoint{T} where {T}
    sφ::T, cφ::T = sincos(pt.φ)
    return CartesianPoint{T}(pt.r * cφ, pt.r * sφ, pt.z)
end

# Have to add: _in_r, _in_φ, _in_z, _in_x, _in_y for Cylindrical Points
