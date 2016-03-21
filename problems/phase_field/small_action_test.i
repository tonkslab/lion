[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 6
  ny = 4
  xmin = 0
  xmax = 900
  ymin = 0
  ymax = 600
  elem_type = QUAD4
  uniform_refine = 3
[]

[Variables]
  [./rho]
  [../]
  [./mu]
  [../]
  [./PolycrystalVariables]
    op_num = 2
    var_name_base = gr0
    family = LAGRANGE
    order = FIRST
  [../]
[]

[AuxVariables]
  [./force]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./bnds]
  [../]
  [./MultiAuxVariables]
    order = CONSTANT
    family = MONOMIAL
    var_name_base = 'dfx dfy'
    op_num = '2 2'
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = 0.001
  [../]
[]

[ICs]
  [./grain_rho]
    type = SpecifiedSmoothCircleIC
    variable = rho
    x_positions = '150 450'
    y_positions = '150 450'
    z_positions = '0 0'
    radii = '125 150'
    invalue = 1.0
    outvalue = 0.0
  [../]
  [./grain00]
    type = SmoothCircleIC
    variable = gr00
    x1 = 150
    y1 = 150
    radius = 150
    invalue = 1.0
    outvalue = 0.0
  [../]
  [./grain01]
    type = SmoothCircleIC
    variable = gr01
    x1 = 450
    y1 = 450
    radius = 150
    invalue = 0.7
    outvalue = 0.0
  [../]
[]

[BCs]
  [./bcs]
    type = DirichletBC
    value = 0
    variable = rho
    boundary = '0 1 2 3'
  [../]
[]

[Kernels]
  [./AllenCahnKernel]
    op_num = 2
    var_name_base = gr0
    f_name = f_loc
    mob_name = L
  [../]
  [./ACInterfaceKernel]
    op_num = 2
    var_name_base = gr0
    kappa_name = kappa_gr
  [../]
  [./TimeDerivativeKernel]
    op_num = 2
    var_name_base = gr0
  [../]
  [./SGRigidBodyKernel]
    op_num = 2
    var_name_base = gr0
    c = rho
  [../]

  [./Dt_mu]
    type = CoupledTimeDerivative
    variable = mu
    v = rho
  [../]
  [./CH_WRes]
    type = SplitCHWRes
    variable = mu
    mob_name = M
  [../]
  [./CH_Parsed]
    type = SplitCHParsed
    variable = rho
    f_name = f_loc
    w = mu
    kappa_name = kappa_c
    args = 'gr00 gr01'
  [../]

  [./vadv_rho]
    type = MultiGrainRigidBodyMotion
    variable = mu
    c = rho
    v = 'gr00 gr01'
  [../]
[]

[AuxKernels]
  [./force]
    type = FunctionAux
    variable = force
    function = load
  [../]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    var_name_base = gr0
    op_num = 2
    v = 'gr00 gr01'
  [../]
  [./MatVecRealGradAuxKernel]
    var_name_base = 'dfx dfy'
    op_num = '2 2'
    property = force_density_ext
  [../]
[]

[UserObjects]
  [./grain_center]
    type = ComputeGrainCenterUserObject
    etas = 'gr00 gr01'
    execute_on = 'initial timestep_end'
  [../]
  [./grain_force]
    type = ComputeGrainForceAndTorque
    grain_data = grain_center
    c = rho
    force_density = force_density_ext
    execute_on = 'initial linear'
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'kappa_gr kappa_c M L'
    prop_values = '0.8 6000 4.5 12.0'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    block = 0
    f_name = f_loc
    constant_names = 'A B'
    constant_expressions = '450 1.0'
    args = 'rho gr00 gr01'
    function = 'A*rho^2*(1-rho)^2+B*(rho^2+6*(1-rho)*
                (gr00^2+gr01^2)-4*(2-rho)*(gr00^3+gr01^3)+3*(gr00^2+gr01^2)^2)'
  [../]
  [./advection_velocity]
    type = GrainAdvectionVelocity
    block = 0
    grain_force = grain_force
    grain_data = grain_center
    etas = 'gr00 gr01'
    c = rho
  [../]
  [./force_density_ext]
    type = ExternalForceDensityMaterial
    block = 0
    c = rho
    etas = 'gr00 gr01'
    k = 10.0
    force_x = load
    force_y = 0
  [../]
[]

[VectorPostprocessors]
  [./centers]
    type = GrainCentersPostprocessor
    grain_data = grain_center
  [../]
  [./forces]
    type = GrainForcesPostprocessor
    grain_force = grain_force
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
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type
                         -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly
                         lu          2'
  l_max_its = 30
  l_tol = 1e-05
  nl_max_its = 50
  nl_abs_tol = 1e-09
  nl_rel_tol = 1e-07
  start_time = 0.0
  dt = 0.1
  num_steps = 20
[]

[Outputs]
  exodus = true
  csv = false
[]
