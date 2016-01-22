[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  nz = 0
  xmax = 150
  ymax = 150
  zmax = 0
  elem_type = QUAD4
  uniform_refine = 2
[]

[Variables]
  [./T]
  [../]
[]

[AuxVariables]
  [./cUO2]
  [../]
  [./cBeO]
  [../]
[]

[Functions]
  [./IF_UO2]
    type = ImageFunction
    threshold = 145
    file = UO2-BeO-Continuous.png
  [../]
  [./IF_BeO]
    type = ImageFunction
    upper_value = 0
    lower_value = 1
    file = UO2-BeO-Continuous.png
    threshold = 145
  [../]
[]

[Kernels]
  [./HeatCon]
    type = HeatConduction
    variable = T
  [../]
[]

[BCs]
  [./L-T]
    type = PresetBC
    variable = T
    boundary = left
    value = 800
  [../]
  [./R-Flux]
    type = NeumannBC
    variable = T
    boundary = right
    value = 5e-6
  [../]
[]

[Materials]
  [./ThermCon]
    type = ParsedMaterial
    block = 0
    function = 'sk_UO2:= length_scale*k_UO2; sk_BeO:= length_scale*k_BeO; sk_int:= k_int*length_scale; if(cBeO>0.1,if(cBeO>0.9,sk_BeO,sk_int),sk_UO2)'
    f_name = thermal_conductivity
    constant_expressions = '1e-6 4 52 4'
    constant_names = 'length_scale k_UO2 k_BeO k_int'
    outputs = exodus
    args = cBeO
  [../]
[]

[Postprocessors]
  [./k_eff]
    type = ThermalCond
    variable = T
    flux = 5e-6
    T_hot = 800
    dx = 150
    length_scale = 1e-6
    boundary = right
  [../]
  [./Right_T]
    type = SideAverageValue
    variable = T
    boundary = right
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 15
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'
  l_tol = 1e-04
[]

[Outputs]
  execute_on = timestep_end
  exodus = true
  csv = true
[]

[ICs]
  [./IC_UO2]
    function = IF_UO2
    variable = cUO2
    type = FunctionIC
  [../]
  [./IC_BeO]
    function = IF_BeO
    variable = cBeO
    type = FunctionIC
  [../]
[]
