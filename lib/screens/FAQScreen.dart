import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';

class FAQScreen extends StatefulWidget {
  static const routeName = './FAQ-Screen';

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // Properties
  int selected = 0;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'ما هو خير جليس ؟',
      'answer':
          'خير جليس هو تطبيق لمساعدة القرّاء لإيجاد أشخاص للقراءة معهم وإنشاء غرف افتراضية لقراءة كتب متفق عليها وإيجاد التحفيز المطلوب لإنهاء الكتب والإستفادة منها.'
    },
    {
      'question': 'كيف يعمل نظام النقاط ؟',
      'answer':
          'تستطيع القيام ببعض الأمور (مهمّات) الموجودة في قائمة المكافآت في القائمة الرئيسية والتي تعطيك عند فعلها مجموعة من النقاط تستطيع بها شراء سمات تعجبك في معرض السمات الموجود في إعدادات حسابك الشخصي.'
    },
    {
      'question': 'هل تحميل الكتب متاح على خير جليس ؟',
      'answer':
          'تطبيق خير جليس لا يدعم تحميل الكتب على الجهاز ولكن يدعم قراءة الكتاب الواحد بداخل التطبيق دون الحاجة لتحميله.',
    },
    {
      'question': 'هل أستطيع فتح غرفتي قراءة لنفس الكتاب ؟',
      'answer':
          'نعم ، ولكن عند إتمام الكتاب في الغرفتين سيتم احتسابه مرةً واحدة في قائمة المتصدرين.',
    },
    {
      'question': 'ماذا يحصل عند إغلاق الغرفة ؟',
      'answer':
          'يمنع الوصول إلى المحادثة أو الكتاب أو صفحة الكتاب أو حتّى إلغاء الصفحة. لكن المستخدمين الذين أكملوا قراءة الكتاب سيتم احتساب الكتاب في إحصائياتهم.',
    },
    {
      'question': 'كيف تتم دعوة مستخدم إلى مجموعة ؟',
      'answer':
          'يجد المستخدم الدعوة في قائمة دعوات الإنضمام في غرف القراءة في القائمة الرئيسية ويستطيع القبول او الرفض.',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomPageLabel('الأسئلة الشائعة'),
          Container(
            height: MediaQuery.of(context).size.height * 0.80,
            child: ListView.builder(
              key: Key('builder ${selected.toString()}'),
              itemCount: questions.length,
              itemBuilder: (ctx, index) {
                final question = questions[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        width: 3,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ExpansionTile(
                      key: Key(index.toString()),
                      initiallyExpanded: index == selected,
                      onExpansionChanged: (value) {
                        setState(() {
                          selected = value ? index : -1;
                        });
                      },
                      trailing: Icon(
                        index == selected
                            ? FontAwesomeIcons.chevronUp
                            : FontAwesomeIcons.chevronDown,
                        color: Theme.of(context).primaryColor,
                      ),
                      backgroundColor: Color(0xFFFFECFF),
                      expandedAlignment: Alignment.centerRight,
                      childrenPadding:
                          EdgeInsets.only(right: 25, left: 25, bottom: 20),
                      title: Text(
                        question['question'],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      children: [
                        Text(
                          question['answer'],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
