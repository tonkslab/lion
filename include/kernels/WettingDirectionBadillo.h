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
#ifndef WETTINGDIRECTIONBADILLO_H
#define WETTINGDIRECTIONBADILLO_H

#include "Kernel.h"
#include "RankTwoTensor.h"

// Forward Declaration
class WettingDirectionBadillo;


template<>
InputParameters validParams<WettingDirectionBadillo>();

/**
 * Computes div(W sqrt(2) phi_l phi_v r_lv/norm(r_lv) ) residual term for the wetting model from Badillo2015
 */
class WettingDirectionBadillo : public Kernel
{
public:
  WettingDirectionBadillo(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const MaterialProperty<Real> & _int_width;

  const unsigned int _phi_w_var;

  const VariableValue & _phi_w;

  const VariableGradient & _grad_phi_w;

  const Real _tol;

};

#endif // WETTINGDIRECTIONBADILLO_H
