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
#include "WettingDirectionBadillo.h"

template<>
InputParameters validParams<WettingDirectionBadillo>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Computes div(W sqrt(2) phi_l phi_v r_lv/norm(r_lv) ) residual term for the wetting model from Badillo2015");
  params.addParam<MaterialPropertyName>("int_width_name", "int_width", "Name of the material property that provides the interface width");
  params.addRequiredCoupledVar("phi_w", "Variable defining the solid atomic fraction");
  return params;
}

WettingDirectionBadillo::WettingDirectionBadillo(const InputParameters & parameters) :
    Kernel(parameters),
    _int_width(getMaterialProperty<Real>("int_width_name")),
    _phi_w_var(coupled("phi_w")),
    _phi_w(coupledValue("phi_w")),
    _grad_phi_w(coupledGradient("phi_w")),
    _tol(1e-8)
{}

Real
WettingDirectionBadillo::computeQpResidual()
{
  //Compute r vector used in the model, where phi_v = 1 - phi_l - phi_w has been used to make it a function of phi_l (u) and phi_w
  RealGradient r_lv = _grad_u[_qp] + _grad_phi_w[_qp] * _u[_qp] - _grad_u[_qp] * _phi_w[_qp];

  //Compute weak form of div(W sqrt(2) phi_l phi_v r_lv/norm(r_lv) )
  if (r_lv.norm() < _tol)
    return 0.0;
  else
    return - _int_width[_qp] * std::sqrt(2) * _u[_qp] * (1 - _u[_qp] - _phi_w[_qp]) * r_lv / r_lv.norm() *  _grad_test[_i][_qp];
}

Real
WettingDirectionBadillo::computeQpJacobian()
{
  RealGradient r_lv = _grad_u[_qp] + _grad_phi_w[_qp] * _u[_qp] - _grad_u[_qp] * _phi_w[_qp];

  //Compute derivative of r_lv wrt phi_l
  RealGradient dr_lv = _grad_phi[_j][_qp] + _grad_phi_w[_qp] * _phi[_j][_qp] - _grad_phi[_j][_qp] * _phi_w[_qp];

  if (r_lv.norm() < _tol)
    return 0.0;
  else
  {
    RankTwoTensor eye(RankTwoTensor::initIdentity);
    RankTwoTensor rXr;
    rXr.vectorOuterProduct(r_lv, r_lv);

    return - _int_width[_qp] * std::sqrt(2) * (
      _phi[_j][_qp] * (1 - 2 * _u[_qp] - _phi_w[_qp]) * r_lv / r_lv.norm()
      + _u[_qp] * (1 - _u[_qp] - _phi_w[_qp]) * (eye / r_lv.norm() - rXr / (r_lv.norm_sq() * r_lv.norm())) * dr_lv
      ) *  _grad_test[_i][_qp];
    }
}

Real
WettingDirectionBadillo::computeQpOffDiagJacobian(unsigned int jvar)
{
  // get the coupled variable jvar is referring to

  if(jvar == _phi_w_var)
  {
    RealGradient r_lv = _grad_u[_qp] + _grad_phi_w[_qp] * _u[_qp] - _grad_u[_qp] * _phi_w[_qp];

    //Compute derivative wrt phi_w
    RealGradient dr_lv = _grad_phi[_j][_qp] * _u[_qp] - _grad_u[_qp] * _phi[_j][_qp];

    if (r_lv.norm() < _tol)
      return 0.0;
    else
    {
      RankTwoTensor eye(RankTwoTensor::initIdentity);
      RankTwoTensor rXr;
      rXr.vectorOuterProduct(r_lv, r_lv);

      return - _int_width[_qp] * std::sqrt(2) * (
        - _u[_qp] * _phi[_j][_qp] * r_lv / r_lv.norm()
        + _u[_qp] * (1 - _u[_qp] - _phi_w[_qp]) * (eye / r_lv.norm() - rXr / (r_lv.norm_sq() * r_lv.norm())) * dr_lv
        ) *  _grad_test[_i][_qp];
      }
  }
  else
    return 0.0;
}
