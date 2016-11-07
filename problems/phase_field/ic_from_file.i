# This file does sintering simulations using a text file to generate the initial
# conditions.

[GlobalParams]
  op_num = 15
  var_name_base = gr
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 16
  ny = 16
  xmin = 0
  xmax = 600
  ymin = 0
  ymax = 600
  elem_type = QUAD4
  uniform_refine = 2
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./free_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./RigidBodyMultiKernel]
    # Creates all of the necessary Allen Cahn kernels automatically
    c = c
    f_name = f_loc
    mob_name = L
    kappa_name = kappa_gr
    grain_force = grain_force
    grain_volumes = volumes
    grain_tracker_object = grain_center
  [../]
  # Cahn Hilliard kernels
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
    args = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11 gr12 gr13 gr14'
  [../]
  [./CH_RBM]
    type = MultiGrainRigidBodyMotion
    variable = w
    c = c
    grain_force = grain_force
    grain_volumes = volumes
    grain_tracker_object = grain_center
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
  [../]
  [./energy_density]
    type = TotalFreeEnergy
    variable = free_energy
    f_name = f_loc
    kappa_names = kappa_c
    interfacial_vars = c
  [../]
[]

[BCs]
  [./bcs]
    #zero flux BC
    type = NeumannBC
    value = 0
    variable = c
    boundary = '0 1 2 3'
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'kappa_gr kappa_c M L'
    prop_values = '250 4000 4.5 60'
  [../]
  [./concentration_energy]
    type = DerivativeParsedMaterial
    block = 0
    constant_names = 'A'
    constant_expressions = '450'
    args = c
    function = 'A*c^2*(1-c)^2'
    derivative_order = 2
    f_name = energy_1
  [../]
  [./grain_energy]
    type = LandauPolynomialMaterial
    block = 0
    c = c
    f_name = energy_2
    op_tracking_coeff = 1.5
    derivative_order = 2
  [../]
  [./free_energy]
    type = DerivativeSumMaterial
    block = 0
    args = 'c gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11 gr12 gr13 gr14'
    sum_materials = 'energy_1 energy_2'
    derivative_order = 2
    f_name = f_loc
  [../]
  [./advection_velocity]
    type = GrainAdvectionVelocity
    block = 0
    grain_force = grain_force
    grain_data = grain_center
    c = c
  [../]
  [./force_density_0]
    type = ExternalForceDensityMaterial
    block = 0
    c = c
    k = 10
    force_x = 0
    force_y = 0
  [../]
[]

[VectorPostprocessors]
  [./volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_center
    execute_on = 'initial timestep_begin'
    outputs = ''
  [../]
  [./forces]
    type = GrainForcesPostprocessor
    grain_force = grain_force
    outputs = ''
  [../]
[]

[UserObjects]
  [./grain_center]
    type = GrainTracker
    execute_on = 'initial timestep_begin'
    outputs = none
    compute_var_to_feature_map = true
  [../]
  [./grain_force]
    type = ComputeExternalGrainForceAndTorque
    grain_data = grain_center
    c = c
    force_density = force_density_ext
    execute_on = 'linear nonlinear'
    etas = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11 gr12 gr13 gr14'
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
                         ilu          2'
  l_tol = 1e-05
  nl_max_its = 30
  l_max_its = 30
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-09
  start_time = 0.0
  end_time = 5
  dt = 0.05
  [./Adaptivity]
    coarsen_fraction = 0.1
    refine_fraction = 0.9
    initial_adaptivity = 2
    max_h_level = 3
    weight_names = 'c gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11 gr12 gr13 gr14'
    weight_values = '0.5 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1'
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_perf_log = true
[]

[ICs]
  [./CirclesFromFileIC]
    c = c
    file_name = compact.txt
    int_width = 10
    header_length = 6
  [../]
[]
