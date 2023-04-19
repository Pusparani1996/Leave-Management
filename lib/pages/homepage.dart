import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
import 'package:leavemanagementadmin/constant.dart';
import 'package:leavemanagementadmin/logic/Employee/cubit/check_empcode_cubit.dart';
import 'package:leavemanagementadmin/logic/Employee/cubit/checkemailexist_cubit.dart';
import 'package:leavemanagementadmin/logic/Employee/cubit/create_employee_cubit.dart';
import 'package:leavemanagementadmin/logic/Employee/cubit/getemployeelist_cubit.dart';
import 'package:leavemanagementadmin/logic/branch/getallbranch_cubit.dart';
import 'package:leavemanagementadmin/logic/department/cubit/get_alldept_cubit.dart';
import 'package:leavemanagementadmin/logic/designation/cubit/get_alldesign_cubit.dart';
import 'package:leavemanagementadmin/logic/role/cubit/get_role_cubit.dart';
import 'package:leavemanagementadmin/model/emp%20_listmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import '../logic/Employee/cubit/updateemployee_cubit.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  /// Creates the home page.
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Employee> employees = <Employee>[];
  DateTime? updatetime;

  Widget _dataofbirth(String dob) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DateTimeField(
              controller: TextEditingController(text: dob),
              decoration: const InputDecoration(
                labelText: 'Date Of Joining',
              ),
              format: format,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                        context: context,
                        initialDate: initialdate!,
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2025),
                        helpText: "SELECT DATE OF JOINING",
                        cancelText: "CANCEL",
                        confirmText: "OK",
                        fieldHintText: "DATE/MONTH/YEAR",
                        fieldLabelText: "ENTER DATE OF JOINING",
                        errorFormatText: "Enter a Valid Date",
                        errorInvalidText: "Date Out of Range")
                    .then((value) {
                  setState(() {
                    datetime = "${value!.year}-${value.month}-${value.day}";
                    datetime2 = "${value.year}-${value.month}-${value.day}";
                    updatetime = value;
                  });
                  log(datetime);

                  return value;
                });
              },
            ),
          ),
        ]);
  }

  bool? ismoreloading;
  int pagenumber = 1;
  int datalimit = 15;
  ScrollController datatablescrollcontroller = ScrollController();
  @override
  void initState() {
    super.initState();

    readall();
    _selectedRadioTile = 1;
    datatablescrollcontroller.addListener(() {
      if (datatablescrollcontroller.position.pixels ==
          datatablescrollcontroller.position.maxScrollExtent) {
        if (ismoreloading == false) {
          log('Item reach its limit');
        } else {
          setState(() {
            datalimit = datalimit + 15;
            // pagenumber = pagenumber + 1;
          });
          displayedDataCell.clear();
          context
              .read<GetemployeelistCubit>()
              .getemployeelist(ismoredata: true, datalimit: datalimit);

          log('reach buttom');
        }
      }
    });
  }

  int? _selectedRadioTile;

  setSelectedRadioTile(int val) {
    setState(() {
      _selectedRadioTile = val;
    });
  }

  void readall() {
    log('reading cubit.......');
    context.read<GetallbranchCubit>().getallbranch();
    context.read<GetAlldeptCubit>().getalldept();
    context.read<GetAlldesignCubit>().getalldesign();
    context.read<GetRoleCubit>().getallrole();
    context
        .read<GetemployeelistCubit>()
        .getemployeelist(datalimit: datalimit, ismoredata: true);
  }

  void fetchdata(
      {required List<Employee> allemplist,
      required Map<dynamic, dynamic> branchidwithname,
      required Map<dynamic, dynamic> deptnamewithid,
      required Map<dynamic, dynamic> designidwithname}) {
    log('Not empty');
    log('All employee List Length :${allemplist.length}');

    for (var item in allemplist) {
      // context
      //     .read<GetspecificCubit>()
      //     .getspecificbrance(id: item.branchId.toString());
      if (branchidwithname.isNotEmpty &&
          deptnamewithid.isNotEmpty &&
          designidwithname.isNotEmpty) {
        displayedDataCell.add(
          DataCell(
            Text(
              (ismoreloading!
                      ? allemplist.lastIndexOf(item) + 1
                      : allemplist.indexOf(item) + 1)
                  .toString(),
            ),
          ),
        );
        displayedDataCell.add(
          DataCell(
            Text(item.employeeName),
          ),
        );
        displayedDataCell.add(
          DataCell(
            Text(designidwithname[item.employeeDesignationId].toString()),
          ),
        );

        displayedDataCell.add(
          DataCell(
            Text(deptnamewithid[item.employeeDepartmentId].toString()),
          ),
        );

        displayedDataCell.add(
          DataCell(Text(item.role)),
        );
        displayedDataCell.add(
          DataCell(
            Text(
              branchidwithname[item.employeeBranchId].toString(),
            ),
          ),
        );

        displayedDataCell.add(
          DataCell(TextButton(
              onPressed: () {
                empcode.text = item.employeeEmpCode.toString();
                _namefieldcontroller.text = item.employeeName;
                numbercontroller.text = item.employeePhone;
                emailcontroller.text = item.email;
                datetime2 =
                    "${item.employeeDateOfJoining.year}-${item.employeeDateOfJoining.month}-${item.employeeDateOfJoining.day}";

                setState(() {
                  dropdownvalue1 =
                      designidwithname[item.employeeDesignationId].toString();

                  dropdownvalue2 =
                      deptnamewithid[item.employeeDepartmentId].toString();
                  dropdownvalue3 = item.role;
                  dropdownvalue4 =
                      branchidwithname[item.employeeBranchId].toString();
                });

                // _namefieldcontroller.clear();
                // usernamecontroller.clear();
                // emailcontroller.clear();
                // numbercontroller.clear();
                // empcode.clear();
                // dropdownvalue1 = null;
                // dropdownvalue2 = null;
                // dropdownvalue3 = null;
                // dropdownvalue4 = null;
                showDialog(
                  context: context,
                  builder: (cnt) {
                    return BlocConsumer<GetallbranchCubit, GetallbranchState>(
                      listener: (context, branchstate) {
                        // TODO: implement listener
                      },
                      builder: (context, branchstate) {
                        return BlocConsumer<GetAlldeptCubit, GetAlldeptState>(
                          listener: (context, deptstate) {
                            // TODO: implement listener
                          },
                          builder: (context, deptstate) {
                            return BlocConsumer<GetAlldesignCubit,
                                GetAlldesignState>(
                              listener: (context, designstate) {
                                // TODO: implement listener
                              },
                              builder: (context, designstate) {
                                return BlocConsumer<GetRoleCubit, GetRoleState>(
                                  listener: (context, rolestate) {
                                    // TODO: implement listener
                                  },
                                  builder: (context, rolestate) {
                                    return BlocConsumer<CheckemailexistCubit,
                                        CheckemailexistState>(
                                      listener: (context, emailcheck) {
                                        // TODO: implement listener
                                      },
                                      builder: (context, emailcheck) {
                                        return BlocConsumer<CheckEmpcodeCubit,
                                            CheckEmpcodeState>(
                                          listener:
                                              (context, checkempStatefinal) {
                                            // TODO: implement listener
                                          },
                                          builder:
                                              (context, checkempStatefinal) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    void Function(
                                                            void Function())
                                                        setState) {
                                              return AlertDialog(
                                                actions: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300],
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {
                                                              _namefieldcontroller
                                                                  .clear();
                                                              datetime2 = '';

                                                              dropdownvalue1 =
                                                                  null;
                                                              dropdownvalue2 =
                                                                  null;
                                                              _position = null;
                                                            });
                                                          },
                                                          child: const Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blueGrey),
                                                          )),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: InkWell(
                                                            onTap: () {
                                                              dropdownvalue11 = designstate
                                                                  .designidwithname
                                                                  .keys
                                                                  .firstWhere(
                                                                      (k) =>
                                                                          designstate.designidwithname[
                                                                              k] ==
                                                                          dropdownvalue1,
                                                                      orElse: () =>
                                                                          null);
                                                              dropdownvalue22 = deptstate
                                                                  .deptidwithname
                                                                  .keys
                                                                  .firstWhere(
                                                                      (k) =>
                                                                          deptstate.deptidwithname[
                                                                              k] ==
                                                                          dropdownvalue2,
                                                                      orElse: () =>
                                                                          null);
                                                              dropdownvalue33 =
                                                                  rolestate
                                                                          .rolenamewithid[
                                                                      dropdownvalue3];
                                                              dropdownvalue44 = branchstate
                                                                  .branchidwithname
                                                                  .keys
                                                                  .firstWhere(
                                                                      (k) =>
                                                                          branchstate.branchidwithname[
                                                                              k] ==
                                                                          dropdownvalue4,
                                                                      orElse: () =>
                                                                          null);
                                                              context.read<UpdateemployeeCubit>().updateemployee(
                                                                  id: item
                                                                      .employeeId,
                                                                  empname:
                                                                      _namefieldcontroller
                                                                          .text,
                                                                  empcode:
                                                                      int.parse(empcode
                                                                          .text),
                                                                  phonenumber:
                                                                      numbercontroller
                                                                          .text,
                                                                  deptid:
                                                                      dropdownvalue22!,
                                                                  designid:
                                                                      dropdownvalue11!,
                                                                  branchid:
                                                                      dropdownvalue44!,
                                                                  roleid:
                                                                      dropdownvalue33!,
                                                                  dateofjoining:
                                                                      datetime2,
                                                                  emptype:
                                                                      _selectedRadioTile
                                                                          .toString(),
                                                                  email:
                                                                      emailcontroller
                                                                          .text);
                                                              // await ServiceApi()
                                                              //     .create_employee(
                                                              //         name: _namefieldcontroller.text,
                                                              //         desId: dropdownvalue11!,
                                                              //         depId: dropdownvalue22!,
                                                              //         dob: datetime,
                                                              //         token: finaltoken,
                                                              //         image: profileimage,
                                                              //         location: finallocation!)
                                                              //     .whenComplete(() {
                                                              //   getdata2().whenComplete(() {
                                                              //     _namefieldcontroller.clear();
                                                              //     all_desid = [];
                                                              //     all_depid = [];
                                                              //     all_dep = [];
                                                              //     all_des = [];
                                                              //     _position = null;
                                                              //     datetime2 = '';

                                                              //     dropdownvalue1 = null;
                                                              //     dropdownvalue2 = null;
                                                              //     setState(() {});

                                                              //     getcreate_status();
                                                              //     getdata();
                                                              EasyLoading
                                                                  .dismiss();
                                                              context.router
                                                                  .pop();
                                                              //   });
                                                              // });

                                                              // allemployee.add({
                                                              //   'name': _namefieldcontroller.text,
                                                              //   'branch': "Imphal West",
                                                              //   "role": "Developer",
                                                              //   "department": "Production"
                                                              // });
                                                              // log(create_statuscode.toString());
                                                              // //     getcreate_status();
                                                              // getdata();
                                                              // EasyLoading.dismiss();
                                                              // _namefieldcontroller.clear();
                                                              // emailcontroller.clear();
                                                              // numbercontroller.clear();
                                                              // empcode.clear();
                                                              // Navigator.of(context).pop();
                                                            },
                                                            child: Material(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            13),
                                                              ),
                                                              elevation: 15,
                                                              child:
                                                                  const CardWidget(
                                                                      color: Colors
                                                                          .green,
                                                                      width: 70,
                                                                      height:
                                                                          30,
                                                                      borderRadius:
                                                                          5,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Update',
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                      )),
                                                            )),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                                title: const Text(
                                                  "Update Employee",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Form(
                                                    child: SizedBox(
                                                      width: 300,
                                                      height: 670,
                                                      child: Column(
                                                        children: [
                                                          TextFormField(
                                                              onChanged:
                                                                  (value) {
                                                                context
                                                                    .read<
                                                                        CheckEmpcodeCubit>()
                                                                    .checkempcode(
                                                                        value);
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              controller:
                                                                  empcode,
                                                              decoration:
                                                                  InputDecoration(
                                                                suffix: checkempStatefinal
                                                                            .isexist
                                                                            .isEmpty ||
                                                                        empcode
                                                                            .value
                                                                            .text
                                                                            .isEmpty
                                                                    ? const SizedBox()
                                                                    : checkempStatefinal.isexist ==
                                                                            'false'
                                                                        ? Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: const [
                                                                              Text(
                                                                                'available',
                                                                                style: TextStyle(color: Colors.green),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 3,
                                                                              ),
                                                                              Icon(
                                                                                Icons.check,
                                                                                color: Colors.green,
                                                                              )
                                                                            ],
                                                                          )
                                                                        : Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: const [
                                                                              Text(
                                                                                'already exist',
                                                                                style: TextStyle(color: Colors.red),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 3,
                                                                              ),
                                                                              Icon(
                                                                                Icons.error,
                                                                                color: Colors.red,
                                                                              )
                                                                            ],
                                                                          ),
                                                                hintStyle: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            212,
                                                                            211,
                                                                            211)),
                                                                hintText:
                                                                    'Employee Code',
                                                              )),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),

                                                          TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              controller:
                                                                  _namefieldcontroller,
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintStyle: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            212,
                                                                            211,
                                                                            211)),
                                                                hintText:
                                                                    'Name',
                                                              )),
                                                          // _dataofbirth(datetime2),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          TextFormField(
                                                              onChanged:
                                                                  (value) {
                                                                context
                                                                    .read<
                                                                        CheckemailexistCubit>()
                                                                    .checkemailexist(
                                                                        value);
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              controller:
                                                                  emailcontroller,
                                                              decoration:
                                                                  InputDecoration(
                                                                suffix: emailcheck
                                                                            .isexist
                                                                            .isEmpty ||
                                                                        emailcontroller
                                                                            .value
                                                                            .text
                                                                            .isEmpty
                                                                    ? const SizedBox()
                                                                    : emailcheck.isexist ==
                                                                            'false'
                                                                        ? Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: const [
                                                                              Text(
                                                                                'available',
                                                                                style: TextStyle(color: Colors.green),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 3,
                                                                              ),
                                                                              Icon(
                                                                                Icons.check,
                                                                                color: Colors.green,
                                                                              )
                                                                            ],
                                                                          )
                                                                        : emailcheck.isexist ==
                                                                                'invalid'
                                                                            ? Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: const [
                                                                                  Text(
                                                                                    'invalid email',
                                                                                    style: TextStyle(color: Colors.red),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 3,
                                                                                  ),
                                                                                  Icon(
                                                                                    Icons.error,
                                                                                    color: Colors.red,
                                                                                  )
                                                                                ],
                                                                              )
                                                                            : Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: const [
                                                                                  Text(
                                                                                    'already exist',
                                                                                    style: TextStyle(color: Colors.red),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 3,
                                                                                  ),
                                                                                  Icon(
                                                                                    Icons.error,
                                                                                    color: Colors.red,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                hintStyle: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            212,
                                                                            211,
                                                                            211)),
                                                                hintText:
                                                                    'Email',
                                                              )),
                                                          _dataofbirth(
                                                              datetime2),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              controller:
                                                                  numbercontroller,
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintStyle: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            212,
                                                                            211,
                                                                            211)),
                                                                hintText:
                                                                    'Phone Number',
                                                              )),

                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          _dataofbirth(
                                                              datetime2),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          const Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                                'Employee Type :'),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    RadioListTile(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  title: const Text(
                                                                      'Employee'),
                                                                  value: 1,
                                                                  groupValue:
                                                                      _selectedRadioTile,
                                                                  onChanged:
                                                                      (val) {
                                                                    print(
                                                                        'Selected value: $val');
                                                                    log(val
                                                                        .toString());
                                                                    setState(
                                                                        () {
                                                                      _selectedRadioTile =
                                                                          val;
                                                                    });
                                                                  },
                                                                  activeColor:
                                                                      Colors
                                                                          .green,
                                                                  selected:
                                                                      _selectedRadioTile ==
                                                                          1,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    RadioListTile(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  title: const Text(
                                                                      'Probation Period'),
                                                                  value: 2,
                                                                  groupValue:
                                                                      _selectedRadioTile,
                                                                  onChanged:
                                                                      (val) {
                                                                    print(
                                                                        'Selected value: $val');
                                                                    setState(
                                                                        () {
                                                                      _selectedRadioTile =
                                                                          val;
                                                                    });
                                                                  },
                                                                  activeColor:
                                                                      Colors
                                                                          .green,
                                                                  selected:
                                                                      _selectedRadioTile ==
                                                                          2,
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        13),
                                                            decoration: BoxDecoration(
                                                                color: const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    240,
                                                                    237,
                                                                    237),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: Border.all(
                                                                    color: const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        225,
                                                                        222,
                                                                        222))),
                                                            child:
                                                                DropdownSearch<
                                                                    String>(
                                                              selectedItem:
                                                                  dropdownvalue1,
                                                              popupProps:
                                                                  PopupProps
                                                                      .menu(
                                                                searchFieldProps: const TextFieldProps(
                                                                    decoration: InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        constraints:
                                                                            BoxConstraints(maxHeight: 40))),
                                                                constraints:
                                                                    BoxConstraints.tight(
                                                                        const Size(
                                                                            250,
                                                                            250)),
                                                                showSearchBox:
                                                                    true,
                                                                showSelectedItems:
                                                                    true,
                                                              ),
                                                              items: designstate
                                                                  .alldesignationnamelist,
                                                              dropdownDecoratorProps:
                                                                  const DropDownDecoratorProps(
                                                                dropdownSearchDecoration:
                                                                    InputDecoration(
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  labelText:
                                                                      "Designation :",
                                                                  hintText:
                                                                      "Choose Your Designation",
                                                                ),
                                                              ),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                setState(() {
                                                                  dropdownvalue1 =
                                                                      newValue
                                                                          as String;
                                                                });

                                                                dropdownvalue11 = designstate
                                                                    .designidwithname
                                                                    .keys
                                                                    .firstWhere(
                                                                        (k) =>
                                                                            designstate.designidwithname[k] ==
                                                                            dropdownvalue1,
                                                                        orElse: () =>
                                                                            null);
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        13),
                                                            decoration: BoxDecoration(
                                                                color: const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    240,
                                                                    237,
                                                                    237),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: Border.all(
                                                                    color: const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        225,
                                                                        222,
                                                                        222))),
                                                            child:
                                                                DropdownSearch<
                                                                    String>(
                                                              selectedItem:
                                                                  dropdownvalue2,
                                                              popupProps:
                                                                  PopupProps
                                                                      .menu(
                                                                searchFieldProps: const TextFieldProps(
                                                                    decoration: InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        constraints:
                                                                            BoxConstraints(maxHeight: 40))),
                                                                constraints:
                                                                    BoxConstraints.tight(
                                                                        const Size(
                                                                            250,
                                                                            250)),
                                                                showSearchBox:
                                                                    true,
                                                                showSelectedItems:
                                                                    true,
                                                              ),
                                                              items: deptstate
                                                                  .alldeptnamelist,
                                                              dropdownDecoratorProps:
                                                                  const DropDownDecoratorProps(
                                                                dropdownSearchDecoration:
                                                                    InputDecoration(
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  labelText:
                                                                      "Department :",
                                                                  hintText:
                                                                      "Choose Your Department",
                                                                ),
                                                              ),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                setState(() {
                                                                  dropdownvalue2 =
                                                                      newValue
                                                                          as String;
                                                                });

                                                                dropdownvalue22 = deptstate
                                                                    .deptidwithname
                                                                    .keys
                                                                    .firstWhere(
                                                                        (k) =>
                                                                            deptstate.deptidwithname[k] ==
                                                                            dropdownvalue2,
                                                                        orElse: () =>
                                                                            null);
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        13),
                                                            decoration: BoxDecoration(
                                                                color: const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    240,
                                                                    237,
                                                                    237),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: Border.all(
                                                                    color: const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        225,
                                                                        222,
                                                                        222))),
                                                            child:
                                                                DropdownSearch<
                                                                    String>(
                                                              selectedItem:
                                                                  dropdownvalue3,
                                                              popupProps:
                                                                  PopupProps
                                                                      .menu(
                                                                searchFieldProps: const TextFieldProps(
                                                                    decoration: InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        constraints:
                                                                            BoxConstraints(maxHeight: 40))),
                                                                constraints:
                                                                    BoxConstraints.tight(
                                                                        const Size(
                                                                            250,
                                                                            250)),
                                                                showSearchBox:
                                                                    true,
                                                                showSelectedItems:
                                                                    true,
                                                              ),
                                                              items: rolestate
                                                                  .allrolenamelist,
                                                              dropdownDecoratorProps:
                                                                  const DropDownDecoratorProps(
                                                                dropdownSearchDecoration:
                                                                    InputDecoration(
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  labelText:
                                                                      "Role :",
                                                                  hintText:
                                                                      "Choose Your Role",
                                                                ),
                                                              ),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                setState(() {
                                                                  dropdownvalue3 =
                                                                      newValue
                                                                          as String;
                                                                });
                                                                dropdownvalue33 =
                                                                    rolestate
                                                                            .rolenamewithid[
                                                                        dropdownvalue3];
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        13),
                                                            decoration: BoxDecoration(
                                                                color: const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    240,
                                                                    237,
                                                                    237),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: Border.all(
                                                                    color: const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        225,
                                                                        222,
                                                                        222))),
                                                            child:
                                                                DropdownSearch<
                                                                    String>(
                                                              selectedItem:
                                                                  dropdownvalue4,
                                                              popupProps:
                                                                  PopupProps
                                                                      .menu(
                                                                searchFieldProps: const TextFieldProps(
                                                                    decoration: InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        constraints:
                                                                            BoxConstraints(maxHeight: 40))),
                                                                constraints:
                                                                    BoxConstraints.tight(
                                                                        const Size(
                                                                            250,
                                                                            250)),
                                                                showSearchBox:
                                                                    true,
                                                                showSelectedItems:
                                                                    true,
                                                              ),
                                                              items: branchstate
                                                                  .allbranchnamelist,
                                                              dropdownDecoratorProps:
                                                                  const DropDownDecoratorProps(
                                                                dropdownSearchDecoration:
                                                                    InputDecoration(
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  labelText:
                                                                      "Branch :",
                                                                  hintText:
                                                                      "Choose Your Branch",
                                                                ),
                                                              ),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                setState(() {
                                                                  dropdownvalue4 =
                                                                      newValue
                                                                          as String;
                                                                });
                                                                dropdownvalue44 = branchstate
                                                                    .branchidwithname
                                                                    .keys
                                                                    .firstWhere(
                                                                        (k) =>
                                                                            branchstate.branchidwithname[k] ==
                                                                            dropdownvalue4,
                                                                        orElse: () =>
                                                                            null);
                                                                log(dropdownvalue44!
                                                                    .toString());
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
              child: const Icon(Icons.edit))),
        );
      }
    }
  }

  String? dropdownvalue1;
  int? dropdownvalue11;
  int? dropdownvalue22;
  String? dropdownvalue2;
  String? dropdownvalue3;
  int? dropdownvalue33;
  String? dropdownvalue4;
  int? dropdownvalue44;

  final TextEditingController empcode = TextEditingController();
  final TextEditingController _namefieldcontroller = TextEditingController();

  final TextEditingController usernamecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController numbercontroller = TextEditingController();

  final TextEditingController _namefieldcontroller2 = TextEditingController();

  String datetime = '';

  String datetime2 = '';
  String datetime3 = '';
  String datetime4 = '';

  var format = DateFormat("dd-MM-yyyy");

  List<String> all_desid = [];
  List<String> all_depid = [];
  List<String> all_des = [];
  List<String> all_dep = [];
  List<String> all_role = [];
  List<String> all_roleid = [];

  @override
  void dispose() {
    _namefieldcontroller.dispose();
    _namefieldcontroller2.dispose();
    super.dispose();
  }

  @override
  int del_statuscode = 0;
  int update_statuscode = 0;
  int create_statuscode = 0;

  String? latitude;
  String? longitude;
  String? finallocation;

  String profileimage = '';

  Position? _position;

  bool clicked = false;
  Container conta = Container(
    child: const Text(
      'No Location Data',
    ),
  );

  getdel_status() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      del_statuscode = prefs.getInt('emp_deletecode')!;
    });
    if (del_statuscode == 204) {
      CustomSnackBar(context, const Text('Deleted Successfully'), Colors.green);
    } else {
      CustomSnackBar(context, const Text('Error'), Colors.red);
    }
  }

  getupdate_status() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      update_statuscode = prefs.getInt('emp_updatecode')!;
    });
    if (update_statuscode == 201 || update_statuscode == 200) {
      CustomSnackBar(
          context, const Text('Updated Employee Successfully'), Colors.green);
    } else {
      CustomSnackBar(context, const Text('Error'), Colors.red);
    }
  }

  getcreate_status() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      create_statuscode = prefs.getInt('emp_createcode')!;
      log(create_statuscode.toString());
    });
    if (create_statuscode == 201 || create_statuscode == 200) {
      CustomSnackBar(
          context, const Text('Added Employee Successfully'), Colors.green);
    } else {
      CustomSnackBar(context, const Text('Error'), Colors.red);
    }
  }

  final GlobalKey<FormFieldState> _keydep = GlobalKey();
  final GlobalKey<FormFieldState> _keydes = GlobalKey();

  String finaltoken = '';
  DateTime? initialdate = DateTime(2023);
  Future getdata() async {
    final prefs = await SharedPreferences.getInstance();
    String tokken = prefs.getString('tokken')!;
    // final datafinal = await ServiceApi().Get_employee(token: tokken);
    // final datafinal2 = await ServiceApi().Get_designation(token: tokken);
    // final datafinal3 = await ServiceApi().Get_department(token: tokken);
    setState(() {
      // newlist = datafinal!;
      // newlist2 = datafinal2!;
      // newlist3 = datafinal3!;
      finaltoken = tokken;
    });
    // for (var element in newlist2) {
    //   all_desid.add(element.id.toString());
    // }
    // for (var element in newlist3) {
    //   all_depid.add(element.id.toString());
    // }
    // for (var element in newlist2) {
    //   all_des.add(element.name.toString());
    // }
    // for (var element in newlist3) {
    //   all_dep.add(element.name.toString());
    // }
    log(all_dep.toString());
    log(all_des.toString());
  }

  Future getdata2() async {
    final prefs = await SharedPreferences.getInstance();
    String tokken = prefs.getString('tokken')!;
    // final datafinal = await ServiceApi().Get_employee(token: tokken);
    // final datafinal2 = await ServiceApi().Get_designation(token: tokken);
    // final datafinal3 = await ServiceApi().Get_department(token: tokken);
    setState(() {
      // newlist = datafinal!;
      // newlist2 = datafinal2!;
      // newlist3 = datafinal3!;
      finaltoken = tokken;
    });

    log(all_dep.toString());
    log(all_des.toString());
  }

  List<DataCell> displayedDataCell = [];

  int index = 1;
  @override
  Widget build(BuildContext context) {
    String size = MediaQuery.of(context).size.width.toString();
    var branch = context.watch<GetallbranchCubit>();
    var dept = context.watch<GetAlldeptCubit>();
    var design = context.watch<GetAlldesignCubit>();
    var role = context.watch<GetRoleCubit>();

    // var branchidwithname = branch.state.branchidwithname;
    // var deptname = dept.state.deptidwithname;
    // var designidwithname = design.state.designidwithname;
    var roleidwithname = role.state.rolenamewithid;

    // All name that should be used for dropdown
    var alldesignationname = design.state.alldesignationnamelist;
    var alldeptname = dept.state.alldeptnamelist;
    var allbranchname = branch.state.allbranchnamelist;
    var allrolename = role.state.allrolenamelist;

    return BlocConsumer<UpdateemployeeCubit, UpdateEmployeeStatus>(
      listener: (context, updatestatus) {
        switch (updatestatus) {
          case UpdateEmployeeStatus.initial:
            break;
          case UpdateEmployeeStatus.loading:
            EasyLoading.show(status: 'Updating Employee..');
            break;
          case UpdateEmployeeStatus.loaded:
            EasyLoading.showToast('Updated Successfully').whenComplete(() {
              displayedDataCell.clear();
              context.read<GetallbranchCubit>().getallbranch();
              context.read<GetAlldeptCubit>().getalldept();
              context.read<GetAlldesignCubit>().getalldesign();
              context
                  .read<GetemployeelistCubit>()
                  .getemployeelist(datalimit: datalimit, ismoredata: true);
            });

            break;
          case UpdateEmployeeStatus.error:
            EasyLoading.showError('Error');
            break;
        }
      },
      builder: (context, updatestatus) {
        return BlocConsumer<CheckEmpcodeCubit, CheckEmpcodeState>(
          listener: (context, checkempState) {
            log('From Build${checkempState.isexist}');
          },
          builder: (context, checkempState) {
            log('From Build2 ${checkempState.isexist}');
            return BlocConsumer<GetallbranchCubit, GetallbranchState>(
              listener: (context, allbranchState) {},
              builder: (context, allbranchState) {
                return BlocConsumer<GetAlldeptCubit, GetAlldeptState>(
                  listener: (context, alldeptState) {},
                  builder: (context, alldeptState) {
                    return BlocConsumer<GetAlldesignCubit, GetAlldesignState>(
                      listener: (context, alldesignstate) {},
                      builder: (context, alldesignstate) {
                        return BlocConsumer<GetemployeelistCubit, PostState>(
                            listener: (context, state) {
                          if (state is PostErrorState) {
                            SnackBar snackBar = SnackBar(
                              content: Text(state.error),
                              backgroundColor: Colors.red,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else if (state is PostinitialState) {
                          } else if (state is PostLoadingState) {
                          } else if (state is PostLoadedState) {
                            log('All Branch :${allbranchState.branchidwithname}');
                            log('All Dept :${alldeptState.deptidwithname}');
                            log('All Design :${alldesignstate.designidwithname}');
                            ismoreloading = state.isloading;
                            fetchdata(
                                allemplist: state.allemployeelist,
                                branchidwithname:
                                    allbranchState.branchidwithname,
                                deptnamewithid: alldeptState.deptidwithname,
                                designidwithname:
                                    alldesignstate.designidwithname);
                          }
                        }, builder: (context, state) {
                          return BlocConsumer<CreateEmployeeCubit,
                              CreateEmployeeStatus>(
                            listener: (context, state) {
                              switch (state) {
                                case CreateEmployeeStatus.initial:
                                  break;
                                case CreateEmployeeStatus.loading:
                                  EasyLoading.show(status: 'Adding Employee..');
                                  break;
                                case CreateEmployeeStatus.loaded:
                                  EasyLoading.showToast('Added Successfully')
                                      .whenComplete(() {
                                    displayedDataCell.clear();
                                    context
                                        .read<GetallbranchCubit>()
                                        .getallbranch();
                                    context
                                        .read<GetAlldeptCubit>()
                                        .getalldept();
                                    context
                                        .read<GetAlldesignCubit>()
                                        .getalldesign();
                                    context
                                        .read<GetemployeelistCubit>()
                                        .getemployeelist(
                                            datalimit: datalimit,
                                            ismoredata: true);
                                  });

                                  break;
                                case CreateEmployeeStatus.error:
                                  EasyLoading.showError('Error');
                                  break;
                              }
                            },
                            builder: (context, state) {
                              log(checkempState.isexist);
                              return Scaffold(
                                backgroundColor:
                                    const Color.fromARGB(255, 245, 245, 245),
                                // appBar: AppBar(
                                //   backgroundColor: const Color.fromARGB(255, 249, 119, 109),
                                //   title: const Text(
                                //     'Globizs Emp Leave Management Admin',
                                //   ),
                                // ),
                                body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Center(
                                      //   child: Column(
                                      //     crossAxisAlignment: CrossAxisAlignment.center,
                                      //     children: [
                                      //       Image.asset(
                                      //         'assets/images/G.png',
                                      //         height: 70,
                                      //       ),
                                      //       const Text(
                                      //         'Leave Management System',
                                      //         style: TextStyle(fontSize: 20),
                                      //       ),
                                      //       const SizedBox(
                                      //         height: 5,
                                      //       ),
                                      //       const Text(
                                      //         'Admin Panel',
                                      //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),

                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Padding(
                                        padding:
                                            MediaQuery.of(context).size.width >
                                                    1040
                                                ? const EdgeInsets.only(
                                                    left: 100,
                                                  )
                                                : const EdgeInsets.only(
                                                    left: 10,
                                                  ),
                                        child: const Text(
                                          'Employee ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            MediaQuery.of(context).size.width >
                                                    1040
                                                ? const EdgeInsets.only(
                                                    left: 100, top: 15)
                                                : const EdgeInsets.only(
                                                    left: 10, top: 15),
                                        child: InkWell(
                                            onTap: () {
                                              _namefieldcontroller.clear();
                                              usernamecontroller.clear();
                                              emailcontroller.clear();
                                              numbercontroller.clear();
                                              empcode.clear();
                                              setState(() {
                                                datetime2 = '';
                                              });
                                              dropdownvalue1 = null;
                                              dropdownvalue2 = null;
                                              dropdownvalue3 = null;
                                              dropdownvalue4 = null;
                                              showDialog(
                                                context: context,
                                                builder: (cnt) {
                                                  log('From Showdialog :${checkempState.isexist}');
                                                  return BlocConsumer<
                                                      CheckemailexistCubit,
                                                      CheckemailexistState>(
                                                    listener:
                                                        (context, emailcheck) {
                                                      // TODO: implement listener
                                                    },
                                                    builder:
                                                        (context, emailcheck) {
                                                      return BlocConsumer<
                                                          CheckEmpcodeCubit,
                                                          CheckEmpcodeState>(
                                                        listener: (context,
                                                            checkempStatefinal) {
                                                          // TODO: implement listener
                                                        },
                                                        builder: (context,
                                                            checkempStatefinal) {
                                                          return StatefulBuilder(
                                                              builder: (BuildContext
                                                                      context,
                                                                  void Function(
                                                                          void
                                                                              Function())
                                                                      setState) {
                                                            return AlertDialog(
                                                              actions: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          setState(
                                                                              () {
                                                                            _namefieldcontroller.clear();
                                                                            datetime2 =
                                                                                '';

                                                                            dropdownvalue1 =
                                                                                null;
                                                                            dropdownvalue2 =
                                                                                null;
                                                                            _position =
                                                                                null;
                                                                          });
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          "Cancel",
                                                                          style:
                                                                              TextStyle(color: Colors.blueGrey),
                                                                        )),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10),
                                                                      child: InkWell(
                                                                          onTap: () {
                                                                            if (_namefieldcontroller.text.isEmpty || empcode.text.isEmpty || emailcontroller.text.isEmpty || empcode.text.isEmpty
                                                                                // dropdownvalue11 == null ||
                                                                                // dropdownvalue22 == null ||
                                                                                // dropdownvalue33==null
                                                                                ) {
                                                                              CustomSnackBar(
                                                                                  context,
                                                                                  const Text(
                                                                                    'All Fields Are Mandatory',
                                                                                  ),
                                                                                  Colors.red);
                                                                            } else {
                                                                              context.read<CreateEmployeeCubit>().createemployee(empname: _namefieldcontroller.text, empusername: usernamecontroller.text, email: emailcontroller.text, empcode: int.parse(empcode.text), phonenumber: numbercontroller.text, deptid: dropdownvalue22!, designid: dropdownvalue11!, branchid: dropdownvalue44!, roleid: dropdownvalue33!, dateofjoining: datetime, emptype: _selectedRadioTile.toString());
                                                                              // await ServiceApi()
                                                                              //     .create_employee(
                                                                              //         name: _namefieldcontroller.text,
                                                                              //         desId: dropdownvalue11!,
                                                                              //         depId: dropdownvalue22!,
                                                                              //         dob: datetime,
                                                                              //         token: finaltoken,
                                                                              //         image: profileimage,
                                                                              //         location: finallocation!)
                                                                              //     .whenComplete(() {
                                                                              //   getdata2().whenComplete(() {
                                                                              //     _namefieldcontroller.clear();
                                                                              //     all_desid = [];
                                                                              //     all_depid = [];
                                                                              //     all_dep = [];
                                                                              //     all_des = [];
                                                                              //     _position = null;
                                                                              //     datetime2 = '';

                                                                              //     dropdownvalue1 = null;
                                                                              //     dropdownvalue2 = null;
                                                                              //     setState(() {});

                                                                              //     getcreate_status();
                                                                              //     getdata();
                                                                              EasyLoading.dismiss();
                                                                              context.router.pop();
                                                                              //   });
                                                                              // });

                                                                              // allemployee.add({
                                                                              //   'name': _namefieldcontroller.text,
                                                                              //   'branch': "Imphal West",
                                                                              //   "role": "Developer",
                                                                              //   "department": "Production"
                                                                              // });
                                                                              // log(create_statuscode.toString());
                                                                              // //     getcreate_status();
                                                                              // getdata();
                                                                              // EasyLoading.dismiss();
                                                                              // _namefieldcontroller.clear();
                                                                              // emailcontroller.clear();
                                                                              // numbercontroller.clear();
                                                                              // empcode.clear();
                                                                              // Navigator.of(context).pop();
                                                                            }
                                                                          },
                                                                          child: Material(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(13),
                                                                            ),
                                                                            elevation:
                                                                                15,
                                                                            child: const CardWidget(
                                                                                color: Colors.green,
                                                                                width: 70,
                                                                                height: 30,
                                                                                borderRadius: 5,
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    'Add',
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                                )),
                                                                          )),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                              title: const Text(
                                                                "Add new Employee",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: Form(
                                                                  child:
                                                                      SizedBox(
                                                                    width: 300,
                                                                    height: 652,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        TextFormField(
                                                                            onChanged:
                                                                                (value) {
                                                                              context.read<CheckEmpcodeCubit>().checkempcode(value);
                                                                            },
                                                                            keyboardType: TextInputType
                                                                                .number,
                                                                            controller:
                                                                                empcode,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              suffix: checkempStatefinal.isexist.isEmpty || empcode.value.text.isEmpty
                                                                                  ? const SizedBox()
                                                                                  : checkempStatefinal.isexist == 'false'
                                                                                      ? Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                                          children: const [
                                                                                            Text(
                                                                                              'available',
                                                                                              style: TextStyle(color: Colors.green),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 3,
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.check,
                                                                                              color: Colors.green,
                                                                                            )
                                                                                          ],
                                                                                        )
                                                                                      : Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                                          children: const [
                                                                                            Text(
                                                                                              'already exist',
                                                                                              style: TextStyle(color: Colors.red),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 3,
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.error,
                                                                                              color: Colors.red,
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                              hintStyle: const TextStyle(fontSize: 15, color: Color.fromARGB(255, 212, 211, 211)),
                                                                              hintText: 'Employee Code',
                                                                            )),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        TextFormField(
                                                                            keyboardType: TextInputType
                                                                                .text,
                                                                            controller:
                                                                                usernamecontroller,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              hintStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 212, 211, 211)),
                                                                              hintText: 'Username',
                                                                            )),
                                                                        // _dataofbirth(datetime2),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        TextFormField(
                                                                            keyboardType: TextInputType
                                                                                .text,
                                                                            controller:
                                                                                _namefieldcontroller,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              hintStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 212, 211, 211)),
                                                                              hintText: 'Name',
                                                                            )),
                                                                        // _dataofbirth(datetime2),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        TextFormField(
                                                                            onChanged:
                                                                                (value) {
                                                                              context.read<CheckemailexistCubit>().checkemailexist(value);
                                                                            },
                                                                            keyboardType: TextInputType
                                                                                .text,
                                                                            controller:
                                                                                emailcontroller,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              suffix: emailcheck.isexist.isEmpty || emailcontroller.value.text.isEmpty
                                                                                  ? const SizedBox()
                                                                                  : emailcheck.isexist == 'false'
                                                                                      ? Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                                          children: const [
                                                                                            Text(
                                                                                              'available',
                                                                                              style: TextStyle(color: Colors.green),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 3,
                                                                                            ),
                                                                                            Icon(
                                                                                              Icons.check,
                                                                                              color: Colors.green,
                                                                                            )
                                                                                          ],
                                                                                        )
                                                                                      : emailcheck.isexist == 'invalid'
                                                                                          ? Row(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                                              children: const [
                                                                                                Text(
                                                                                                  'invalid email',
                                                                                                  style: TextStyle(color: Colors.red),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 3,
                                                                                                ),
                                                                                                Icon(
                                                                                                  Icons.error,
                                                                                                  color: Colors.red,
                                                                                                )
                                                                                              ],
                                                                                            )
                                                                                          : Row(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                                              children: const [
                                                                                                Text(
                                                                                                  'already exist',
                                                                                                  style: TextStyle(color: Colors.red),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 3,
                                                                                                ),
                                                                                                Icon(
                                                                                                  Icons.error,
                                                                                                  color: Colors.red,
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                              hintStyle: const TextStyle(fontSize: 15, color: Color.fromARGB(255, 212, 211, 211)),
                                                                              hintText: 'Email',
                                                                            )),
                                                                        // _dataofbirth(datetime2),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        TextFormField(
                                                                            keyboardType: TextInputType
                                                                                .text,
                                                                            controller:
                                                                                numbercontroller,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              hintStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 212, 211, 211)),
                                                                              hintText: 'Phone Number',
                                                                            )),

                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        _dataofbirth(
                                                                            datetime2),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        const Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Text('Employee Type :'),
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: RadioListTile(
                                                                                contentPadding: EdgeInsets.zero,
                                                                                title: const Text('Employee'),
                                                                                value: 1,
                                                                                groupValue: _selectedRadioTile,
                                                                                onChanged: (val) {
                                                                                  print('Selected value: $val');
                                                                                  log(val.toString());
                                                                                  setState(() {
                                                                                    _selectedRadioTile = val;
                                                                                  });
                                                                                },
                                                                                activeColor: Colors.green,
                                                                                selected: _selectedRadioTile == 1,
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: RadioListTile(
                                                                                contentPadding: EdgeInsets.zero,
                                                                                title: const Text('Probation Period'),
                                                                                value: 2,
                                                                                groupValue: _selectedRadioTile,
                                                                                onChanged: (val) {
                                                                                  print('Selected value: $val');
                                                                                  setState(() {
                                                                                    _selectedRadioTile = val;
                                                                                  });
                                                                                },
                                                                                activeColor: Colors.green,
                                                                                selected: _selectedRadioTile == 2,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        Container(
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 13),
                                                                          decoration: BoxDecoration(
                                                                              color: const Color.fromARGB(255, 240, 237, 237),
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              border: Border.all(color: const Color.fromARGB(255, 225, 222, 222))),
                                                                          child:
                                                                              DropdownSearch<String>(
                                                                            popupProps:
                                                                                PopupProps.menu(
                                                                              searchFieldProps: const TextFieldProps(decoration: InputDecoration(border: OutlineInputBorder(), constraints: BoxConstraints(maxHeight: 40))),
                                                                              constraints: BoxConstraints.tight(const Size(250, 250)),
                                                                              showSearchBox: true,
                                                                              showSelectedItems: true,
                                                                            ),
                                                                            items:
                                                                                alldesignationname,
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration: InputDecoration(
                                                                                hintStyle: TextStyle(
                                                                                  fontSize: 15,
                                                                                ),
                                                                                border: InputBorder.none,
                                                                                labelText: "Designation :",
                                                                                hintText: "Choose Your Designation",
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                dropdownvalue1 = newValue as String;
                                                                              });

                                                                              dropdownvalue11 = alldesignstate.designidwithname.keys.firstWhere((k) => alldesignstate.designidwithname[k] == dropdownvalue1, orElse: () => null);
                                                                            },
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 13),
                                                                          decoration: BoxDecoration(
                                                                              color: const Color.fromARGB(255, 240, 237, 237),
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              border: Border.all(color: const Color.fromARGB(255, 225, 222, 222))),
                                                                          child:
                                                                              DropdownSearch<String>(
                                                                            popupProps:
                                                                                PopupProps.menu(
                                                                              searchFieldProps: const TextFieldProps(decoration: InputDecoration(border: OutlineInputBorder(), constraints: BoxConstraints(maxHeight: 40))),
                                                                              constraints: BoxConstraints.tight(const Size(250, 250)),
                                                                              showSearchBox: true,
                                                                              showSelectedItems: true,
                                                                            ),
                                                                            items:
                                                                                alldeptname,
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration: InputDecoration(
                                                                                hintStyle: TextStyle(
                                                                                  fontSize: 15,
                                                                                ),
                                                                                border: InputBorder.none,
                                                                                labelText: "Department :",
                                                                                hintText: "Choose Your Department",
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                dropdownvalue2 = newValue as String;
                                                                              });

                                                                              dropdownvalue22 = alldeptState.deptidwithname.keys.firstWhere((k) => alldeptState.deptidwithname[k] == dropdownvalue2, orElse: () => null);
                                                                            },
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 13),
                                                                          decoration: BoxDecoration(
                                                                              color: const Color.fromARGB(255, 240, 237, 237),
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              border: Border.all(color: const Color.fromARGB(255, 225, 222, 222))),
                                                                          child:
                                                                              DropdownSearch<String>(
                                                                            popupProps:
                                                                                PopupProps.menu(
                                                                              searchFieldProps: const TextFieldProps(decoration: InputDecoration(border: OutlineInputBorder(), constraints: BoxConstraints(maxHeight: 40))),
                                                                              constraints: BoxConstraints.tight(const Size(250, 250)),
                                                                              showSearchBox: true,
                                                                              showSelectedItems: true,
                                                                            ),
                                                                            items:
                                                                                allrolename,
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration: InputDecoration(
                                                                                hintStyle: TextStyle(
                                                                                  fontSize: 15,
                                                                                ),
                                                                                border: InputBorder.none,
                                                                                labelText: "Role :",
                                                                                hintText: "Choose Your Role",
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                dropdownvalue3 = newValue as String;
                                                                              });
                                                                              dropdownvalue33 = roleidwithname[dropdownvalue3];
                                                                            },
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 13),
                                                                          decoration: BoxDecoration(
                                                                              color: const Color.fromARGB(255, 240, 237, 237),
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              border: Border.all(color: const Color.fromARGB(255, 225, 222, 222))),
                                                                          child:
                                                                              DropdownSearch<String>(
                                                                            popupProps:
                                                                                PopupProps.menu(
                                                                              searchFieldProps: const TextFieldProps(decoration: InputDecoration(border: OutlineInputBorder(), constraints: BoxConstraints(maxHeight: 40))),
                                                                              constraints: BoxConstraints.tight(const Size(250, 250)),
                                                                              showSearchBox: true,
                                                                              showSelectedItems: true,
                                                                            ),
                                                                            items:
                                                                                allbranchname,
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration: InputDecoration(
                                                                                hintStyle: TextStyle(
                                                                                  fontSize: 15,
                                                                                ),
                                                                                border: InputBorder.none,
                                                                                labelText: "Branch :",
                                                                                hintText: "Choose Your Branch",
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                dropdownvalue4 = newValue as String;
                                                                              });
                                                                              dropdownvalue44 = allbranchState.branchidwithname.keys.firstWhere((k) => allbranchState.branchidwithname[k] == dropdownvalue4, orElse: () => null);
                                                                              log(dropdownvalue44!.toString());
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Material(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                              elevation: 15,
                                              child: const CardWidget(
                                                  gradient: [
                                                    Color.fromARGB(
                                                        255, 211, 32, 39),
                                                    Color.fromARGB(
                                                        255, 164, 92, 95)
                                                  ],
                                                  width: 120,
                                                  height: 40,
                                                  borderRadius: 13,
                                                  child: Center(
                                                    child: Text(
                                                      'Add Employee',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )),
                                            )),
                                      ),

                              Expanded(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding:
                                        MediaQuery.of(context).size.width > 1040
                                            ? const EdgeInsets.only(
                                                left: 100, right: 100, top: 20)
                                            : const EdgeInsets.only(
                                                left: 10, right: 10, top: 20),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: DataTable2(
                                        fixedTopRows: 1,
                                        dividerThickness: 2,
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                                Colors.grey.withOpacity(0.2)),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  blurRadius: 4,
                                                  spreadRadius: 3,
                                                  offset: const Offset(0, 3))
                                            ]),
                                        headingTextStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        rows: <DataRow>[
                                          for (int i = 0;
                                              i < displayedDataCell.length;
                                              i += 7)
                                            DataRow(cells: [
                                              displayedDataCell[i],
                                              displayedDataCell[i + 1],
                                              displayedDataCell[i + 2],
                                              displayedDataCell[i + 3],
                                              displayedDataCell[i + 4],
                                              displayedDataCell[i + 5],
                                              displayedDataCell[i + 6]
                                            ])
                                        ],
                                        columns: const <DataColumn>[
                                          DataColumn(
                                            label: Text(
                                              'Sl.no',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              overflow: TextOverflow.ellipsis,
                                              'Employee Name',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Designation',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Department',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Role',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Branch',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Action',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                            ]),
                      );
                    },
                  );
                });
              },
            );
          },
        );
      },
    );
  }
}

// class Employee {
//   /// Creates the employee class with required details.
//   Employee(this.id, this.name, this.designation, this.role, this.button);

//   /// Id of an employee.
//   final int id;

//   /// Name of an employee.
//   final String name;

//   /// Designation of an employee.
//   final String designation;

//   /// Salary of an employee.
//   final String role;
//   final TextButton button;
// }

// /// An object to set the employee collection data source to the datagrid. This
// /// is used to map the employee data to the datagrid widget.
// class EmployeeDataSource extends DataGridSource {
//   EmployeeDataSource({required List<Employee> employees}) {
//     _employees = employees;
//     updateDataGridRows();
//   }

//   List<DataGridRow> dataGridRow = [];
//   late List<Employee> _employees;
//   Color? rowBackgroundColor;

//   void updateDataGridRows() {
//     dataGridRow = _employees
//         .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
//               DataGridCell<int>(columnName: 'sl', value: dataGridRow.id),
//               DataGridCell<String>(columnName: 'name', value: dataGridRow.name),
//               DataGridCell<String>(
//                   columnName: 'branch', value: dataGridRow.designation),
//               DataGridCell<String>(columnName: 'role', value: dataGridRow.role),
//               DataGridCell(columnName: 'action', value: dataGridRow.button),
//             ]))
//         .toList();
//   }

//   @override
//   List<DataGridRow> get rows => dataGridRow;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//       return Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Text(e.value.toString()),
//       );
//     }).toList());
//   }

//   void updateDataGridSource() {
//     notifyListeners();
//   }
// }
