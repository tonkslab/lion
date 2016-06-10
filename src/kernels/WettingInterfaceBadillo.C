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
#include "WettingInterfaceBadillo.h"

template<>
InputParameters validParams<WettingInterfaceBadillo>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Computes div(W^2 r_lv) residual term for the wetting model from Badillo2015");
  params.addParam<MaterialPropertyName>("int_width_name", "int_width", "Name of the material property that provides the interface width");
  params.addRequiredCoupledVar("phi_w", "Variable defining the solid atomic fraction");
  return params;
}

WettingInterfaceBadillo::WettingInterfaceBadillo(const InputParameters & parameters) :
    Kernel(parameters),
    _int_width(getMaterialProperty<Real>("int_width_name")),
    _phi_w_var(coupled("phi_w")),
    _phi_w(coupledValue("phi_w")),
    _grad_phi_w(coupledGradient("phi_w"))
{}

Real
WettingInterfaceBadillo::computeQpResidual()
{
  //Compute r vector used in the model, where phi_v = 1 - phi_l - phi_w has been used to make it a function of phi_l (u) and phi_w
  RealGradient r_lv = _grad_u[_qp] + _grad_phi_w[_qp] * _u[_qp] - _grad_u[_qp] * _phi_w[_qp];

  //weak form of div(W^2 * r_lv)
  return _int_width[_qp] * _int_width[_qp] * r_lv * _grad_test[_i][_qp];
}

Real
WettingInterfaceBadillo::computeQpJacobian()
{
  //Derivative of r_lv wrt nodal values of phi_l (u)
  RealGradient dr_lv = _grad_phi[_j][_qp] + _grad_phi_w[_qp] * _phi[_j][_qp] - _grad_phi[_j][_qp] * _phi_w[_qp];

  return _int_width[_qp] * _int_width[_qp] * dr_lv * _grad_test[_i][_qp];
}

Real
WettingInterfaceBadillo::computeQpOffDiagJacobian(unsigned int jvar)
{
  if(jvar == _phi_w_var)
  {
    //Derivative of r_lv wrt nodal values of phi_w
    RealGradient dr_lv = _grad_phi[_j][_qp] * _u[_qp] - _grad_u[_qp] * _phi[_j][_qp];

    return _int_width[_qp] * _int_width[_qp] * dr_lv *  _grad_test[_i][_qp];
  }
  else
    return 0.0;
}
