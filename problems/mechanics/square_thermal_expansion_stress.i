# This example problem demonstrates coupling heat conduction with mechanics.
# A circular domain has as uniform heat source that increases with time
# and a fixed temperature on the outer boundary, resulting in a temperature gradient.
# This results in heterogeneous thermal expansion, where it is pinned in the center.
# Looking at the hoop stress demonstrates why fuel pellets have radial cracks
# that extend from the outer boundary to about halfway through the radius.
# The problem is run with length units of microns.

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmin = 0
  xmax = 1000
  ymin = 0
  ymax = 1000
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  # We solve for the temperature and the displacements
  [./T]
    initial_condition = 800
    scaling = 1e9
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[AuxVariables]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  active = 'TensorMechanics htcond Q_function'
  [./htcond] #Heat conduction equation
    type = HeatConduction
    variable = T
  [../]
  [./TensorMechanics] #Action that creates equations for disp_x and disp_y
    displacements = 'disp_x disp_y'
  [../]
  [./Q_function] #Heat generation term
    type = BodyForce
    variable = T
    value = 1
    function = 0.8e-9*t
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  [../]
[]

[BCs]
  [./bottom_T] #Temperature on outer edge is fixed at 800K
    type = PresetBC
    variable = T
    boundary = 'bottom'
    value = 800
  [../]
  [./bottom_x] #Displacements in the x-direction are fixed in the center
    type = PresetBC
    variable = disp_x
    boundary = 'left'
    value = 0
  [../]
  [./left_y] #Displacements in the y-direction are fixed in the center
    type = PresetBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  [../]
[]

[Materials]
  [./thcond] #Thermal conductivity is set to 5 W/mK
    type = GenericConstantMaterial
    block = 0
    prop_names = 'thermal_conductivity'
    prop_values = '9.5e-6'
  [../]
  [./iso_C] #Sets isotropic elastic constants
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 4.6e4
    poissons_ratio = 0.21
    block = 0
  [../]
  [./srain] #We use small deformation mechanics
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y'
    thermal_expansion_coeff = 4.6e-6
    temperature = T
    block = 0
  [../]
  [./stress] #We use linear elasticity
    type = ComputeLinearElasticStress
    block = 0
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  num_steps = 10
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 101'
  l_max_its = 200
  nl_max_its = 200
  nl_abs_tol = 1e-7
  l_tol = 1e-04
  dt = 1
[]

[Outputs]
  exodus = true
  print_perf_log = true
[]
