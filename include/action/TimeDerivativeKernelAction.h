/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef TimeDerivativeKernelAction_H
#define TimeDerivativeKernelAction_H

#include "Action.h"

class TimeDerivativeKernelAction: public Action
{
public:
  TimeDerivativeKernelAction(const InputParameters & params);

  virtual void act();

private:
  unsigned int _op_num;
  std::string _var_name_base;
  bool _implicit;
};

template<>
InputParameters validParams<TimeDerivativeKernelAction>();

#endif //TimeDerivativeKernelAction_H
