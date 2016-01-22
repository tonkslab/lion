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
[]

[MeshModifiers]
  [./AEH_Node]
    type = AddExtraNodeset
    new_boundary = 100
    coord = '75 75'
  [../]
[]

[Variables]
  [./Tx_AEH]
    initial_condition = 800
    scaling = 1.0e4
  [../]
  [./Ty_AEH]
    initial_condition = 800
    scaling = 1.0e4
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
  [./Heat_X]
    type = HeatConduction
    variable = Tx_AEH
  [../]
  [./Heat_X_rhs]
    type = HomogenizationHeatConduction
    variable = Tx_AEH
    component = 0
  [../]
  [./Heat_Y]
    type = HeatConduction
    variable = Ty_AEH
  [../]
  [./Heat_Y_rhs]
    type = HomogenizationHeatConduction
    variable = Ty_AEH
    component = 1
  [../]
[]

[BCs]
  [./Periodic]
    [./XY_AEH]
      auto_direction = 'x y'
      variable = 'Tx_AEH Ty_AEH'
    [../]
  [../]
  [./fix_x]
    type = DirichletBC
    variable = Tx_AEH
    value = 800
    boundary = 100
  [../]
  [./fix_y]
    type = DirichletBC
    variable = Ty_AEH
    value = 800
    boundary = 100
  [../]
[]

[Materials]
  [./ThermCon]
    type = ParsedMaterial
    block = 0
    function = 'sk_UO2:= length_scale*k_UO2; sk_BeO:= length_scale*k_BeO; sk_int:= k_int*length_scale; if(cBeO>0.1,if(cBeO>0.9,sk_BeO,sk_int),sk_UO2)'
    f_name = thermal_conductivity
    constant_expressions = '1e-6 4 52 0.1'
    constant_names = 'length_scale k_UO2 k_BeO k_int'
    outputs = exodus
    args = cBeO
  [../]
[]

[Postprocessors]
  [./k_x_AEH]
    type = HomogenizedThermalConductivity
    variable = Tx_AEH
    temp_x = Tx_AEH
    temp_y = Ty_AEH
    component = 0
    scale_factor = 1e6
  [../]
  [./k_y_AEH]
    type = HomogenizedThermalConductivity
    variable = Ty_AEH
    temp_x = Tx_AEH
    temp_y = Ty_AEH
    component = 1
    scale_factor = 1e6
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

[Preconditioning]
  [./SMP]
    type = SMP
    off_diag_row = 'Tx_AEH Ty_AEH'
    off_diag_column = 'Ty_AEH Tx_AEH'
  [../]
[]

[Outputs]
  execute_on = timestep_end
  exodus = true
  csv = true
  file_base = Eff_Therm_Con_AEH
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

