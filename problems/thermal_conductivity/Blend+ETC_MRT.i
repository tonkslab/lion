[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 38
  ny = 38
  nz = 0
  xmax = 150
  ymax = 150
  zmax = 0
  elem_type = QUAD4
  uniform_refine = 2
[]

[MeshModifiers]
  [./AEH_Node]
    type = AddExtraNodeset
    new_boundary = 100
    coord = '75 75'
  [../]
[]

[Variables]
  [./cUO2]
  [../]
  [./Tx_AEH]
    initial_condition = 800
    scaling = 1.0e4
  [../]
  [./Ty_AEH]
    initial_condition = 800
    scaling = 1.0e4
  [../]
  [./w]
  [../]
[]

[AuxVariables]
  [./local_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  [./IF_UO2]
    type = ImageFunction
    threshold = 100
    file = UO2-BeO-Continuous.png
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
  [./c_dot]
    type = CoupledTimeDerivative
    variable = w
    v = cUO2
  [../]
  [./c_res]
    type = SplitCHParsed
    variable = cUO2
    f_name = fbulk
    kappa_name = kappa_c
    w = w
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
[]

[AuxKernels]
  [./local_energy]
    type = TotalFreeEnergy
    variable = local_energy
    f_name = fbulk
    interfacial_vars = cUO2
    kappa_names = kappa_c
    execute_on = timestep_end
  [../]
[]

[BCs]
  [./Periodic]
    [./XY_AEH]
      auto_direction = 'x y'
      variable = 'Tx_AEH Ty_AEH'
    [../]
    [./all]
      auto_direction = 'x y'
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
    function = 'sk_UO2:= length_scale*k_UO2; sk_BeO:= length_scale*k_BeO; sk_int:= k_int*length_scale; if(cUO2<0.8,if(cUO2<0.2,sk_BeO,sk_int),sk_UO2)'
    f_name = thermal_conductivity
    constant_expressions = '1e-6 4 52 2'
    constant_names = 'length_scale k_UO2 k_BeO k_int'
    outputs = exodus
    args = cUO2
  [../]
  [./mat]
    type = GenericConstantMaterial
    prop_names = 'M kappa_c'
    prop_values = '1.0 0.25'
    block = 0
  [../]
  [./free_energy_UO2]
    type = DerivativeParsedMaterial
    block = 0
    function = cUO2^2*(1-cUO2)^2
    outputs = exodus
    f_name = fbulk
    args = cUO2
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
  type = Transient
  scheme = bdf2
  dt = 0.1
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 20
  nl_rel_tol = 1e-9
  end_time = 5
  [./Adaptivity]
    initial_adaptivity = 3 # Number of times mesh is adapted to initial condition
    refine_fraction = 0.7 # Fraction of high error that will be refined
    coarsen_fraction = 0.1 # Fraction of low error that will coarsened
    max_h_level = 3 # Max number of refinements used, starting from initial mesh (before uniform refinement)
    weight_names = 'cUO2 Tx_AEH Ty_AEH w'
    weight_values = '1 0 0 0'
  [../]
[]

[Preconditioning]
  [./cw_coupling]
    type = SMP
    full = true
  [../]
[]

[Outputs]
  execute_on = 'timestep_end initial'
  exodus = true
  csv = true
  file_base = ETC-AEH-Blend
[]

[ICs]
  [./IC_UO2]
    function = IF_UO2
    variable = cUO2
    type = FunctionIC
  [../]
[]
