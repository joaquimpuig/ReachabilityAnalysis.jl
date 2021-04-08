# ================================================================
# Template reach set
# ================================================================

"""
    TemplateReachSet{N, VN, TN<:AbstractDirections{N, VN}, SN<:AbstractVector{N}} <: AbstractLazyReachSet{N}

Reach set that stores the support function of a set at a give set of directions.

### Notes

The struct has the following parameters:

- `N`  -- refers to the numerical type of the representation.
- `VN` -- refers to the vector type of the template
- `TN` -- refers to the template type
- `SN` -- vector type that holds the support function evaluations

Concrete subtypes of `AbstractDirections` are defined in the `LazySets` library.

This reach-set implicitly represents a set by a set of directions and support
functions. `set(R::TemplateReachSet)` returns a polyhedron in half-space
representation.

Apart from the getter functions inherited from the `AbstractReachSet` interface,
the following methods are available:

- `directions(R)`           -- return the set of directions normal to the faces of this reach-set
- `support_functions(R)`    -- return the vector of support function evaluations
- `support_functions(R, i)` -- return the `i`-th coordinate of the vector of support function evaluatons
"""
struct TemplateReachSet{N, VN, TN<:AbstractDirections{N, VN}, SN<:AbstractVector{N}} <: AbstractLazyReachSet{N}
    dirs::TN
    sf::SN
    Δt::TimeInterval
end

# constructor from a given set (may overapproximate)
function TemplateReachSet(dirs::AbstractDirections, X::LazySet, Δt::TimeInterval)
    sfunc = [ρ(d, X) for d in dirs]
    return TemplateReachSet(dirs, sfunc, Δt)
end

# constructor from a given reach-set (may overapproximate)
function TemplateReachSet(dirs::AbstractDirections, R::AbstractLazyReachSet)
    return TemplateReachSet(dirs, set(R), tspan(R))
end

# abstract reachset interface
function set(R::TemplateReachSet)
    T = isbounding(R.dirs) ? HPolytope : HPolyhedron
    return T([HalfSpace(di, R.sf[i]) for (i, di) in enumerate(R.dirs)])
end

# FIXME requires adding boundedness property as a type parameter
setrep(::Type{<:TemplateReachSet{N, VN}}) where {N, VN} = HPolyhedron{N, VN}
setrep(::TemplateReachSet{N, VN}) where {N, VN} = HPolyhedron{N, VN}

tspan(R::TemplateReachSet) = R.Δt
tstart(R::TemplateReachSet) = inf(R.Δt)
tend(R::TemplateReachSet) = sup(R.Δt)
dim(R::TemplateReachSet) = dim(R.dirs)
vars(R::TemplateReachSet) = Tuple(Base.OneTo(dim(R)),)

directions(R::TemplateReachSet) = R.dirs
support_functions(R::TemplateReachSet) = R.sf
support_functions(R::TemplateReachSet, i::Int) = R.sf[i]

_collect(dirs::AbstractDirections) = collect(dirs)
_collect(dirs::CustomDirections) = dirs.directions

# overapproximate a given reach-set with a template
function overapproximate(R::AbstractLazyReachSet, dirs::AbstractDirections) where {VN}
    return TemplateReachSet(dirs, R)
end
function overapproximate(R::AbstractLazyReachSet, dirs::Vector{VN}) where {VN}
    return TemplateReachSet(CustomDirections(dirs), R)
end

# concrete projection of a TemplateReachSet for a given direction
function project(R::TemplateReachSet, dir::AbstractVector{<:AbstractFloat}; vars=nothing)
    ρdir = ρdir₋ = nothing
    dir₋ = -dir
    @inbounds for (i, d) in enumerate(R.dirs)
        if iszero(norm(dir - d))
            ρdir = R.sf[i]
        elseif iszero(norm(dir₋ - d))
            ρdir₋ = -R.sf[i]
        end
    end
    if isnothing(ρdir)
        ρdir = ρ(dir, R)
    end
    if isnothing(ρdir₋)
        ρdir₋ = -ρ(ρdir₋, R)
    end
    πR = ReachSet(Interval(min(ρdir, ρdir₋), max(ρdir, ρdir₋)), tspan(R))
    return isnothing(vars) ? πR : project(πR, vars)
end

# concrete projection of a vector of TemplateReachSet for a given direction
function project(Xk::Vector{<:TemplateReachSet}, dir::AbstractVector{<:AbstractFloat}; vars=nothing)
    return map(X -> project(X, dir, vars=vars), Xk)
end

# convenience functions to get support directions of a given set
_getdirs(X::LazySet) = [c.a for c in constraints_list(X)]
LazySets.CustomDirections(X::LazySet) = CustomDirections(_getdirs(X), dim(X)) # TODO may use isboundedtype trait