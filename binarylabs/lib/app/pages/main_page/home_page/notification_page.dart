import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:binarylabs/app/providers/user_provider.dart';
import 'package:binarylabs/app/services/user_service/user_service.dart';
import 'package:binarylabs/app/widgets/main_widget/home_widget/notification_widget.dart';
import 'package:binarylabs/common/common.dart';
import 'package:binarylabs/common/components.dart';
import 'package:binarylabs/common/utils/app_text.dart';
import 'package:binarylabs/common/utils/date_formater.dart';
import 'package:binarylabs/config/assets.dart';
import 'package:binarylabs/config/colors.dart';
import 'package:binarylabs/config/styles.dart';
import 'package:binarylabs/locator.dart';

class NotificationPage extends StatefulWidget {
  static const String pageName = '/notification';
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  
  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        appBar: appbar(title: appText.notification),

        body: locator<UserProvider>().notification.isEmpty
      ? Center(child: emptyState(AppAssets.emptyNotificationSvg, appText.noNotifications, appText.noNotificationsDesc))
      : ListView.builder(
          padding: padding(vertical: 18),
          itemCount: locator<UserProvider>().notification.length,
          itemBuilder: (context, index) {

            return GestureDetector(
              onTap: (){

                if(locator<UserProvider>().notification[index].status != 'read'){

                  UserService.seenNotification(locator<UserProvider>().notification[index].id!);
                  
                  locator<UserProvider>().notification[index].status = 'read';
                  locator<UserProvider>().setNotification(locator<UserProvider>().notification);
                }

                NotificationWidget.showDetailsSheet(locator<UserProvider>().notification[index]);              
                
                setState(() {});
              },
              child: Container(
                width: getSize().width,
                margin: const EdgeInsets.only(bottom: 16),
                padding: padding(horizontal: 13,vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius(radius: 16)
                ),
            
                child: Row(
                  children: [
            
                    // icon
                    Container(
                      width: 65,
                      height: 65,
            
                      decoration: BoxDecoration(
                        color: green77(),
                        borderRadius: borderRadius(radius: 14)
                      ),
            
                      child: Stack(
                        children: [
            
                          Center(child: SvgPicture.asset(AppAssets.notificationSvg,width: 23,)),
            
                          if(locator<UserProvider>().notification[index].status == 'unread')...{
                            Positioned(
                              top: 18,
                              right: 20,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: red49
                                ),
                              )
                            )
                          },
            
                        ],
                      ),
                    ),
            
                    space(0, width: 10),
            
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        
                        children: [
            
                          Text(
                            locator<UserProvider>().notification[index].title ?? '',
                            style: style14Bold(),
                          ),
            
                          space(8),
                          
                          Text(
                            timeStampToDateHour((locator<UserProvider>().notification[index].createdAt ?? 0) * 1000),
                            style: style12Regular().copyWith(color: greyA5),
                          ),
                        ],
                      )
                    )
            
                  ],
                ),
              ),
            );

          },
        ),

      )
    );
  }
}