module ReachabilityAnalysis

# ===========================================================
# Dependencies & User API
# ===========================================================
include("Initialization/init.jl")
include("Initialization/exports.jl")
include("Continuous/solve.jl")

# ===========================================================
# Structures to represent solutions of reachability problems
# ===========================================================
include("Flowpipes/setops.jl")
include("ReachSets/reachsets.jl")
include("Flowpipes/flowpipes.jl")
include("Flowpipes/arrayops.jl")
include("Flowpipes/clustering.jl")
include("Flowpipes/solutions.jl")

# ===========================================================
# Shared functionality for continuous systems
# ===========================================================
include("Continuous/fields.jl")
include("Continuous/normalization.jl")
include("Continuous/homogeneization.jl")
include("Continuous/linearization.jl")
include("Discretization/exponentiation.jl")
include("Discretization/discretization.jl")

# ===========================================================
# Reachability solver algorithms
# ===========================================================

# Linear
include("Algorithms/A20/A20.jl")
include("Algorithms/LGG09/LGG09.jl")
include("Algorithms/GLGM06/GLGM06.jl")
include("Algorithms/INT/INT.jl")
include("Algorithms/BOX/BOX.jl")
include("Algorithms/BFFPSV18/BFFPSV18.jl")
include("Algorithms/ASB07/ASB07.jl")
include("Algorithms/ORBIT/ORBIT.jl")
include("Algorithms/VREP/VREP.jl")

# Nonlinear
include("Algorithms/CARLIN/CARLIN.jl")
include("Algorithms/TMJets/TMJets21b/TMJets21b.jl")
include("Algorithms/TMJets/common.jl")
include("Algorithms/TMJets/TMJets21a/TMJets21a.jl")
include("Algorithms/TMJets/TMJets20/TMJets20.jl")
include("Algorithms/QINT/QINT.jl")

# ===========================================================
# Discrete post-operators for hybrid systems
# ===========================================================
include("Hybrid/constructors.jl")
include("Hybrid/waiting_list.jl")
include("Hybrid/transitions.jl")
include("Hybrid/time_triggered.jl")
include("Hybrid/solve.jl")

# visualization
include("Flowpipes/recipes.jl")

end # module
