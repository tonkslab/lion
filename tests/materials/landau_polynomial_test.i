[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 100
  ymax = 100
  elem_type = QUAD4
  nx = 25
  ny = 25
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./op0]
  [../]
[]

[Kernels]
  [./AC_interface]
    type = ACInterface
    variable = op0
  [../]
  [./AllenCahn]
    type = AllenCahn
    f_name = f_loc
    variable = op0
    args = c
  [../]
  [./dt_op0]
    type = TimeDerivative
    variable = op0
  [../]
  [./dt_w]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./CH_wres]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./CH_Parsed]
    type = SplitCHParsed
    variable = c
    f_name = f_loc
    w = w
    kappa_name = kappa_c
    args = op0
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'kappa_op kappa_c M L'
    prop_values = '200 1500 4.5 60'
  [../]
  [./free_energy]
    type = LandauPolynomialMaterial
    block = 0
    c = c
    f_name = f_loc
    args = op0
    outputs = exodus
  [../]
[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                 preonly       ilu          2'
  nl_max_its = 30
  l_max_its = 30
  dt = 0.01
  num_steps = 3
[]

[Outputs]
  exodus = true
  console = false
  file_base = landau_polynomial
[]

[ICs]
  [./concentration]
    type = BoundingBoxIC
    variable = c
    x1 = 10
    x2 = 60
    y1 = 20
    y2 = 80
    inside = 1.0
  [../]
  [./order_parameter]
    type = BoundingBoxIC
    variable = op0
    x1 = 40
    x2 = 90
    y1 = 20
    y2 = 80
    inside = 1.0
  [../]
[]
