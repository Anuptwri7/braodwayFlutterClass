
import 'package:flutter/material.dart';
import 'package:binarylabs/app/models/course_model.dart';
import 'package:binarylabs/app/pages/offline_page/offline_single_course_page.dart';
import 'package:binarylabs/app/widgets/main_widget/classes_widget/classes_widget.dart';
import 'package:binarylabs/common/common.dart';
import 'package:binarylabs/common/components.dart';
import 'package:binarylabs/common/database/app_database.dart';
import 'package:binarylabs/common/utils/app_text.dart';

class OfflineListCoursePage extends StatefulWidget {
  static const String pageName = '/offline-list-course';
  const OfflineListCoursePage({super.key});

  @override
  State<OfflineListCoursePage> createState() => _OfflineListCoursePageState();
}

class _OfflineListCoursePageState extends State<OfflineListCoursePage> {

  List<CourseModel> data = [];


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      data = await AppDataBase.getCoursesAtDB();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    return directionality(
      child: Scaffold(
        appBar: appbar(title: appText.myCourses),

        body: SingleChildScrollView(
          padding: padding(),
          physics: const BouncingScrollPhysics(),

          child: Column(
            children: [

              space(10),

              ...List.generate(data.length, (index) {
                return ClassessWidget.classesItem(
                  data[index],
                  onTap: (){
                    nextRoute(OfflineSingleCoursePage.pageName, arguments: data[index]);
                  }
                );
              })
              
            ],
          ),

        ),
      )
    );
  }
}