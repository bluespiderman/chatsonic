import 'dart:async';

import 'package:chat_gpt/core/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:share/share.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'chat_message_widget.dart';
import 'question_box.dart';
import 'ad.dart';
import 'chat_sonic_messaging.dart';
import 'ad_helper.dart';

const backgroundColor = Color(0xFFF5F5F5);
const botBackgroundColor = Color(0xFF0D2F74);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FocusNode _focusNode = FocusNode();

  late bool isLoading;
  late bool keyboardUp;
  late ChatSonicApi _api;
  late double questionBoxLeft;

  BannerAd? _ad1;
  BannerAd? _ad2;

  Future<InitializationStatus> _initGoogleMobileAds() {
    // COMPLETE: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  @override
  void initState() {
    super.initState();
    _api = ChatSonicApi(enableGoogleResults: true, enableMemory: false);
    isLoading = false;
    keyboardUp = false;
    questionBoxLeft = 32.0;
    _initGoogleMobileAds();

    BannerAd(
      adUnitId: AdHelper.nativeAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
      ),
    ).load();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad2 = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          // debugPrint('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(32),
        child: GFAppBar(
          backgroundColor: botBackgroundColor,
          title: const Text(
            "AI CHAT - ASK ANYTHING!",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // bottom: 16,
          actions: <Widget>[
            GFIconButton(
              icon: const Icon(
                Icons.share,
                color: Colors.white,
                size: 16,
              ),
              onPressed: () {
                Share.share('check out my website https://play.google.com/');
              },
              type: GFButtonType.transparent,
            ),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: keyboardUp ? 50 : 100,
                ),
                Expanded(child: _buildList())
              ],
            ),
            Column(children: [
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                color: const Color(0xFF7D7D7D),
                child: const Text(
                  'Banner Ad 1 (W 100% x 50)',
                  textAlign: TextAlign.center,
                ),
              ),
              Visibility(
                visible: !keyboardUp,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 50,
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black)),
                    color: Color(0xFF7D7D7D),
                  ),
                  child: const Text(
                    'Banner Ad 2 (W 100% x 50)',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ad1?.dispose();
    _ad2?.dispose();

    super.dispose();
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: botBackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length + 4,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Stack(
            alignment: const AlignmentDirectional(-1, 0),
            children: [
              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16.0, 16.0, 32.0, 0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.white),
                  child: RichText(
                    text: const TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      style: TextStyle(
                          color: Color(0xFF0D2F74),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.37),
                      children: <TextSpan>[
                        TextSpan(text: 'Hello, I’m your '),
                        TextSpan(
                            text: 'AI Assistant',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                ', ask me anything you want! I can teach you about Languages, Science, Finance, Geography, anything!'),
                      ],
                    ),
                  )),
              Container(
                  width: 14,
                  height: 14,
                  color: Colors.white,
                  transform: Matrix4.translationValues(16, 0, 0)
                    ..rotateZ(3.14 / 4))
            ],
          );
        }
        if (index == 1) {
          return Stack(
            alignment: const AlignmentDirectional(-1, 0),
            children: [
              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16.0, 16.0, 32.0, 0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Examples:",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF0D2F74),
                            height: 1.37,
                            fontSize: 16),
                      ),
                      const Text(
                        "- Explain to me Quantum Physics",
                        style: TextStyle(
                            color: Color(0xFF0D2F74),
                            height: 1.37,
                            fontSize: 16),
                      ),
                      const Text(
                        "- Conjugate the verb to be in Spanish",
                        style: TextStyle(
                            color: Color(0xFF0D2F74),
                            height: 1.37,
                            fontSize: 16),
                      ),
                      const Text(
                        "- Write me a poem about love!",
                        style: TextStyle(
                            color: Color(0xFF0D2F74),
                            height: 1.37,
                            fontSize: 16),
                      )
                    ],
                  )),
              Container(
                  width: 14,
                  height: 14,
                  color: Colors.white,
                  transform: Matrix4.translationValues(16, 0, 0)
                    ..rotateZ(3.14 / 4))
            ],
          );
        }
        if (index == _messages.length + 2) {
          return Visibility(
              visible: isLoading,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: GFLoader(
                              size: GFSize.SMALL,
                              loaderColorThree: Color(0xFF0D2F74),
                              loaderstrokeWidth: 3,
                              type: GFLoaderType.custom,
                              child: Image(
                                width: 50,
                                height: 50,
                                image: AssetImage('assets/images/spinner.gif'),
                              ),
                            ),
                          ),
                          Text(
                            "AI Typing...",
                            style: TextStyle(color: Color(0xFFB7B7B7)),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: const Text("Cancel"),
                      )
                    ],
                  )));
        }
        if (index == _messages.length + 3) {
          return Visibility(
              visible: !isLoading,
              child: GFAccordionCustom(
                titlePadding: const EdgeInsets.all(3),
                titleChild: const Text(
                  "    ASK A NEW QUESTION",
                  textAlign: TextAlign.center,
                ),
                contentChild: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints.expand(height: 160),
                        child: TextField(
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _textController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.black),
                          onTap: () {
                            setState(() {
                              keyboardUp = true;
                            });
                            Future.delayed(const Duration(milliseconds: 500))
                                .then((_) => _scrollDown());
                          },
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ))),
                margin: EdgeInsets.fromLTRB(questionBoxLeft, 16, 16, 16),
                textStyle: const TextStyle(color: Colors.black),
                contentBackgroundColor: Colors.white,
                collapsedTitleBackgroundColor: const Color(0xFF2F489E),
                expandedTitleBackgroundColor: const Color(0xFF2F489E),
                expandedIcon: const Icon(null),
                collapsedIcon: const Icon(null),
                titleBorderRadius: const BorderRadius.all(Radius.circular(5)),
                contentPadding: const EdgeInsets.all(8),
                onToggleCollapsed: (showAccordion, ok) async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _focusNode.requestFocus();
                  Future.delayed(const Duration(milliseconds: 500))
                      .then((_) => _scrollDown());
                  if (showAccordion) {
                    setState(() {
                      questionBoxLeft = 16;
                      keyboardUp = true;
                    });
                    return;
                  }
                  setState(() {
                    questionBoxLeft = 32;
                  });
                  setState(() => {keyboardUp = false});
                  if (_textController.text == "" || ok == false) return;
                  setState(
                    () {
                      _messages.add(
                        ChatMessage(
                          text: _textController.text,
                          chatMessageType: ChatMessageType.user,
                        ),
                      );
                      isLoading = true;
                    },
                  );
                  var input = _textController.text;
                  _textController.clear();
                  var newMessage = await _api.sendMessage(input);
                  if (isLoading) {
                    setState(() {
                      isLoading = false;
                      _messages.add(
                        ChatMessage(
                          text: newMessage.message,
                          chatMessageType: ChatMessageType.bot,
                        ),
                      );
                    });
                  }
                  _textController.clear();
                  Future.delayed(const Duration(milliseconds: 500))
                      .then((_) => _scrollDown());
                },
              ));
        }
        var message = _messages[index - 2];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
