[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = -20
  xmax = 20
  nx = 100
  ymin = 0
  ymax = 10
  ny = 50
[]

[Variables]
  [dummy]
  []
[]

[Kernels]
  [dummy_u]
    type = TimeDerivative
    variable = dummy
  []
[]


[AuxVariables]
  [mogp_temperature]
  []
[]

[AuxKernels]
  [function_aux]
    type = FunctionAux
    variable = mogp_temperature
    function = mogp_data
  []
[]


[Functions]
  [mogp_data]
    type = PiecewiseMultilinear
    data_file = mogp_temp_profile.txt
  []
[]


[Executioner]
  type = Transient
  dt = 1
  end_time = 19
[]

[Outputs]
  execute_on = 'timestep_end'
  hide = dummy
  exodus = true
[]
