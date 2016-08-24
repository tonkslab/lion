/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "CirclesFromFileICAction.h"
#include "Factory.h"
#include "Conversion.h"
#include <stdlib.h>

template<>
InputParameters validParams<CirclesFromFileICAction>()
{
  InputParameters params = validParams<Action>();

  params.addClassDescription("Creates overlapping SmoothCircleIC's for conserved variable and order parameters");
  params.addRequiredParam<std::string>("var_name_base", "specifies the base name of the variables");
  params.addRequiredParam<unsigned int>("op_num", "Number of order parameters");
  params.addRequiredParam<FileName>("file_name", "File containing sphere centers and radii");
  params.addRequiredParam<VariableName>("c", "Name of coupled conserved variable");
  params.addParam<Real>("op_invalue", 1, "Value inside spheres for order parameters");
  params.addParam<Real>("op_outvalue", 0, "Value outside spheres for order parameters");
  params.addParam<Real>("c_invalue", 1, "Value inside spheres for conserved variable");
  params.addParam<Real>("c_outvalue", 0, "Value outside spheres for conserved variable");
  params.addParam<Real>("int_width", 0, "Width of variable interfaces for spheres");
  params.addParam<bool>("3D_spheres", true, "In 3D, whether objects are spheres or columns");
  params.addParam<unsigned int>("header_length", 0, "Number of lines to skip at top of file");
  return params;
}

CirclesFromFileICAction::CirclesFromFileICAction(const InputParameters & params) :
    Action(params),
    _var_name_base(getParam<std::string>("var_name_base")),
    _op_num(getParam<unsigned int>("op_num")),
    _file_name(getParam<FileName>("file_name")),
    _x(_op_num),
    _y(_op_num),
    _z(_op_num),
    _r(_op_num)
{
  //Read File
  MooseUtils::checkFileReadable(_file_name);

  std::ifstream inFile;
  unsigned int header_length = getParam<unsigned int>("header_length");

  inFile.open(_file_name.c_str());

  std::vector<Real> data;
  data.resize(4 * _op_num);

  for (unsigned int i = 0; i < header_length; ++i)
    inFile.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

  for (unsigned int i = 0; i < 4 * _op_num; ++i)
    inFile >> data[i];

  for (unsigned int i = 0; i < _op_num; ++i)
  {
    _x[i] = data[4 * i];
    _y[i] = data[4 * i + 1];
    _z[i] = data[4 * i + 2];
    _r[i] = data[4 * i + 3];
  }
  inFile.close();
}

void
CirclesFromFileICAction::act()
{
  #ifdef DEBUG
    Moose::err << "Inside the CirclesFromFileICAction Object\n";
  #endif

  VariableName c = getParam<VariableName>("c");
  Real i_w = getParam<Real>("int_width");
  //
  // Create MultiSmoothCircleIC
  //
  InputParameters parameters = _factory.getValidParams("SpecifiedSmoothCircleIC");
  parameters.set<std::vector<Real> >("x_positions") = _x;
  parameters.set<std::vector<Real> >("y_positions") = _y;
  parameters.set<std::vector<Real> >("z_positions") = _z;
  parameters.set<std::vector<Real> >("radii") = _r;
  parameters.set<VariableName>("variable") = c;
  parameters.set<Real>("invalue") = getParam<Real>("c_invalue");
  parameters.set<Real>("outvalue") = getParam<Real>("c_outvalue");
  parameters.set<Real>("int_width") = i_w;
  parameters.set<bool>("3D_spheres") = getParam<bool>("3D_spheres");

  _problem->addInitialCondition("SpecifiedSmoothCircleIC", "PolySmoothCircleIC", parameters);

  for (unsigned int op = 0; op < _op_num; ++op)
  {
    // Create OP Variable Name
    std::string var_name = _var_name_base + Moose::stringify(op);

    // Create SmoothCircleIC
    InputParameters parameters = _factory.getValidParams("SmoothCircleIC");
    parameters.set<VariableName>("variable") = var_name;
    parameters.set<Real>("x1") = _x[op];
    parameters.set<Real>("y1") = _y[op];
    parameters.set<Real>("z1") = _z[op];
    parameters.set<Real>("radius") = _r[op];
    parameters.set<Real>("invalue") = getParam<Real>("op_invalue");
    parameters.set<Real>("outvalue") = getParam<Real>("op_outvalue");
    parameters.set<Real>("int_width") = i_w;
    parameters.set<bool>("3D-spheres") = getParam<bool>("3D_spheres");

    std::string ic_name = "Circle_gr" + var_name;
    _problem->addInitialCondition("SmoothCircleIC", ic_name, parameters);
  }
}
