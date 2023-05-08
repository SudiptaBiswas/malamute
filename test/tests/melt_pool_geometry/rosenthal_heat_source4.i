[Mesh]
  type = GeneratedMesh
  dim = 2
  # xmin = -0.002
  xmax = 4.0
  nx = 200

  ymin = -1.0
  ymax = 1.0
  ny = 100

  # zmin = 0.0
  # zmax = 1.0
  # nz = 1
[]

[Variables]
  [temp]
    initial_condition = 393
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
  # [./heat_source]
  #   type = ADMatHeatSource
  #   material_property = meltpool_heat
  #   variable = temp
  # [../]
[]

# [BCs]
#   [./temp_bottom_fix]
#     type = ADDirichletBC
#     variable = temp
#     boundary = 1
#     value = 300
#   [../]
# []
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

[Materials]
  [heat]
    type = ADHeatConductionMaterial
    specific_heat = 603
    thermal_conductivity = 20e-2
  []
  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '8000e-9'
  []
  [meltpool_heat]
    type = ADRosenthalTemperatureSource
    power = 500
    velocity = 2.0
    absorptivity = 1.0
    melting_temperature = 1660
    ambient_temperature = 300
    # thermal_conductivity = thermal_conductivity
    outputs = exodus
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
  solve_type = PJFNK

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'preonly lu       superlu_dist'

  l_max_its = 100

  end_time = 20
  dt = 0.1
  dtmin = 1e-4
[]

[Outputs]
  exodus = true
[]
