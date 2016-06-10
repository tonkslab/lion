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
    initial_condition = 0.0
  [../]
[]

[ICs]
  [./phi_l_IC]
    type = BoundingBoxIC
    variable = phi_l
    x1 = 0
    x2 = 1
    y1 = 0
    y2 = 1
    inside = 0
    outside = 1
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
    function = 0.0625
    f_name = inter_width
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  dt = 0.068
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm lu 1'
  num_steps = 10
  l_tol = 1e-4
  l_max_its = 15
  nl_max_its = 15
  nl_rel_tol = 1e-8
[]

[Outputs]
  exodus = true
  execute_on = 'INITIAL FINAL'
  print_perf_log = true
[]
