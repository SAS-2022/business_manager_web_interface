import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/questions_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/questions_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key, this.uid});
  final String? uid;

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;

  //Services
  DatabaseService db = DatabaseService();
  QuestionsService qs = QuestionsService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  //Variables
  bool isLoading = false, settingTutorial = true;
  UserDetails user = UserDetails();
  Future<UserDetails>? getUserFuture;
  Future<List<QuestionsModel>>? getQuestionFuture;
  List<QuestionsModel> questionList = [];
  String? expandedFaqId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    if (widget.uid != null) {
      //fetch user
      getUserFuture = fetchUser();
    }
    getQuestionFuture = qs.getAllQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: getUserFuture,
          builder: (context, usershot) {
            if (usershot.hasError) {
              return Scaffold(
                body: Center(
                  child: MyText(
                      text: errorClass.userNoTFoundError(
                          e: usershot.error.toString())),
                ),
              );
            } else if (usershot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: GradientSkeleton());
            } else {
              user = usershot.data!;
              return Scaffold(
                appBar: AppBar(
                  title: MyText(
                    text: appLoc!.faq,
                    fontScale: responsive!.scaleFont(18),
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  actions: [
                    //add button
                    usershot.data != null && usershot.data!.level == 'admin'
                        ? IconButton(
                            onPressed: () {
                              GoRouter.of(context).pushNamed('faq_add',
                                  pathParameters: {'uid': widget.uid!});
                            },
                            icon: const Icon(Icons.add))
                        : const SizedBox.shrink()
                  ],
                ),
                body: _buildListofQuestionsBody(),
              );
            }
          }),
    );
  }

  Widget _buildListofQuestionsBody() {
    return Padding(
      padding: responsive!.responsivePaddingES,
      child: FutureBuilder(
          future: getQuestionFuture,
          builder: (context, questionshot) {
            if (questionshot.hasError) {
              return Center(
                child: MyText(
                    text: errorClass.questionNotLoading(
                        e: questionshot.error.toString())),
              );
            } else if (questionshot.connectionState ==
                ConnectionState.waiting) {
              return const GradientSkeleton();
            } else {
              questionList = questionshot.data!;
              return _buildQuestionList();
            }
          }),
    );
  }

  Widget _buildQuestionList() {
    return SizedBox(
      height: responsive!.screenHeight * 0.85,
      child: questionList.isNotEmpty
          ? ListView.builder(
              itemCount: questionList.length,
              itemBuilder: (context, index) {
                final faq = questionList[index];
                final isExpanded = expandedFaqId == faq.uid;
                return buildFaqTile(faq, isExpanded);
              })
          : Center(
              child: MyText(text: appLoc!.questionEmpty),
            ),
    );
  }

  Widget buildFaqTile(QuestionsModel faq, bool isExpanded) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive!.scaleHeight(12)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive!.scaleWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Header (always visible)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  // Toggle expansion
                  if (isExpanded) {
                    expandedFaqId = null;
                  } else {
                    expandedFaqId = faq.uid;
                  }
                });
              },
              borderRadius: BorderRadius.circular(responsive!.scaleWidth(12)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: responsive!.scaleHeight(16),
                  horizontal: responsive!.scaleWidth(16),
                ),
                child: Row(
                  children: [
                    // Expand/Collapse Icon
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isExpanded ? 0.5 : 0.0,
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.white,
                        size: responsive!.scaleFont(24),
                      ),
                    ),
                    SizedBox(width: responsive!.scaleWidth(12)),
                    // Question Text
                    Expanded(
                      child: MyText(
                        text: faq.questions!,
                        fontScale: responsive!.scaleFont(16),
                        fontWeight: FontWeight.w600,
                        maxLines: isExpanded ? null : 2,
                        textOverflow: TextOverflow.ellipsis,
                        fontColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: responsive!.scaleWidth(6)),
                    user.level == 'admin'
                        ? GestureDetector(
                            onTap: () {
                              GoRouter.of(context).pushNamed('faq_edit',
                                  pathParameters: {
                                    'uid': widget.uid!,
                                    'questionId': faq.uid!
                                  });
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
          // Answer Container (animated)
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(16),
                      vertical: responsive!.scaleHeight(16),
                    ),
                    height: _setContainerHeight(faq.answer),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(responsive!.scaleWidth(12)),
                        bottomRight:
                            Radius.circular(responsive!.scaleWidth(12)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Divider line
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.grey.withValues(alpha: 0.3),
                          margin: EdgeInsets.only(
                            bottom: responsive!.scaleHeight(12),
                          ),
                        ),
                        // Answer text
                        Expanded(
                          child: MyText(
                            text: faq.answer!,
                            fontScale: responsive!.scaleFont(15),
                            optimalSizeEnabled: false,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid!);

    return result;
  }

  double? _setContainerHeight(String? text) {
    return ((text ?? '').length / 7) * 6;
  }
}
