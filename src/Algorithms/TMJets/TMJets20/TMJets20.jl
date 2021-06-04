"""
    TMJets20{N, DM<:AbstractDisjointnessMethod} <: AbstractContinuousPost

Validated integration using Taylor models.

### Fields

- `orderQ`       -- (optional, default: `2`) order of the Taylor models for jet transport variables
- `orderT`       -- (optional, default: `8`) order of the Taylor model in time
- `abstol`       -- (optional, default: `1e-10`) absolute tolerance
- `maxsteps`     -- (optional, default: `2000`) maximum number of steps in the
                     validated integration ``x' = f(x)``
- `adaptive`     -- (optional, default: `true`) if `true`, try decreasing the absolute
                     tolerance each time step validation fails, until `min_abs_tol` is reached
- `minabstol`    -- (optional, default: `1e-29`) minimum absolute tolerance for the adaptive algorithm
- `disjointness` -- (optional, default: `ZonotopeEnclosure()`) defines the method to
                     perform the disjointness check between the taylor model flowpipe and the invariant

### Notes

The argument `disjointness` allows to control how are disjointness checks
computed, in the case where the invariant is not universal. In particular,
`ZonotopeEnclosure()` pre-processes the taylor model with a zonotopic
overapproximation, then performs the disjointness check with that zonotope and the
invariant. For other options, see the documentation of `AbstractDisjointnessMethod`.

This algorithm is an adaptation of the implementation in `TaylorModels.jl`
(see copyright license in the file `reach.jl` of the current folder). The package
`TaylorIntegration.jl` is used for jet-transport of ODEs using the Taylor method,
and `TaylorSeries.jl` is used to work with truncated Taylor series.
"""
@with_kw struct TMJets20{N, DM<:AbstractDisjointnessMethod} <: AbstractContinuousPost
    orderQ::Int=DEFAULT_ORDER_Q_TMJETS
    orderT::Int=DEFAULT_ORDER_T_TMJETS
    abstol::N=DEFAULT_ABS_TOL_TMJETS
    maxsteps::Int=DEFAULT_MAX_STEPS_TMJETS
    adaptive::Bool=true
    minabstol::N=1e-29
    disjointness::DM=ZonotopeEnclosure()
end

const DEFAULT_MAX_STEPS_TMJETS = 2000
const DEFAULT_ABS_TOL_TMJETS = 1e-10
const DEFAULT_ORDER_T_TMJETS = 8
const DEFAULT_ORDER_Q_TMJETS = 2

numtype(::TMJets20{N}) where {N} = N
rsetrep(::TMJets20{N}) where {N} = TaylorModelReachSet{N}

include("post.jl")
include("reach.jl")