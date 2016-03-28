/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/
#ifndef MATCONVECTION_H
#define MATCONVECTION_H

#include "Kernel.h"
#include "JvarMapInterface.h"
#include "DerivativeMaterialInterface.h"

// Forward Declaration
class MatConvection;


template<>
InputParameters validParams<MatConvection>();

/**
 * Compute convection term for phase field simulations
 */
class MatConvection : public DerivativeMaterialInterface<JvarMapInterface<Kernel> >
{
public:
  MatConvection(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const unsigned int _c_var;

  const VariableGradient & _grad_c;

  const MaterialProperty<Real> & _conv_prop;

  /// Vector defining driving force for the convection
  const RealVectorValue _driving_vector;

  /// number of coupled variables
  const unsigned int _nvar;

  /// @{ Mobility derivative w.r.t. other coupled variables
  std::vector<const MaterialProperty<Real> *> _dconv_propdarg;

};

#endif // MATCONVECTION_H
