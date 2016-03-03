# Input file to test the behavior of sintering model with variable
# number of grains.
# Ian Greenquist -- 2/25/16
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 8
  ny = 8
  xmin = 0
  xmax = 500
  ymin = 0
  ymax = 500
  elem_type = QUAD4
  uniform_refine = 5
[]

[GlobalParams]
  op_num = 4                     #The number of grains for the simulation
  var_name_base = gr
[]

[Variables]
  [./rho]
    scaling = 100
  [../]
  [./mew]
  [../]
  [./PolycrystalVariables]
    var_name_base = gr
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./MultiAuxVariables]
    order = CONSTANT
    family = MONOMIAL
    var_name_base = 'dfx dfy force'
    op_num = '4 4 1'             #First two should be equal to standard op_num
  [../]
  [./free_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  [./load_x]
    type = ParsedFunction
    value = 0.005*cos(x*pi/500)
  [../]
  [./load_y]
    type = ParsedFunction
    value = 0.006*cos(y*pi/500)
  [../]
[]

[ICs]
  [./rho]
    type = SpecifiedSmoothCircleIC
    variable = rho
    x_positions = '125 375 125 375'
    y_positions = '125 125 375 375'
    z_positions = '0 0 0 0'
    radii = '75 75 100 75'
    invalue = 1.0
    outvalue = 0.0
  [../]
  [./gr0]
    type = SmoothCircleIC
    variable = gr0
    x1 = 125
    y1 = 125
    radius = 75
    invalue = 1.0
    outvalue = 0.0
  [../]
  [./gr1]
    type = SpecifiedSmoothCircleIC
    variable = gr1
    x_positions = '375 250'
    y_positions = '125 250'
    z_positions = '0 0'
    radii = '75 45'
    invalue = 1.0
    outvalue = 0.0
  [../]
  [./gr2]
    type = SmoothCircleIC
    variable = gr2
    x1 = 125
    y1 = 375
    radius = 75
    invalue = 1.0
    outvalue = 0.0
  [../]
  [./gr3]
    type = SmoothCircleIC
    variable = gr3
    x1 = 375
    y1 = 375
    radius = 75
    invalue = 0.6
    outvalue = 0.0
  [../]
[]

[BCs]
  [./bcs]
    #zero flux BC
    type = NeumannBC
    value = 0
    variable = rho
    boundary = '0 1 2 3'
  [../]
[]

[Kernels]
  #Allen Cahn kernel actions
  [./AllenCahnKernel]
    f_name = f_loc
    mob_name = L
  [../]
  [./ACInterfaceKernel]
    kappa_name = kappa_gr
  [../]
  [./TimeDerivativeKernel]
  [../]
  [./SGRigidBodyKernel]
    c = rho
  [../]
  #Cahn Hilliard kernels
  [./dt_mew]
    type = CoupledTimeDerivative
    variable = mew
    v = rho
  [../]
  [./CH_wres]
    type = SplitCHWRes
    variable = mew
    mob_name = M
  [../]
  [./CH_parsed]
    type = SplitCHParsed
    variable = rho
    f_name = f_loc
    w = mew
    kappa_name = kappa_c
    args = 'gr0 gr1 gr2 gr3'     #Must be changed as op_num changes
  [../]
  [./CH_parsed2]
    type = MultiGrainRigidBodyMotion
    variable = mew
    c = rho
    v = 'gr0 gr1 gr2 gr3'        #Must be changed as op_num changes
  [../]
[]

[AuxKernels]
  [./force_x]
    type = FunctionAux
    variable = force0
    function = load_x
  [../]
  [./force_y]
    type = FunctionAux
    variable = force0
    function = load_y
  [../]
  [./MatVecRealGradAuxKernel]
    var_name_base = 'dfx dfy'
    op_num = '4 4'               #Should both be equal to standard op_num
    property = force_density_ext
  [../]
  [./energy_density]
    type = TotalFreeEnergy
    variable = free_energy
    f_name = f_loc
    kappa_names = kappa_c
    interfacial_vars = rho
  [../]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 gr2 gr3'        #Must be changed as op_num changes
  [../]
[]

[UserObjects]
  [./grain_center]
    type = ComputeGrainCenterUserObject
    etas = 'gr0 gr1 gr2 gr3'     #Must be changed as op_num changes
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
    prop_values = '50 3000 4.5 60'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    block = 0
    f_name = f_loc
    constant_names = 'A B'
    constant_expressions = '450 1.5'
    args = 'rho gr0 gr1 gr2 gr3' #Must be changed as op_num changes
    function = 'A*rho^2*(1-rho)^2+B*(rho^2+6*(1-rho)*
                (gr0^2+gr1^2+gr2^2+gr3^2)
                -4*(2-rho)*(gr0^3+gr1^3+gr2^3+gr3^3)
                +3*(gr0^2+gr1^2+gr2^2+gr3^2)^2)'
                                 #Must be changed as op_num changes
  [../]
  [./advection_velocity]
    type = GrainAdvectionVelocity
    block = 0
    grain_force = grain_force
    grain_data = grain_center
    etas = 'gr0 gr1 gr2 gr3'     #Must be changed as op_num changes
    c = rho
  [../]
  [./force_density]
    type = ExternalForceDensityMaterial
    block = 0
    c = rho
    etas = 'gr0 gr1 gr2 gr3'     #Must be changed as op_num changes
    k = 10.0
    force_x = load_x
    force_y = load_y
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

[Postprocessors]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    convex_hull_buffer = 2.0
    use_single_map = false
    enable_var_coloring = true
    condense_map_info = true
    connecting_threshold = 0.08
    execute_on = 'initial timestep_end'
  [../]
  [./total_energy]
    type = ElementIntegralVariablePostprocessor
    variable = free_energy
    execute_on = 'initial timestep_end'
  [../]
  [./dt]
    type = TimestepSize
  [../]
  [./sim_time]
    type = RunTime
    time_type = active
  [../]
  [./num_nodes]
    type = NumNodes
    execute_on = 'initial timestep_end'
  [../]
  [./evaluations]
    type = NumResidualEvaluations
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
  l_tol = 1e-05
  nl_max_its = 30
  l_max_its = 15
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-09
  start_time = 0.0
  end_time = 0.5
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.005
    optimal_iterations = 9
    growth_factor = 1.25
    cutback_factor = 0.5
  [../]
  [./Adaptivity]
    coarsen_fraction = 0.1
    refine_fraction = 0.9
    max_h_level = 5
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  file_base = z_output
  print_perf_log = true
  [./display]
    type = Console
    max_rows = 10
  [../]
[]
