/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "ACInterfaceKernelAction.h"
#include "Factory.h"
#include "Parser.h"
#include "Conversion.h"
#include "FEProblem.h"

template<>
InputParameters validParams<ACInterfaceKernelAction>()
{
  InputParameters params = validParams<Action>();

  params.addRequiredParam<unsigned int>("op_num", "specifies the number of grains to create");
  params.addRequiredParam<std::string>("var_name_base", "specifies the base name of the variables");
  params.addParam<bool>("implicit", true, "Whether kernels are implicit or not");
  params.addParam<bool>("use_displaced_mesh", false, "Whether to use displaced mesh in the kernels");
  params.addParam<std::string>("kappa_name", "kappa_op", "The kappa used with the kernel");
  params.addParam<std::string>("mob_name", "L", "The mobility used with the kernel");

  return params;
}

ACInterfaceKernelAction::ACInterfaceKernelAction(const InputParameters & params) :
    Action(params),
    _op_num(getParam<unsigned int>("op_num")),
    _var_name_base(getParam<std::string>("var_name_base")),
    _implicit(getParam<bool>("implicit"))
{
}

void
ACInterfaceKernelAction::act()
{
  for (unsigned int op = 0; op < _op_num; ++op)
  {
    //
    // Create variable names
    //

    std::string var_name = _var_name_base + Moose::stringify(op);

    //
    // Set up ACInterface kernels
    //

    {
      InputParameters params = _factory.getValidParams("ACInterface");
      params.set<NonlinearVariableName>("variable") = var_name;
      params.set<bool>("implicit") = getParam<bool>("implicit");
      params.set<bool>("use_displaced_mesh") = getParam<bool>("use_displaced_mesh");
      params.set<MaterialPropertyName>("kappa_name") = getParam<std::string>("kappa_name");
      params.set<MaterialPropertyName>("mob_name") = getParam<std::string>("mob_name");

      std::string kernel_name = "ACInt_" + var_name;
      _problem->addKernel("ACInterface", kernel_name, params);
    }
  }
}
