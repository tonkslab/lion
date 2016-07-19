/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef LANDAUPOLYNOMIALMATERIAL_H
#define LANDAUPOLYNOMIALMATERIAL_H

#include "DerivativeFunctionMaterialBase.h"

// Forward Declarations
class LandauPolynomialMaterial;

template<>
InputParameters validParams<LandauPolynomialMaterial>();

/**
 * Landau Polynomial Free energy function with auto-built variables that
 * allows order parameters to follow a concentration variable. The polynomial
 * has the form:
 * \f$ F = B[c^2+6(1-c)|Sigma_i \eta_i^2-4(2-c)\Sigma_i \eta_i^3 + 3(\Sigma_i \eta_i^2)^2] \f$.
 */
class LandauPolynomialMaterial : public DerivativeFunctionMaterialBase
{
public:
  LandauPolynomialMaterial(const InputParameters & parameters);

protected:
  virtual Real computeF();
  virtual Real computeDF(unsigned int j_var);
  virtual Real computeD2F(unsigned int j_var, unsigned int k_var);
  virtual Real computeD3F(unsigned int j_var, unsigned int k_var, unsigned int l_var);

private:
  const VariableValue & _c;
  unsigned int _nop;
  std::vector<const VariableValue *> _v;
  unsigned int _c_var;
  std::vector<unsigned int> _v_var;
  Real _B;
};

#endif // LANDAUPOLYNOMIALMATERIAL_H
