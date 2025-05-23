# This simulation predicts GB migration of a 2D copper polycrystal with 15 grains
# Mesh adaptivity (new system) and time step adaptivity are used
# An AuxVariable is used to calculate the grain boundary locations
# Postprocessors are used to record time step and the number of grains
# We are not using the GrainTracker in this example so the number
# of order paramaters must match the number of grains.

[Mesh]
  # Mesh block.  Meshes can be read in or automatically generated
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = 24 # Number of elements in the x-direction
  ny = 12 # Number of elements in the y-direction
  nz = 0 # Number of elements in the z-direction
  xmin = 0 # minimum x-coordinate of the mesh
  xmax = 2000 # maximum x-coordinate of the mesh
  ymin = 0 # minimum y-coordinate of the mesh
  ymax = 1000 # maximum y-coordinate of the mesh
  zmin = 0
  zmax = 0
  elem_type = QUAD4 # Type of elements used in the mesh
  uniform_refine = 3 # Initial uniform refinement of the mesh

  parallel_type = replicated # Periodic BCs
[]

[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 10 # Number of grains
  var_name_base = gr # Base name of grains
[]

[UserObjects]
  [voronoi]
    type = PolycrystalVoronoi
    grain_num = 160
    rand_seed = 42
    int_width = 14.0
    # coloring_algorithm = jp # We must use bt to force the UserObject to assign one grain to each op
  []
  [grain_tracker]
    type = GrainTracker
  []
[]

[ICs]
  [PolycrystalICs]
    [PolycrystalColoringIC]
      polycrystal_ic_uo = voronoi
    []
  []
  [bnds]
    type = BndsCalcIC # IC is created for activating the initial adaptivity
    variable = bnds
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
  []
[]

[Variables]
  # Variable block, where all variables in the simulation are declared
  [PolycrystalVariables]
    # Custom action that created all of the grain variables and sets their initial condition
  []
  # [temp]
  #   family = MONOMIAL
  #   initial_condition = 300
  # []
[]

[AuxVariables]
  # Dependent variables
  [bnds]
    # Variable used to visualize the grain boundaries in the simulation
  []
  [temp]
    family = MONOMIAL
    initial_condition = 300
  []
  [liquid]
    family = MONOMIAL
  []
  [unique_grains]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_indices]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  # Kernel block, where the kernels defining the residual equations are set up.
  [PolycrystalKernel]
    # variable_mobility = true
    mob_name = L_mob
    # Custom action creating all necessary kernels for grain growth.  All input parameters are up in GlobalParams
  []
  # [time]
  #   type = HeatConductionTimeDerivative
  #   variable = temp
  # []
  # [heat_conduct]
  #   type = HeatConduction
  #   variable = temp
  #   # thermal_conductivity = thermal_conductivity
  # []
  [f_temp_gr0]
    type = AllenCahn
    f_name = F_temp
    variable = gr0
    mob_name = L_mob
  []
  [f_temp_gr1]
    type = AllenCahn
    f_name = F_temp
    variable = gr1
    mob_name = L_mob
  []
  [f_temp_gr2]
    type = AllenCahn
    f_name = F_temp
    variable = gr2
    mob_name = L_mob
  []
  [f_temp_gr3]
    type = AllenCahn
    f_name = F_temp
    variable = gr3
    mob_name = L_mob
  []
  [f_temp_gr4]
    type = AllenCahn
    f_name = F_temp
    variable = gr4
    mob_name = L_mob
  []
  [f_temp_gr5]
    type = AllenCahn
    f_name = F_temp
    variable = gr5
    mob_name = L_mob
  []
  [f_temp_gr6]
    type = AllenCahn
    f_name = F_temp
    variable = gr6
    mob_name = L_mob
  []
  [f_temp_gr7]
    type = AllenCahn
    f_name = F_temp
    variable = gr7
    mob_name = L_mob
  []
  [f_temp_gr8]
    type = AllenCahn
    f_name = F_temp
    variable = gr8
    mob_name = L_mob
  []
  [f_temp_gr9]
    type = AllenCahn
    f_name = F_temp
    variable = gr9
    mob_name = L_mob
  []
[]

[AuxKernels]
  # AuxKernel block, defining the equations used to calculate the auxvars
  [bnds_aux]
    # AuxKernel that calculates the GB term
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
    execute_on = timestep_end
  []
  [temp]
    type = MaterialRealAux
    variable = temp
    property = temp_source
  []
  [liquid]
    type = MaterialRealAux
    variable = liquid
    property = liquid_phase
  []
  [unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
    execute_on = 'initial timestep_end'
  []
  [var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    flood_counter = grain_tracker
    field_display = VARIABLE_COLORING
    execute_on = 'initial timestep_end'
  []
[]

[BCs]
  # Boundary Condition block
  [Periodic]
    [top_bottom]
      auto_direction = 'x y' # Makes problem periodic in the x and y directions
    []
  []
[]

[Materials]
  [CuGrGr]
    # Material properties
    type = GBEvolution # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
    GBmob0 = 2.5e-6 # Mobility prefactor for Cu from Schonfelder1997
    GBenergy = 0.708 # GB energy for Cu from Schonfelder1997
    Q = 0.23 # Activation energy for grain growth from Schonfelder 1997
    T = temp # Constant temperature of the simulation (for mobility calculation)
    wGB = 14 # Width of the diffuse GB
    outputs = exodus
  []
  [liquid_phase]
    type = DerivativeParsedMaterial
    property_name = liquid_phase
    material_property_names = 'temp_source'
    # expression = ' if(temp_source>1700, 1.0, 0.5*(1+tanh((temp_source-1700)/sqrt(2))))'
    expression = '(1+tanh((temp_source-1700)/sqrt(2)))'
    outputs = exodus
  []
  [mob]
    type = DerivativeParsedMaterial
    property_name = L_mob
    # coupled_variables = 'li'
    material_property_names = 'L liquid_phase'
    expression = 'L*(1.0-liquid_phase)'
    outputs = exodus
    output_properties = 'L_mob'
  []
  [meltpool]
    type = RosenthalTemperatureSource
    power = 200000
    velocity = 20.0
    absorptivity = 1.0
    melting_temperature = 1700
    ambient_temperature = 393
    initial_position = '0.0 500.0 0.0'
    outputs = exodus
  []
  [heat]
    type = HeatConductionMaterial
    specific_heat = 650
    thermal_conductivity = 20e-2
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '8000e-12'
  []
  [switching_temp]
    type = DerivativeParsedMaterial
    property_name = h
    # coupled_variables = 'gr0 gr1 gr2 gr3'
    coupled_variables = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
    expression = 'gr0*gr0*gr0*(20-45*gr0+36*gr0*gr0-10*gr0*gr0*gr0)
                + gr1*gr1*gr1*(20-45*gr1+36*gr1*gr1-10*gr1*gr1*gr1)
                + gr2*gr2*gr2*(20-45*gr2+36*gr2*gr2-10*gr2*gr2*gr2)
                + gr3*gr3*gr3*(20-45*gr3+36*gr3*gr3-10*gr3*gr3*gr3)
                + gr4*gr4*gr4*(20-45*gr4+36*gr4*gr4-10*gr4*gr4*gr4)
                + gr5*gr5*gr5*(20-45*gr5+36*gr5*gr5-10*gr5*gr5*gr5)
                + gr6*gr6*gr6*(20-45*gr6+36*gr6*gr6-10*gr6*gr6*gr6)
                + gr7*gr7*gr7*(20-45*gr7+36*gr7*gr7-10*gr7*gr7*gr7)
                + gr8*gr8*gr8*(20-45*gr8+36*gr8*gr8-10*gr8*gr8*gr8)
                + gr9*gr9*gr9*(20-45*gr9+36*gr9*gr9-10*gr9*gr9*gr9)'
  []
  [temp_energy]
    type = DerivativeParsedMaterial
    property_name = F_temp
    coupled_variables = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
    material_property_names = 'h temp_source'
    expression = '(1700 - temp_source)/1700*h'
    output_properties = 'F_temp'
    outputs = exodus
  []
[]

[Postprocessors]
  # Scalar postprocessors
  [dt]
    # Outputs the current time step
    type = TimestepSize
  []
[]

[Executioner]
  type = Transient # Type of executioner, here it is transient with an adaptive time step
  scheme = bdf2 # Type of time integration (2nd order backward euler), defaults to 1st order backward euler

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -mat_mffd_type'
  petsc_options_value = 'hypre    boomeramg      101                ds'

  l_max_its = 30 # Max number of linear iterations
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-11 # Relative tolerance for nonlienar solves
  nl_rel_tol = 1e-10 # Absolute tolerance for nonlienar solves

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0 # Initial time step.  In this simulation it changes.
    cutback_factor = 0.5
    optimal_iterations = 6
    iteration_window = 2
    growth_factor = 2
  []

  start_time = 0.0
  end_time = 4000
  # num_steps = 30
[]

[Adaptivity]
  marker = errorfrac
  max_h_level = 4
  initial_marker = errorfrac
  initial_steps = 3
  [Indicators]
    [error]
      type = GradientJumpIndicator
      variable = bnds
    []
  []
  [Markers]
    [bound_adapt]
      type = ValueThresholdMarker
      third_state = DO_NOTHING
      coarsen = 1.0
      refine = 0.99
      variable = bnds
      invert = true
    []
    [errorfrac]
      type = ErrorFractionMarker
      coarsen = 0.05
      indicator = error
      refine = 0.6
    []
  []
[]

[Outputs]
  exodus = true
  csv = true
  [console]
    type = Console
    max_rows = 20
  []
[]
