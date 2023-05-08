[Mesh]
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = 15 # Number of elements in the x-direction
  ny = 6 # Number of elements in the y-direction
  xmin = 0 # minimum x-coordinate of the mesh
  xmax = 1500 # maximum x-coordinate of the mesh
  ymin = -300 # minimum y-coordinate of the mesh
  ymax = 300 # maximum y-coordinate of the mesh
  elem_type = QUAD4 # Type of elements used in the mesh
  uniform_refine = 3 # Initial uniform refinement of the mesh

  parallel_type = replicated # Periodic BCs
[]

[Variables]
  [temp]
    initial_condition = 300
  []
[]

[AuxVariables]
  [temp_src]
    order = FIRST
    family = MONOMIAL
  []
[]

[AuxKernels]
  [temp_src]
    type = ADMaterialRealAux
    variable = temp_src
    property = temp_source
  []
[]

[Kernels]
  [time]
    type = ADHeatConductionTimeDerivative
    variable = temp
  []
  [heat_conduct]
    type = ADHeatConduction
    variable = temp
    thermal_conductivity = thermal_conductivity
  []
[]

[Materials]
  [heat]
    type = ADHeatConductionMaterial
    specific_heat = 500
    thermal_conductivity = 20e-2
  []
  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '8000e-12'
  []
  [meltpool]
    type = ADRosenthalTemperatureSource
    power = 100000
    velocity = 2.0
    absorptivity = 1.0
    melting_temperature = 1700
    ambient_temperature = 300
  []
[]

[Postprocessors]
  [meltpool_depth]
    type = ADElementAverageMaterialProperty
    mat_prop = meltpool_depth
  []
  [meltpool_width]
    type = ADElementAverageMaterialProperty
    mat_prop = meltpool_width
  []
  [max_temp]
    type = ADElementExtremeMaterialProperty
    mat_prop = temp_source
    value_type = max
  []
[]

[Preconditioning]
  [full]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'preonly lu       superlu_dist'

  l_max_its = 100

  end_time = 1000
  # num_steps = 2
  # dt = 0.1
  dtmin = 1e-4
[]

[Outputs]
  exodus = true
  csv = true
[]
