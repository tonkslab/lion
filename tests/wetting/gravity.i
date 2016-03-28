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
  uniform_refine = 1
[]

[Variables]
  # We are solving the Cahn-Hilliard equation with the split form
  # The split form requires two variables
  [./phi] #The phase variable, 1 = liquid, -1 = vapor
  [../]
  [./chem_pot] #The chemical potential, mu
  [../]
[]

[AuxVariables]
  # These variables define the solid and the wetting behavior
  [./a] #Solid variable, 1 = liquid/vaport, -1 = solid
  [../]
  [./A] #Wetting parameter, > 0 is hydrophilic, < 0 is hydrophobic
  [../]
[]

[ICs]
  [./alphaIC] #This initial condition will be constant through the simulation
    # 1=fluid,gas; -1=solid
    x1 = 0.1
    x2 = 1.9
    y1 = 0
    y2 = 2
    inside = 1
    outside = -1
    variable = a
    type = BoundingBoxIC
  [../]
  [./phi_IC]
    x1 = 0
    x2 = 2
    y1 = 0.7
    y2 = 1.3
    inside = 1.0
    outside = -1.0
    variable = phi
    type = BoundingBoxIC
  [../]
  [./A_IC] #This initial condition will be constant through the simulation
    x1 = 0
    x2 = 1
    y1 = 0
    y2 = 2
    variable = A
    inside = 0.2
    outside = 0.4
    type = BoundingBoxIC
  [../]
[]

[Kernels]
  # Kernels define different pieces of our equation we are solving
  # dot(phi) = laplacian(-gamma*laplacian(phi) + dV/dphi)
  # but we solve it with the split form, so we have two equations
  # variable = mu: dot(phi) = laplacian(mu)
  # variable = phi: mu = -gamma*laplacian(phi) + dV/dphi

  [./phi_dot] #dot(phi)
    type = CoupledTimeDerivative
    variable = chem_pot
    v = phi
  [../]
  [./c_res] #mu = -gamma*laplacian(phi) + dV/dphi
    type = SplitCHParsed
    variable = phi
    f_name = V
    kappa_name = gamma
    w = chem_pot
  [../]
  [./w_res] #laplacian(mu)
    type = SplitCHWRes
    variable = chem_pot
    mob_name = M
    args = phi
  [../]
  [./gravity]
    type = MatConvection
    variable = chem_pot
    driving_vector = '0 -0.02 0'
    mat_prop = M
    conserved_var = phi
    args = phi
  [../]
[]

[Materials]
  [./V] #Calculates dV/dphi
    type = DerivativeParsedMaterial
    block = 0
    constant_expressions = '2'
    function = '0.5*(1 + a)*0.25*(1 - phi^2)^2 + 0.5*(1 - a)*(K/2)*(phi - A)^2'
    outputs = exodus
    args = 'phi A a'
    constant_names = 'K'
    f_name = V
    derivative_order = 2
  [../]
  [./gamma]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'gamma'
    prop_values = '0.005'
  [../]
  [./M]
    type = DerivativeParsedMaterial
    block = 0
    args = 'phi'
    constant_names = 'M0 lb ub'
    constant_expressions = '1 0.1 1'
    outputs = exodus
    f_name = M
    derivative_order = 2
    function = 'if(phi<-1, lb*M0, if(phi>1, ub*M0, M0*((lb + ub) + phi*(ub - lb))/2))'
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
  l_tol = 1e-4
  nl_max_its = 20
  nl_rel_tol = 1e-8
  num_steps = 4
  nl_abs_tol = 1e-10
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.75
    dt = 0.002
    growth_factor = 1.2
    optimal_iterations = 8
  [../]
[]

[Outputs]
  execute_on = 'initial timestep_end'
  exodus = true
  print_perf_log = true
[]
