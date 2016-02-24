/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "MultiAuxVariablesAction.h"
#include "Factory.h"
#include "Parser.h"
#include "FEProblem.h"

#include <sstream>
#include <stdexcept>

// libMesh includes
#include "libmesh/libmesh.h"
#include "libmesh/exodusII_io.h"
#include "libmesh/equation_systems.h"
#include "libmesh/nonlinear_implicit_system.h"
#include "libmesh/explicit_system.h"
#include "libmesh/string_to_enum.h"

const Real MultiAuxVariablesAction::_abs_zero_tol = 1e-12;

template<>
InputParameters validParams<MultiAuxVariablesAction>()
{
  MooseEnum orders("CONSTANT FIRST SECOND THIRD FOURTH", "FIRST");
  MooseEnum families("LAGRANGE MONOMIAL HERMITE SCALAR HIERARCHIC CLOUGH XYZ SZABAB BERNSTEIN L2_LAGRANGE", "LAGRANGE");

  InputParameters params = validParams<Action>();
  params.addClassDescription("Set up auxvariables for a polycrystal sample");
  params.addParam<MooseEnum>("family", families, "Specifies the family of FE shape functions to use for this variable");
  params.addParam<MooseEnum>("order", orders, "Specifies the order of the FE shape function to use for this variable");
  params.addRequiredParam<std::vector<unsigned int> >("op_num", "Vector that specifies the number of order parameters to create");
  params.addRequiredParam<std::vector<std::string> >("var_name_base", "Vector that specifies the base name of the variables");
  return params;
}

MultiAuxVariablesAction::MultiAuxVariablesAction(const InputParameters & params) :
    Action(params)
{
}

void
MultiAuxVariablesAction::act()
{
  
MooseEnum order = getParam<MooseEnum>("order");
MooseEnum family = getParam<MooseEnum>("family");
std::vector<unsigned int> _op_num = getParam<std::vector<unsigned int> >("op_num");
std::vector<std::string> _var_name_base = getParam<std::vector<std::string> >("var_name_base");

#ifdef DEBUG
  Moose::err << "Inside the MultiAuxVariablesAction Object\n"
             << "VariableBase: " << _var_name_base
             << "\torder: " << getParam<MooseEnum>("order")
             << "\tfamily: " << getParam<MooseEnum>("family") << std::endl;
#endif

unsigned int size_o = _op_num.size();
unsigned int size_v = _var_name_base.size();

if (size_o != size_v)
  mooseError("op_num and var_name_base must be vectors of the same size");


  // Loop through the number of order parameters
  for (unsigned int val = 0; val < size_o; val++)
  {
    for (unsigned int op = 0; op < _op_num[val]; op++)
    {

      //Create variable names
      std::string var_name = _var_name_base[val];
      std::stringstream out;
      out << op;
      var_name.append(out.str());

      _problem->addAuxVariable(var_name,
                            FEType(Utility::string_to_enum<Order>(order),
                                  Utility::string_to_enum<FEFamily>(family)));
    }
  }
}
