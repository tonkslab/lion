#
# This input file run Coupled Convection Input File
#
[GlobalParams]
  gravity = '0 0 0'
  rho = 1
  mu = 1
  cp = 1
  k = .01
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 30
  ny = 15
  nz = 0
  xmax = 10
  ymax = 5
  zmax = 0
  elem_type = QUAD9
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
  [./vel_x]
    order = SECOND
    family = LAGRANGE
  [../]
  [./vel_y]
    order = SECOND
    family = LAGRANGE
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  # These variables define the solid and the wetting behavior
  [./a]
    # Interface variable, 0 = liquid/vapor, 1 = solid/liquid interface
  [../]
  [./b]
    # Solid variable, 0 = liquid/vapor, 1 = solid
  [../]
  [./A]
    # Wetting parameter, > 0.5 is hydrophilic, < 0.5 is hydrophobic
    initial_condition = 0.75
  [../]
[]

[ICs]
  #active = 'a_IC b_IC phi_IC d_IC'
  [./a_IC]
    type = BoundingBoxIC
    x1 = 0
    x2 = 10
    y1 = 0.2
    y2 = 0.4
    inside = 1
    outside = 0
    variable = a
  [../]
  [./b_IC]
    type = BoundingBoxIC
    x1 = 0
    x2 = 10
    y1 = 0
    y2 = 0.2
    inside = 1
    outside = 0
    variable = b
  [../]
  [./phi_IC]
    variable = 'phi'
    type = SmoothCircleIC
    invalue = 1
    outvalue = 0
    radius = 1.5
    x1 = 5
    y1 = 1.5
    int_width = 0.3
  [../]
  [./d_IC]
    variable = 'd'
    type = SmoothCircleIC
    invalue = 1
    outvalue = 0
    radius = 1.5
    x1 = 5
    y1 = 1.5
    int_width = 0.3
  [../]
[]

[Kernels]
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
    args = 'phi'
  [../]
  [./w_res]
    # laplacian(mu)
    type = SplitCHWRes
    variable = chem_pot
    mob_name = M
    args = 'd phi'
  [../]
  [./phi_dot]
    type = TimeDerivative
    variable = phi
  [../]
  [./phi_bulk]
    type = AllenCahn
    f_name = V
    variable = phi
    mob_name = L
    args = 'd'
  [../]
  [./phi_interface]
    type = ACInterface
    variable = phi
    kappa_name = gamma
    mob_name = L
    args = 'd'
  [../]
  [./gravity]
    type = MatConvection
    variable = phi
    driving_vector = '0 -0.0015 0'
    mat_prop = M
    args = 'phi'
  [../]
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
  [../]

  # x-momentum, time
  [./x_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
  [../]

  # x-momentum, space
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
  [../]

  # y-momentum, time
  [./y_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
  [../]

  # y-momentum, space
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
  [../]
  [./CoupledConvection]
    type = CoupledConvection
    variable = phi
    u = vel_x
    v = vel_y
  [../]
[]

[Materials]
  [./V_liquid]
    type = DerivativeParsedMaterial
    block = 0
    function = '(1 - d)^2 * (1 - a) * (1 - b) + a * (d - A)^2 + 2 * b * d^2'
    args = 'd A a b'
    f_name = V_liq
    derivative_order = 3
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
    type = DerivativeParsedMaterial
    block = 0
    args = 'd phi A a b'
    constant_names = W
    constant_expressions = 1
    material_property_names = 'V_gas(d) V_liq(d) g(phi) h(phi)'
    function = '(1 - h)*V_gas + h*V_liq + W*g'
    derivative_order = 2
    f_name = V
  [../]
  [./phi_switching]
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
    derivative_order = 2
  [../]
  [./gamma]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'gamma'
    prop_values = 0.0032
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
  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -sub_pc_factor_levels'
  petsc_options_value = 'asm      2               ilu          4'
  line_search = 'none'
  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 15
  nl_rel_tol = 1e-10
  num_steps = 4
  dt = 0.0001
[]

[Outputs]
  execute_on = 'initial timestep_end'
  exodus = true
  print_perf_log = true
[]
