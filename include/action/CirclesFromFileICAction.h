/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef CIRCLESFROMFILEICACTION_H
#define CIRCLESFROMFILEICACTION_H

#include "InputParameters.h"
#include "FEProblem.h"
#include "Action.h"

class CirclesFromFileICAction: public Action
{
public:
  CirclesFromFileICAction(const InputParameters & params);

  virtual void act();

private:

  std::string _var_name_base;
  unsigned int _op_num;
  FileName _file_name;

  std::vector<Real> _x;
  std::vector<Real> _y;
  std::vector<Real> _z;
  std::vector<Real> _r;
};

template<>
InputParameters validParams<CirclesFromFileICAction>();

#endif //CIRCLESFROMFILEICACTION_H
