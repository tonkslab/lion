[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 2
  ymax = 1
  nx = 18
  ny = 9
  uniform_refine = 2
[]

[Variables]
  [./phi_l]
  [../]
[]

[AuxVariables]
  [./phi_w]
  [../]
[]

[ICs]
  [./phi_l_IC]
    type = SmoothCircleIC
    variable = phi_l
    x1 = 1.0
    y1 = 0.15
    radius = 0.6
    invalue = 1
    int_width = 0.15
    outvalue = 0
  [../]
  [./phi_w_IC]
    type = FunctionIC
    variable = phi_w
    function = 'if(y<0.15,(1+cos(y/0.15*3.141592))/2,0)'
  [../]
[]

[Kernels]
  [./phi_l_dot]
    type = MatTimeDerivative
    mat_prop = time_scaling
    variable = phi_l
  [../]
  [./phi_l_1]
    type = WettingInterfaceBadillo
    variable = phi_l
    int_width_name = inter_width
    phi_w = phi_w
  [../]
  [./phi_l_2]
    type = WettingDirectionBadillo
    variable = phi_l
    int_width_name = inter_width
    phi_w = phi_w
  [../]
[]

[Materials]
  [./p1]
    type = ParsedMaterial
    function = 1.0
    f_name = time_scaling
  [../]
  [./p2]
    type = ParsedMaterial
    function = 0.065
    f_name = inter_width
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  dt = 0.068
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm lu 1'
  num_steps = 11
  l_tol = 1e-4
  l_max_its = 100
  nl_max_its = 25
  nl_rel_tol = 1e-9
[]

[Outputs]
  exodus = true
  execute_on = 'INITIAL FINAL'
  print_perf_log = true
[]
