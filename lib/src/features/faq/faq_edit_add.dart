import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/my_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/questions_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/questions_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FaqEditAdd extends StatefulWidget {
  const FaqEditAdd({super.key, this.uid, this.questionid});
  final String? uid;
  final String? questionid;

  @override
  State<FaqEditAdd> createState() => _FaqEditAddState();
}

class _FaqEditAddState extends State<FaqEditAdd> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;

  //Services
  DatabaseService db = DatabaseService();
  QuestionsService qs = QuestionsService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  //Variables
  bool isLoading = false;
  UserDetails user = UserDetails();
  Future<UserDetails>? getUserFuture;
  Future<List<QuestionsModel>>? getQuestionFuture;
  List<QuestionsModel> questionList = [];
  Future<QuestionsModel>? getCurrentQuestion;
  QuestionsModel currentQuestion = QuestionsModel();
  String? expandedFaqId;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  TextEditingController referenceController = TextEditingController();
  List<int> questionsRef = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    fetchAllQuestions();

    if (widget.questionid != null) {
      getCurrentQuestion = fetchCurrentQuestion();
    }
    snackbarWidget.context = context;
    super.initState();
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: MyText(
              text: appLoc!.faq,
              fontScale: responsive!.scaleFont(20),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: Stack(
            children: [
              _buildListofQuestionsBody(),
              isLoading
                  ? const Center(
                      child: AnimatedArcLoader(),
                    )
                  : const SizedBox.shrink()
            ],
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
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
              questionList = questionshot.data ?? [];
              return _buildQuestionList();
            }
          }),
    );
  }

  Widget _buildQuestionList() {
    return Padding(
      padding: responsive!.responsivePaddingES,
      child: SizedBox(
          height: responsive!.screenHeight * 0.85,
          child: FutureBuilder(
              future: getCurrentQuestion,
              builder: (context, questionshot) {
                if (questionshot.hasError) {
                  return Center(
                    child: MyText(
                      text: errorClass.questionNotLoading(
                        e: questionshot.error.toString(),
                      ),
                    ),
                  );
                } else if (questionshot.connectionState ==
                    ConnectionState.waiting) {
                  return const GradientSkeleton();
                }

                return Column(
                  children: [
                    //Question Controller
                    SizedBox(
                      height: responsive!.scaleHeight(120),
                      child: MyTextField(
                        controller: questionController,
                        hintText: appLoc!.question,
                        capitalize: TextCapitalization.sentences,
                        lines: 4,
                      ),
                    ),
                    //Answer Controller
                    SizedBox(
                      height: responsive!.scaleHeight(210),
                      child: MyTextField(
                        controller: answerController,
                        hintText: appLoc!.answer,
                        capitalize: TextCapitalization.sentences,
                        lines: 9,
                      ),
                    ),
                    MyTextField(
                      controller: referenceController,
                      hintText: appLoc!.referenceOrder,
                      isNumberKeyboard: true,
                    ),
                    GestureDetector(
                        onTap: () {
                          widget.questionid != null
                              ? updateQuestion()
                              : addQuestion();
                        },
                        child: MyButton(
                            text: widget.questionid != null
                                ? appLoc!.update
                                : appLoc!.add))
                  ],
                );
              })),
    );
  }

  Future<QuestionsModel> fetchCurrentQuestion() async {
    var result = await qs.futureSingleQuestion(questionId: widget.questionid);
    questionController.text = result.questions!;
    answerController.text = result.answer!;
    referenceController.text = result.ref.toString();

    return result;
  }

  Future<void> fetchAllQuestions() async {
    var result = await qs.getAllQuestions();

    if (result.isNotEmpty) {
      for (var question in result) {
        if (question.ref != null && !questionsRef.contains(question.ref)) {
          questionsRef.add(question.ref!);
        }
      }
    }
  }

  //Add new question
  Future<void> addQuestion() async {
    if (questionController.text.isEmpty) {
      snackbarWidget.content = appLoc!.questionIsEmpty;
      snackbarWidget.showSnack();
      return;
    }

    if (answerController.text.isEmpty) {
      snackbarWidget.content = appLoc!.answerIsEmpty;
      snackbarWidget.showSnack();
      return;
    }

    if (referenceController.text.isEmpty) {
      snackbarWidget.content = appLoc!.referenceIsEmpty;
      snackbarWidget.showSnack();
      return;
    }

    if (questionsRef.contains(int.tryParse(referenceController.text))) {
      snackbarWidget.content = appLoc!.referenceOrderExits;
      snackbarWidget.showSnack();
      return;
    }
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    QuestionsModel question = QuestionsModel(
        questions: questionController.text,
        answer: answerController.text,
        ref: int.tryParse(referenceController.text),
        createdAt: DateTime.now(),
        enabled: true);

    await qs.createQuestion(question);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
      GoRouter.of(context).pop();
    }
  }

  //update current question
  Future<void> updateQuestion() async {
    if (questionController.text.isEmpty) {
      snackbarWidget.content = appLoc!.questionIsEmpty;
      snackbarWidget.showSnack();
      return;
    }

    if (answerController.text.isEmpty) {
      snackbarWidget.content = appLoc!.answerIsEmpty;
      snackbarWidget.showSnack();
      return;
    }

    if (referenceController.text.isEmpty) {
      snackbarWidget.content = appLoc!.referenceIsEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    QuestionsModel question = QuestionsModel(
        uid: widget.questionid,
        questions: questionController.text,
        answer: answerController.text,
        ref: int.tryParse(referenceController.text),
        createdAt: DateTime.now(),
        enabled: true);

    await qs.updateQuestion(widget.questionid!, question);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
      GoRouter.of(context).pop();
    }
  }
}
