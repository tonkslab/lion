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
#ifndef WETTINGINTERFACEBADILLO_H
#define WETTINGINTERFACEBADILLO_H

#include "Kernel.h"

// Forward Declaration
class WettingInterfaceBadillo;


template<>
InputParameters validParams<WettingInterfaceBadillo>();

/**
 * Computes div(W^2 r_lv) residual term for the wetting model from Badillo2015
 */
class WettingInterfaceBadillo : public Kernel
{
public:
  WettingInterfaceBadillo(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const MaterialProperty<Real> & _int_width;

  const unsigned int _phi_w_var;

  const VariableValue & _phi_w;

  const VariableGradient & _grad_phi_w;

};

#endif // WETTINGINTERFACEBADILLO_H
