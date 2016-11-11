/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef COUPLEDCONVECTION_H
#define COUPLEDCONVECTION_H

#include "Kernel.h"

// Forward Declarations
class CoupledConvection;

template<>
InputParameters validParams<CoupledConvection>();

/**
 * This class computes coupled convection
 */
class CoupledConvection : public Kernel
{
public:
  CoupledConvection(const InputParameters & parameters);

  //virtual ~CoubpledConvection(){}

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  // Coupled variables
  const VariableValue & _u_vel;
  const VariableValue & _v_vel;
  const VariableValue & _w_vel;

  // Gradients
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;

  // Variable numberings
  unsigned _u_vel_var_number;
  unsigned _v_vel_var_number;
  unsigned _w_vel_var_number;

};


#endif // INSMOMENTUM_H
