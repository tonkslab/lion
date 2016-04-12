#
# This input file an initial test of the phase field wetting model
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 30
  ny = 15
  nz = 0
  xmax = 10
  ymax = 5
  zmax = 0
  elem_type = QUAD4
  uniform_refine = 3
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
    # Interface variable, 0 = liquid/vapor, 1 = solid/liquid interface
  [../]
  [./b]
    # Solid variable, 0 = liquid/vapor, 1 = solid
  [../]
  [./A]
    # Wetting parameter, > 0.5 is hydrophilic, < 0.5 is hydrophobic
    initial_condition = 0.3
  [../]
[]

[ICs]
  active = 'a_IC d_IC2 phi_IC2 density_IC'
  [./a_IC]
    # This initial condition will be constant through the simulation
    # 0=fluid,gas; 1=solid
    x1 = 0
    x2 = 10
    y1 = 0.0
    y2 = 0.2
    inside = 1
    outside = 0
    variable = a
    type = BoundingBoxIC
  [../]
  [./b_IC]
    type = BoundingBoxIC
    x1 = 0
    x2 = 10
    y1 = 0
    y2 = 0.1
    inside = 1
    outside = 0
    variable = b
  [../]
  [./phi_IC]
    variable = 'phi'
    type = SmoothCircleIC
    invalue = 1
    outvalue = 0
    radius = 1.8
    x1 = 5
    y1 = 2.3
    int_width = 0.15
  [../]
  [./d_IC]
    variable = 'd'
    type = SmoothCircleIC
    invalue = 1
    outvalue = 0
    radius = 1.8
    x1 = 5
    y1 = 2.3
    int_width = 0.15
  [../]
  [./phi_IC2]
    variable = 'phi'
    type = SmoothCircleIC
    invalue = 1
    outvalue = 0
    radius = 3.2
    x1 = 5
    y1 = -.5
    int_width = 0.2
  [../]
  [./d_IC2]
    variable = 'd'
    type = SmoothCircleIC
    invalue = 1
    outvalue = 0
    radius = 3.2
    x1 = 5
    y1 = -.5
    int_width = 0.2
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
    args = 'd phi'
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
    args = 'd phi'
  [../]
  [./phi_interface]
    type = ACInterface
    variable = phi
    kappa_name = gamma
    mob_name = L
    args = 'd phi'
  [../]
  [./gravity]
    type = MatConvection
    variable = phi
    driving_vector = '0 -0.0015 0'
    mat_prop = M
    args = 'd'
  [../]
[]

[Materials]
  active = 'V V_gas V_liquid phi_barrier phi_switching L gamma M_const'
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
    derivative_order = 3
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
    derivative_order = 3
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
  [./M]
    type = DerivativeParsedMaterial
    block = 0
    args = 'a d'
    constant_names = 'M0 ctoff'
    constant_expressions = '1 0'
    outputs = exodus
    f_name = M
    derivative_order = 2
    function = 'lb:=ctoff - ctoff^2; if(d<0+ctoff, lb*M0, if(d>1-ctoff, lb*M0, M0*4*(d - d^2)))'
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

[Postprocessors]
  [./dt]
    type = TimestepSize
  [../]
  [./total_d]
    type = ElementIntegralVariablePostprocessor
    variable = d
    execute_on = 'initial TIMESTEP_END'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 15
  nl_rel_tol = 1e-8
  end_time = 2000.0
  nl_abs_tol = 1e-9
  dtmax = 10
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.75
    dt = 2.0e-4
    growth_factor = 1.2
    iteration_window = 2
    optimal_iterations = 8
  [../]
  [./Adaptivity]
    refine_fraction = 0.9
    coarsen_fraction = 0.05
    max_h_level = 3
    weight_names = 'd phi chem_pot'
    weight_values = '1 1 0.1'
    initial_adaptivity = 0
  [../]
[]

[Outputs]
  execute_on = 'initial timestep_end'
  exodus = true
  print_perf_log = true
  interval = 5
  file_base = angle
[]
