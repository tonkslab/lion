/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef SGRIGIDBODYKERNELACTION_H
#define SGRIGIDBODYKERNELACTION_H

#include "Action.h"

class SGRigidBodyKernelAction: public Action
{
public:
  SGRigidBodyKernelAction(const InputParameters & params);

  virtual void act();

private:
  unsigned int _op_num;
  std::string _var_name_base;
  bool _implicit;
};

template<>
InputParameters validParams<SGRigidBodyKernelAction>();

#endif //SGRIGIDBODYKERNELACTION_H
