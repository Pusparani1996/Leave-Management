import 'dart:developer';

import 'package:auto_route/auto_route.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leavemanagementadmin/logic/Authflow/auth_flow_cubit.dart';
import 'package:leavemanagementadmin/logic/designation/cubit/get_alldesign_cubit.dart';
import 'package:leavemanagementadmin/router/router.gr.dart';

import '../logic/branch/getallbranch_cubit.dart';
import '../logic/department/cubit/get_alldept_cubit.dart';

@RoutePage()
class AuthFlowPage extends StatefulWidget {
  const AuthFlowPage({Key? key}) : super(key: key);

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  @override
  void initState() {
    context.read<AuthFlowCubit>().getloginstatus();
    context.read<GetallbranchCubit>().getallbranch();
    context.read<GetAlldeptCubit>().getalldept();
    context.read<GetAlldesignCubit>().getalldesign();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AuthFlowCubit>().state;
    final status = s.status;

    return AutoRouter.declarative(
      routes: (context) {
        log(status.toString());
        switch (status) {
          case logStatus.loggedIn:
            return [
              SidebarRoute()
              // const AppUpdaterRoute()
            ];
          case logStatus.loggedOut:
            return [const LoginRoute()];
          case logStatus.initial:
            return [];
        }
      },
    );
  }
}
