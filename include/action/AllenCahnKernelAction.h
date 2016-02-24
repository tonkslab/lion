/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef ALLENCAHNKERNELACTION_H
#define ALLENCAHNKERNELACTION_H

#include "Action.h"

class AllenCahnKernelAction: public Action
{
public:
  AllenCahnKernelAction(const InputParameters & params);

  virtual void act();

private:
  unsigned int _op_num;
  std::string _var_name_base;
  bool _implicit;
};

template<>
InputParameters validParams<AllenCahnKernelAction>();

#endif //ALLENCAHNKERNELACTION_H
