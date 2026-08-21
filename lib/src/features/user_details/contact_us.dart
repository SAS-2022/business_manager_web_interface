import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/dynamic_dropdown.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/models/contactus_model.dart';
import 'package:business_manager_web_ui/src/services/contact_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Screenshot attachment picking rewritten for web the same way as Gallery
/// (Stage 5) and Account Settings' logo upload: mobile's FilePickerService
/// (dart:io Platform branching) + flutter_image_compress replaced with
/// `ImagePicker().pickMultiImage()` + direct `Uint8List` upload via
/// `StorageService.uploadImageToStorage`. `images` changed from
/// `List<dynamic>` (holding dart:io `File`s) to `List<XFile>`, previewed
/// via `Image.network(xfile.path)` — on web, XFile.path is a blob: URL
/// Image.network renders directly.
class ContactUs extends StatefulWidget {
  const ContactUs({super.key, this.uid});
  final String? uid;

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  SnackbarWidget snackbar = SnackbarWidget();
  ContactService cs = ContactService();
  StorageService ss = StorageService();
  final ImagePicker imagePicker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  bool isLoading = false, messageSent = false;
  List<dynamic> subjectOptions = [];
  List<XFile> images = [];
  String? selectedOption;
  ContactusModel contactUs = ContactusModel();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    subjectOptions = [appLoc!.technical, appLoc!.complaint, appLoc!.suggestion];
    snackbar.context = context;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: MyText(
        text: text.toUpperCase(),
        fontScale: responsive!.scaleFont(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _groupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _fieldRow(
      {required IconData icon,
      required Widget child,
      CrossAxisAlignment crossAxis = CrossAxisAlignment.center}) {
    return Row(
      crossAxisAlignment: crossAxis,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: responsive!.scaleWidth(14),
            top: crossAxis == CrossAxisAlignment.start
                ? responsive!.scaleHeight(14)
                : 0,
          ),
          child: Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: appLoc!.contactUs,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
          ),
          body: Stack(
            children: [
              messageSent ? _buildMessageSentBody() : _buildContactUsBody(),
              if (isLoading) const Center(child: AnimatedArcLoader()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Contact form ───────────────────────────────────────────────────────────

  Widget _buildContactUsBody() {
    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sender details ────────────────────────────────────────────
          _sectionLabel(appLoc!.senderDetails),
          _groupCard(children: [
            _fieldRow(
              icon: Icons.person_outline_rounded,
              child: FlushTextField(
                controller: nameController,
                hintText: appLoc!.name,
                textCapitalization: TextCapitalization.words,
                fontSize: responsive!.scaleFont(13),
              ),
            ),
            _fieldRow(
              icon: Icons.mail_outline_rounded,
              child: FlushTextField(
                controller: emailController,
                hintText: appLoc!.emailAddress,
                keyboardType: TextInputType.emailAddress,
                fontSize: responsive!.scaleFont(13),
              ),
            ),
          ]),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Subject ───────────────────────────────────────────────────
          _sectionLabel(appLoc!.subject),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
                  child: Icon(
                    Icons.topic_outlined,
                    size: responsive!.scaleHeight(18),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: responsive!.scaleWidth(8)),
                    child: DynamicDropdown(
                      items: subjectOptions,
                      selectedValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) selectedOption = value;
                        });
                      },
                      appLoc: appLoc,
                      responsive: responsive,
                      hint: appLoc!.subject,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Message ───────────────────────────────────────────────────
          _sectionLabel(appLoc!.messageContent),
          _groupCard(children: [
            _fieldRow(
              icon: Icons.chat_bubble_outline_rounded,
              child: FlushTextField(
                controller: messageController,
                hintText: appLoc!.messageContent,
                textCapitalization: TextCapitalization.sentences,
                fontSize: responsive!.scaleFont(13),
                lines: 5,
              ),
              crossAxis: CrossAxisAlignment.start,
            ),
          ]),

          // ── Screenshots (technical / complaint only) ──────────────────
          if (selectedOption == appLoc!.technical ||
              selectedOption == appLoc!.complaint) ...[
            SizedBox(height: responsive!.scaleHeight(20)),
            _sectionLabel(appLoc!.screenShots),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(responsive!.scaleWidth(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: responsive!.scaleHeight(80),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...images.asMap().entries.map((entry) {
                          final index = entry.key;
                          return Padding(
                            padding: EdgeInsets.only(
                                right: responsive!.scaleWidth(8)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                images[index].path,
                                width: responsive!.scaleHeight(80),
                                height: responsive!.scaleHeight(80),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                        // Add button
                        GestureDetector(
                          onTap: _addImage,
                          child: Container(
                            width: responsive!.scaleHeight(80),
                            height: responsive!.scaleHeight(80),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.4),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: responsive!.scaleHeight(24),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (images.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: responsive!.scaleHeight(8)),
                      child: MyText(
                        text: appLoc!.longPressToRemove,
                        fontScale: responsive!.scaleFont(11),
                      ),
                    ),
                ],
              ),
            ),
          ],

          SizedBox(height: responsive!.scaleHeight(28)),

          // ── Send button ───────────────────────────────────────────────
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(vertical: responsive!.scaleHeight(15)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: MyText(
                  text: appLoc!.send,
                  fontScale: responsive!.scaleFont(15),
                  fontWeight: FontWeight.w500,
                  fontColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(24)),
        ],
      ),
    );
  }

  // ── Success state ──────────────────────────────────────────────────────────

  Widget _buildMessageSentBody() {
    return Padding(
      padding: responsive!.responsivePaddingHorM,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: responsive!.scaleWidth(72),
            ),
            SizedBox(height: responsive!.scaleHeight(20)),
            MyText(
              text: appLoc!.messageSentSuccessfully,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
              align: TextAlign.center,
            ),
            SizedBox(height: responsive!.scaleHeight(8)),
            MyText(
              text: appLoc!.thankYouForReachingOut,
              fontScale: responsive!.scaleFont(13),
              align: TextAlign.center,
            ),
            SizedBox(height: responsive!.scaleHeight(32)),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(vertical: responsive!.scaleHeight(15)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: MyText(
                    text: appLoc!.close,
                    fontScale: responsive!.scaleFont(15),
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<void> _sendMessage() async {
    List<String> uploadedImages = [];
    if (nameController.text.isEmpty) {
      snackbar.content = appLoc!.nameRequired;
      snackbar.showSnack();
      return;
    }
    if (emailController.text.isEmpty) {
      snackbar.content = appLoc!.emailAddressRequired;
      snackbar.showSnack();
      return;
    }
    if (selectedOption == null) {
      snackbar.content = appLoc!.selectSubject;
      snackbar.showSnack();
      return;
    }
    if (messageController.text.isEmpty) {
      snackbar.content = appLoc!.messageCannotBeEmpty;
      snackbar.showSnack();
      return;
    }

    setState(() => isLoading = true);

    if (images.isNotEmpty) {
      uploadedImages = await saveImages(images);
    }

    contactUs = ContactusModel(
      name: nameController.text,
      email: emailController.text,
      subject: selectedOption,
      message: messageController.text,
      dateTime: DateTime.now(),
      status: 'new',
      images: uploadedImages,
    );

    var result = await cs.createNewMessage(contactUs);

    if (mounted) {
      setState(() {
        isLoading = false;
        messageSent = result == 'Message has been sent successfully';
      });
      snackbar.content = result;
      snackbar.time = 5;
      snackbar.showSnack();
    }
  }

  // Mobile picks via a FilePickerService that platform-branches on dart:io
  // Platform.isIOS/isAndroid — replaced here with image_picker's web
  // implementation directly, same pattern used by Gallery (Stage 5) and
  // Account Settings' logo upload.
  Future<void> _addImage() async {
    List<XFile> pickedFiles;
    try {
      pickedFiles = await imagePicker.pickMultiImage();
    } catch (error) {
      snackbar.content = error.toString();
      snackbar.showSnack();
      return;
    }
    if (pickedFiles.isNotEmpty) {
      images = pickedFiles;
      setState(() {});
    }
  }

  Future<List<String>> saveImages(List<XFile> images) async {
    List<String> uploadedImages = [];
    setState(() => isLoading = true);

    ProgressManager.startLoading(
      onTimeout: () {
        if (mounted) {
          setState(() => isLoading = false);
          snackbar.content = appLoc!.operationTimedOut;
          snackbar.showSnack();
        }
      },
      timeoutDuration: const Duration(seconds: 60),
    );

    for (var image in images) {
      final bytes = await image.readAsBytes();
      var url = await ss.uploadImageToStorage(
        bytes: bytes,
        fileName: image.name,
        folderName: '${widget.uid}/$selectedOption',
      );
      if (url.isEmpty) {
        snackbar.content = appLoc!.failedToUploadImage;
        snackbar.showSnack();
        return [];
      }
      ProgressManager.updateProgress(1.0);
      uploadedImages.add(url);
    }

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
      ProgressManager.stopLoading();
    });
    return uploadedImages;
  }
}
