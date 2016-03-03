/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "AllenCahnKernelAction.h"
#include "Factory.h"
#include "Parser.h"
#include "Conversion.h"
#include "FEProblem.h"

template<>
InputParameters validParams<AllenCahnKernelAction>()
{
  InputParameters params = validParams<Action>();

  params.addRequiredParam<unsigned int>("op_num", "specifies the number of grains to create");
  params.addRequiredParam<std::string>("var_name_base", "specifies the base name of the variables");
  params.addParam<bool>("implicit", true, "Whether kernels are implicit or not");
  params.addParam<bool>("use_displaced_mesh", false, "Whether to use displaced mesh in the kernels");
  params.addParam<std::string>("mob_name", "L", "The mobility used with the kernels");
  params.addParam<std::string>("f_name", "Base name of the free energy function F defined in a DerivativeParsedMaterial");

  return params;
}

AllenCahnKernelAction::AllenCahnKernelAction(const InputParameters & params) :
    Action(params),
    _op_num(getParam<unsigned int>("op_num")),
    _var_name_base(getParam<std::string>("var_name_base")),
    _implicit(getParam<bool>("implicit"))
{
}

void
AllenCahnKernelAction::act()
{
  for (unsigned int op = 0; op < _op_num; ++op)
  {
    //
    // Create variable names
    //

    std::string var_name = _var_name_base + Moose::stringify(op);
    std::vector<VariableName> v;
    v.resize(_op_num - 1);

    unsigned int ind = 0;
    for (unsigned int j = 0; j < _op_num; ++j)
      if (j != op)
        v[ind++] = _var_name_base + Moose::stringify(j);

    //
    // Set up the AllenCahn kernels
    //

    {
      InputParameters params = _factory.getValidParams("AllenCahn");
      params.set<NonlinearVariableName>("variable") = var_name;
      params.set<std::vector<VariableName> >("args") = v;
      params.set<MaterialPropertyName>("mob_name") = getParam<std::string>("mob_name");
      params.set<MaterialPropertyName>("f_name") = getParam<std::string>("f_name");
      params.set<bool>("implicit") = _implicit;
      params.set<bool>("use_displaced_mesh") = getParam<bool>("use_displaced_mesh");

      std::string kernel_name = "AC_" + var_name;
      _problem->addKernel("AllenCahn", kernel_name, params);
    }
  }
}
