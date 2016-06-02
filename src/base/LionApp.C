#include "LionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

/*
 * Actions
*/
#include "ACInterfaceKernelAction.h"
#include "AllenCahnKernelAction.h"
#include "SGRigidBodyKernelAction.h"
#include "TimeDerivativeKernelAction.h"

/*
 * Kernels
*/
#include "MatConvection.h"
#include "MatTimeDerivative.h"
#include "GradientDirection.h"

template<>
InputParameters validParams<LionApp>()
{
  InputParameters params = validParams<MooseApp>();

  params.set<bool>("use_legacy_uo_initialization") = false;
  params.set<bool>("use_legacy_uo_aux_computation") = false;
  params.set<bool>("use_legacy_output_syntax") = false;

  return params;
}

LionApp::LionApp(InputParameters parameters) :
    MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  LionApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  LionApp::associateSyntax(_syntax, _action_factory);
}

LionApp::~LionApp()
{
}

// External entry point for dynamic application loading
extern "C" void LionApp__registerApps() { LionApp::registerApps(); }
void
LionApp::registerApps()
{
  registerApp(LionApp);
}

// External entry point for dynamic object registration
extern "C" void LionApp__registerObjects(Factory & factory) { LionApp::registerObjects(factory); }
void
LionApp::registerObjects(Factory & factory)
{
  registerKernel(MatConvection);
  registerKernel(MatTimeDerivative);
  registerKernel(GradientDirection);
}

// External entry point for dynamic syntax association
extern "C" void LionApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory) { LionApp::associateSyntax(syntax, action_factory); }
void
LionApp::associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  syntax.registerActionSyntax("ACInterfaceKernelAction", "Kernels/ACInterfaceKernel");
  syntax.registerActionSyntax("AllenCahnKernelAction", "Kernels/AllenCahnKernel");
  syntax.registerActionSyntax("SGRigidBodyKernelAction", "Kernels/SGRigidBodyKernel");
  syntax.registerActionSyntax("TimeDerivativeKernelAction", "Kernels/TimeDerivativeKernel");

  registerAction(ACInterfaceKernelAction, "add_kernel");
  registerAction(AllenCahnKernelAction, "add_kernel");
  registerAction(SGRigidBodyKernelAction, "add_kernel");
  registerAction(TimeDerivativeKernelAction, "add_kernel");
}
