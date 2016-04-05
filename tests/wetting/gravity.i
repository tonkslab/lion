#
# This input file an initial test of the phase field wetting model
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  nz = 0
  xmax = 2
  ymax = 2
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./phi]
    # The phase order parameter, 1 = liquid, 0 = vapor
  [../]
  [./d]
    # The normalized density (1 - c)
  [../]
  [./chem_pot]
    # The chemical potential, mu
  [../]
[]

[AuxVariables]
  # These variables define the solid and the wetting behavior
  [./a]
    # Interface variable, 0 = liquid/vaport, 1 = solid/liquid interface
  [../]
  [./b]
    # Solid variable, 0 = liquid/vaport, -1 = solid
  [../]
  [./A]
    # Wetting parameter, > 0 is hydrophilic, < 0 is hydrophobic
    #initial_condition = 0.75
  [../]
[]

[ICs]
  [./a_IC] #This initial condition will be constant through the simulation
    # 1=fluid,gas; -1=solid
    x1 = 0.1
    x2 = 1.9
    y1 = 0
    y2 = 2
    inside = 0
    outside = 1
    variable = a
    type = BoundingBoxIC
  [../]
  [./d_IC]
    x1 = 0
    x2 = 2
    y1 = 0.7
    y2 = 1.3
    inside = 1.0
    outside = 0.0
    variable = d
    type = BoundingBoxIC
  [../]
  [./phi_IC]
    x1 = 0.0
    x2 = 2
    y1 = 0.7
    y2 = 1.3
    inside = 1.0
    outside = 0.0
    variable = phi
    type = BoundingBoxIC
  [../]
  [./A_IC]
    type = BoundingBoxIC
    x1 = 0
    x2 = 1
    y1 = 0
    y2 = 2
    inside = 0.1
    outside = 0.9
    variable = A
  [../]
[]

[Kernels]
  active = 'd_dot d_res w_res phi_dot phi_bulk phi_interface gravity'
  [./d_dot]
    # dot(phi)
    type = CoupledTimeDerivative
    variable = chem_pot
    v = d
  [../]
  [./d_res]
    # mu = -gamma*laplacian(phi) + dV/dphi
    type = SplitCHParsed
    variable = d
    f_name = V
    kappa_name = gamma
    w = chem_pot
    args = 'd phi'
  [../]
  [./w_res]
    # laplacian(mu)
    type = SplitCHWRes
    variable = chem_pot
    mob_name = M
  [../]
  [./phi_dot]
    type = TimeDerivative
    variable = phi
  [../]
  [./phi_bulk]
    type = AllenCahn
    f_name = V
    variable = phi
    args = d
  [../]
  [./phi_interface]
    type = ACInterface
    variable = phi
    kappa_name = gamma
    mob_name = L
  [../]
  [./gravity]
    type = MatConvection
    variable = phi
    driving_vector = '0 -0.1 0'
    mat_prop = M
    conserved_var = phi
    args = phi
  [../]
[]

[Materials]
  active = 'V_liquid V_gas V phi_switching2 phi_barrier gamma L M_const'
[./V_liquid]
  type = DerivativeParsedMaterial
  block = 0
  function = '(1 - d)^2 * (1 - a) * (1 - b) + a * (d - A)^2 + 2 * b * d^2'
  args = 'd A a b'
  f_name = V_liq
  derivative_order = 2
[../]
[./V_gas]
  type = DerivativeParsedMaterial
  block = 0
  constant_names = deq
  constant_expressions = 0.0
  function = '(deq - d)^2 * (1 - a) * (1 - b) + a * (d - A)^2 + 2 * b * d^2'
  args = 'd A a b'
  f_name = V_gas
  derivative_order = 2
[../]
[./V]
  type = DerivativeTwoPhaseMaterial
  block = 0
  eta = phi
  derivative_order = 2
  f_name = V
  fa_name = V_gas
  fb_name = V_liq
  args = 'd A a b'
  W = 1.0
[../]
[./V2]
  type = DerivativeParsedMaterial
  block = 0
  derivative_order = 2
  material_property_names = 'V_liq(d) h(phi) V_gas(d) g(phi)'
  args = 'd phi'
  function = '(1 - h) * V_gas + h * V_liq + 1.0 * g'
[../]
[./phi_switching]
  type = SwitchingFunctionMaterial
  block = 0
  eta = phi
  h_order = SIMPLE
  derivative_order = 4
[../]
[./phi_switching2]
  type = DerivativeParsedMaterial
  block = 0
  args = phi
  function = '3*phi^2 - 2*phi^3'
  derivative_order = 3
  f_name = h
[../]
[./phi_barrier]
  type = DerivativeParsedMaterial
  block = 0
  args = 'phi a b A'
  function = 'phi^2*(1-phi)^2 * (1 - a) * (1 - b) + a * (phi - A)^2 + 2 * b * phi^2'
  f_name = g
  derivative_order = 3
[../]
[./gamma]
  type = GenericConstantMaterial
  block = 0
  prop_names = 'gamma'
  prop_values = 0.02
[../]
[./L]
  type = GenericConstantMaterial
  prop_names = 'L'
  prop_values = '2'
[../]
[./M_const]
  type = GenericConstantMaterial
  prop_names = 'M'
  prop_values = '1'
[../]
[]

[BCs]
[]

[Preconditioning]
  [./off_diag_coupling]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   lu      1'
  l_max_its = 30
  l_tol = 1e-8
  nl_max_its = 20
  nl_rel_tol = 1e-10
  num_steps = 4
  dt = 0.01
[]

[Outputs]
  execute_on = 'initial final'
  exodus = true
  print_perf_log = true
[]
