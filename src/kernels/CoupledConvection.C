/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "CoupledConvection.h"

template<>
InputParameters validParams<CoupledConvection>()
{
  InputParameters params = validParams<Kernel>();

  // Coupled variables
  params.addRequiredCoupledVar("u", "x-velocity");
  params.addCoupledVar("v", 0, "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("w", 0, "z-velocity"); // only required in 3D

  return params;
}

CoupledConvection::CoupledConvection(const InputParameters & parameters) :
  Kernel(parameters),

  // Coupled variables
  _u_vel(coupledValue("u")),
  _v_vel(coupledValue("v")),
  _w_vel(coupledValue("w")),

  // Gradients
  _grad_u_vel(coupledGradient("u")),
  _grad_v_vel(coupledGradient("v")),
  _grad_w_vel(coupledGradient("w")),

  // Variable numberings
  _u_vel_var_number(coupled("u")),
  _v_vel_var_number(coupled("v")),
  _w_vel_var_number(coupled("w"))

{
}

Real CoupledConvection::computeQpResidual()
{
  RealVectorValue V(_u_vel[_qp],_v_vel[_qp],_w_vel[_qp]);
  return _test[_i][_qp] *
  (
    (_grad_u[_qp] * V) +
    (_grad_u_vel[_qp](0) + _grad_v_vel[_qp](1) + _grad_w_vel[_qp](2)) * _u[_qp]
  );
}

Real CoupledConvection::computeQpJacobian()
{
 RealVectorValue V(_u_vel[_qp],_v_vel[_qp],_w_vel[_qp]);
 return _test[_i][_qp] *
 (
   (_grad_phi[_j][_qp] * V) +
   (_grad_u_vel[_qp](0) + _grad_v_vel[_qp](1) + _grad_w_vel[_qp](2)) * _phi[_j][_qp]
 );
}

Real CoupledConvection::computeQpOffDiagJacobian(unsigned jvar)
{
  if (jvar == _u_vel_var_number)
  {
    return (_grad_u[_qp](0) * _phi[_j][_qp] + _u[_qp] * _grad_phi[_j][_qp](0)) * _test[_i][_qp];
  }

  else if (jvar == _v_vel_var_number)
  {
    return (_grad_u[_qp](1) * _phi[_j][_qp] + _u[_qp] * _grad_phi[_j][_qp](1)) * _test[_i][_qp];
  }

  else if (jvar == _w_vel_var_number)
  {
    return (_grad_u[_qp](2) * _phi[_j][_qp] + _u[_qp] * _grad_phi[_j][_qp](2)) * _test[_i][_qp];
  }

  else
    return 0;
}
