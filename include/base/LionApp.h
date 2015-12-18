#ifndef LIONAPP_H
#define LIONAPP_H

#include "MooseApp.h"

class LionApp;

template<>
InputParameters validParams<LionApp>();

class LionApp : public MooseApp
{
public:
  LionApp(InputParameters parameters);
  virtual ~LionApp();

  static void registerApps();
  static void registerObjects(Factory & factory);
  static void associateSyntax(Syntax & syntax, ActionFactory & action_factory);
};

#endif /* LIONAPP_H */
