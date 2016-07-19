/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "LandauPolynomialMaterial.h"

#include "libmesh/quadrature.h"

template<>
InputParameters validParams<LandauPolynomialMaterial>()
{
  InputParameters params = validParams<DerivativeFunctionMaterialBase>();
  params.addClassDescription("Material that implements a Landau type polynomial to sync order parameters to concentration variables");
  params.addRequiredCoupledVar("c", "Concentration variable");
  params.addRequiredCoupledVarWithAutoBuild("args", "var_name_base", "op_num", "Array of coupled variables");
  params.addParam<Real>("op_tracking_coeff", 1, "Coefficient of order parameter tracking in free energy");
  return params;
}

LandauPolynomialMaterial::LandauPolynomialMaterial(const InputParameters & parameters) :
  DerivativeFunctionMaterialBase(parameters),
  _c(coupledValue("c")),
  _nop(coupledComponents("args")),
  _v(_nop),
  _c_var(coupled("c")),
  _v_var(_nop),
  _B(getParam<Real>("op_tracking_coeff"))
{
  for (unsigned int n = 0; n < _nop; ++n)
  {
    _v[n] = &coupledValue("args", n);
    _v_var[n] = coupled("args", n);
  }
}

Real
LandauPolynomialMaterial::computeF()
{
  Real op_sum_s = 0.0;
  Real op_sum_c = 0.0;

  for (unsigned int n = 0; n < _nop; ++n)
  {
    op_sum_s += (*_v[n])[_qp] * (*_v[n])[_qp];
    op_sum_c += (*_v[n])[_qp] * (*_v[n])[_qp] * (*_v[n])[_qp];
  }

  return _B * (_c[_qp] * _c[_qp] + 6.0 * (1.0 - _c[_qp]) * op_sum_s -
         4.0 * (2.0 - _c[_qp]) * op_sum_c + 3.0 * op_sum_s * op_sum_s);
}

Real
LandauPolynomialMaterial::computeDF(unsigned int j_var)
{
  Real ans = 0.0;
  Real op_sum_s = 0.0;

  for (unsigned int n = 0; n < _nop; ++n)
    op_sum_s += (*_v[n])[_qp] * (*_v[n])[_qp];

  if (j_var == _c_var)
  {
    Real op_sum_c = 0.0;
    for (unsigned int n = 0; n < _nop; ++n)
      op_sum_c += (*_v[n])[_qp] * (*_v[n])[_qp] * (*_v[n])[_qp];

    ans = _B * (2.0 * _c[_qp] - 6.0 * op_sum_s + 4.0 * op_sum_c);
  }
  else
  {
    for (unsigned int n = 0; n < _nop; ++n)
      if (j_var == _v_var[n])
        ans = 12.0 * _B * ((1.0 - _c[_qp]) * (*_v[n])[_qp] - (2.0 - _c[_qp]) *
              (*_v[n])[_qp] * (*_v[n])[_qp] + (*_v[n])[_qp] * op_sum_s);
  }
  return ans;
}

Real
LandauPolynomialMaterial::computeD2F(unsigned int j_var, unsigned int k_var)
{
  Real ans = 0.0;
  if ((j_var == _c_var) && (k_var == _c_var))
    ans = 2.0 * _B;
  else if ((j_var == _c_var) ||  (k_var == _c_var))
  {
    for (unsigned int n = 0; n < _nop; ++n)
      if ((j_var == _v_var[n]) || (k_var == _v_var[n]))
        ans = 12.0 * _B * (*_v[n])[_qp] * ((*_v[n])[_qp] - 1.0);
  }
  else
  {
    for (unsigned int n = 0; n < _nop; ++n)
      if ((j_var == _v_var[n]) && (k_var == _v_var[n]))
      {
        Real op_sum_s = 0.0;
        for (unsigned int n = 0; n < _nop; ++n)
          op_sum_s += (*_v[n])[_qp] * (*_v[n])[_qp];

        ans = 12.0 * _B * (1.0 - _c[_qp] - 2.0 * (2.0 - _c[_qp]) * (*_v[n])[_qp] +
              2.0 * (*_v[n])[_qp] * (*_v[n])[_qp] + op_sum_s);
      }
      else if (j_var == _v_var[n])
        for (unsigned int m = 0; m < _nop; ++m)
          if (k_var == _v_var[m])
            ans = 24.0 * _B * (*_v[n])[_qp] * (*_v[m])[_qp];
  }
  return ans;
}

Real
LandauPolynomialMaterial::computeD3F(unsigned int j_var, unsigned int k_var, unsigned int l_var)
{
  Real ans = 0.0;
  for (unsigned int n = 0; n < _nop; ++n)
    if((j_var == _v_var[n] && k_var == _v_var[n]) || (j_var == _v_var[n] && l_var == _v_var[n]) ||
       (k_var == _v_var[n] && l_var == _v_var[n]))
    {
      if ((j_var == _c_var) || (k_var == _c_var) || (l_var == _c_var))
        ans = 12.0 * _B * (2.0 * (*_v[n])[_qp] - 1.0);
      else if (j_var == _v_var[n] && k_var == _v_var[n] && l_var == _v_var[n])
        ans = 24.0 * _B * (_c[_qp] - 2.0 + 3.0 * (*_v[n])[_qp]);
      else
        for (unsigned int m = 0; m < _nop; ++m)
          if (m != n && (j_var == _v_var[m] || k_var == _v_var[m] || l_var == _v_var[m]))
            ans = 24.0 * _B * (*_v[m])[_qp];
    }
  return ans;
}
