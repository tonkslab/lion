/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef MULTIAUXVARIABLESACTION_H
#define MULTIAUXVARIABLESACTION_H

#include "InputParameters.h"
#include "Action.h"

/**
 * Automatically generates all auxvariables given vectors telling it the names
 * and how many to create
 */
class MultiAuxVariablesAction: public Action
{
public:
  MultiAuxVariablesAction(const InputParameters & params);

  virtual void act();

private:
  static const Real _abs_zero_tol;

  std::vector<unsigned int>_op_num;
  std::vector<std::string>_var_name_base;
};

template<>
InputParameters validParams<MultiAuxVariablesAction>();

#endif //MULTIAUXVARIABLESACTION_H
