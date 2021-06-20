import 'package:flutter/material.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';
import '../models/Reward.dart';

class UserRewardsScreen extends StatelessWidget {
  //Constants
  static const routeName = '/User-Rewards-Screen';
  final rewardsinfo = [
    Reward(
        title: "تعبئة معلومات الحساب الشخصي",
        description: "إضافة معلومات الحساب الشخصي تزيد من نقاطك بشكل جيّد",
        points: 100),
    Reward(
        title: "قراءة 5 كتب",
        description:
            "لكلّ 5 كتب تتم قراءتها ستضاف كمية أكبر من النقاط إلى الحساب",
        points: 300),
    Reward(
        title: "قراءة كتاب واحد",
        description: "تحصل على عدد جيّد من النقاط عند إتمام قراءة كتاب واحد",
        points: 55),
    Reward(
        title: "إنشاء 4 مجموعات للقراءة",
        description: "عدد كبير من مجموعات القراءة يعني العديد من النقاط",
        points: 100),
    Reward(
        title: "إنشاء غرفة قراءة واحدة",
        description: "أنشئ غرفة قراءة منفردة لإكتساب بعض النقاط الإضافية",
        points: 20),
    Reward(
        title: "إضافة 5 مستخدمين للمعارف",
        description: "تزداد النقاط المضافة إلى حسابك بإزدياد معارفك",
        points: 100),
    Reward(
        title: "إضافة مستخدم إلى المعارف",
        description:
            "كونك إجتماعياً وتضيف المعارف يجعلك مستحقاً لمجموعة من النقاط",
        points: 15),
    Reward(
        title: "دعوة مستخدم إلى مجموعة",
        description:
            "إرسال دعوة لمستخدم للمشاركة في غرفة قراءة يضيف بعض النقاط إلى الحساب",
        points: 20),
    Reward(
        title: "مراجعة كتاب واحد",
        description: "أضف رأيك في كتاب لتحصل على بضعة نقاط",
        points: 6),
    Reward(
        title: "مراجعة 10 كتب",
        description: "تعليقك على 10 كتب يعني حصولك على المزيد من النقاط",
        points: 75),
    Reward(
        title: "تفضيل أو تقييم كتاب واحد",
        description:
            "القليل من النقاط تضاف إليك في حال تقييمك أو تفضيلك لكتاب ",
        points: 3),
    Reward(
        title: "تفضيل أو تقييم 10 كتب",
        description: "زيادة نقاط الحساب عن طريق تقييم الكتب أو تعيينها ك مفضلة",
        points: 35),
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              CustomPageLabel("قائمة المكافئات"),
              Expanded(
                  child: ListView.builder(
                itemCount: rewardsinfo.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    color: Colors.white,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  "https://ignitewoo.com/wp-content/uploads/2012/08/woocommerce-loyalty-rewards.png"),
                            ),
                            title: Text(
                              rewardsinfo[index].title,
                              style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              rewardsinfo[index].description,
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    rewardsinfo[index].points.toString(),
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "نقطة",
                                    style: TextStyle(color: theme.primaryColor),
                                  )
                                ]),
                          )),
                    ),
                  );
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
