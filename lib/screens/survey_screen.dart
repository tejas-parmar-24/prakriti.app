import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prakriti/screens/login_screen.dart';
import 'package:prakriti/screens/profile_screen.dart';

class SurveyScreen extends StatefulWidget {
  static const String id = 'survey_screen';

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentPageIndex = 0;

  final List<Map<String, dynamic>> _surveyQuestions = [
    {
      'question': 'शरीरिक संगठन(Body Frame)?',
      'optionsWithPoints': {
        'संकीर्ण(Narrow)': 1,
        'मध्यम(Medium)': 2,
        'चौड़ा(Wide)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'शरीर संहनन(Body Bulk)?',
      'optionsWithPoints': {
        'कमजोर विकसित(Weakly Developed)': 1,
        'मध्यम रूप से विकसित(Moderately Developed)': 2,
        'अच्छी तरह से विकसित(Well Developed)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'शारीरिक संहनन (मांसपेशीय)Body Build (Musculature)?',
      'optionsWithPoints': {
        'पतली मांसलता(Thin Musculature)': 1,
        'नरम और ढीले ढंग से मांसलता(Soft and Loosely Knitted Musculature)': 2,
        'स्निग्ध और मजबूती से मांसलता(Smooth and Firmly Knitted Musculature)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'माथे की लंबाई(Forehead Length)?',
      'optionsWithPoints': {
        'छोटा(Small)': 1,
        'मध्यम(Medium)': 2,
        'विशाल(Large)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'नाखून बनावट(Nails Texture)?',
      'optionsWithPoints': {
        'खुरदुरा(Rough)': 1,
        'कोमल(Soft)': 2,
        'चिकना(Smooth)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'नाखुनो का रंग(Nails Colour)?',
      'optionsWithPoints': {
        'पीला(Pale)': 1,
        'लाल(Reddish)': 2,
        'गुलाबी(Pink)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'उंगली के नाखुन का आकार(Finger Nail Size)?',
      'optionsWithPoints': {
        'छोटा(Small)': 1,
        'मध्यम(Medium)': 2,
        'बडा(Large)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'त्वचा की उपस्थिति(Skin Appearance)?',
      'optionsWithPoints': {
        'फटा(Cracked), खुरदुरा(Rough), झुर्रियां(Wrinkles)': 1,
        'तिल और मस्से(Moles), निशान(Marks), चहरे पर दाने(Pimples), झाईयां(Freckles)':
            2,
        'शोभायमान(Lustrous), कोई नहीं (None)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': true,
    },
    {
      'question': 'त्वचा का रंग/आभा(Skin Colour/Complexion)?',
      'optionsWithPoints': {
        'गहरा सांवला(Dark), काला(Dusky)': 1,
        'लाल रंग के साथ गोरा(Fair with reddishtinge), पीले रंग के साथ गोरा(Fair with yellowishtinge), गेहुआ रंग(Wheatish)':
            2,
        'गोरा(Fair)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'त्वचा की प्रकृति(Skin Nature)?',
      'optionsWithPoints': {
        'सूखी(Dry)': 1,
        'मौसमी(Seasonal-Oily + Pimple)': 2,
        'तेलीय(Oily and Clear)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'त्वचा की बनावट(Skin Texture)?',
      'optionsWithPoints': {
        'पतला(Thin)': 1,
        'सुकुमार(Delicate)': 2,
        'मोटा(Thick)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'बालों की बनावट(Hair Texture), बालों की प्रकृति(Hair Nature)?',
      'optionsWithPoints': {
        'पतला(Thin), विरल(Sparse), गिरने वाले(Breaking), सिरों पर विभाजित(Splitatends)':
            1,
        'मध्यम(Moderate), जल्दी गिरने वाले(Falling), जल्दी पकने वाले(Graying)':
            2,
        'मोटा(Thick), घुँघराले(Curly), घना(Dense)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': true,
    },
    {
      'question': 'बालों की प्रकृति(Hair Nature)?',
      'optionsWithPoints': {
        'सूखा(Dry)': 1,
        'मौसमी(Seasonal), सामान्य (Normal)': 2,
        'तेलीय(Oily)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'क्या आप देखते हैं कि आपके पास है?(Do you observe you have?)?',
      'optionsWithPoints': {
        'Nails(नाखून): भंगुर(Brittle), Palm(हथेली): फटा(Cracked), Sole(सोल): क्रैक्ड(Cracked), Lips(होंठ): क्रैक्ड(Cracked)':
            1,
        'Nails(नाखून): गैर भंगुर(Non-Brittle), Palm(हथेली): गैर-फटा(Non-cracked), Sole(सोल): नॉन-क्रैक्ड(Non-cracked), Lips(होंठ): नॉन-क्रैक्ड(Non-cracked)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपकी भूख कैसी है?(नियमितता)(How is your appetite?(Regularity, Frequency, Amount))?',
      'optionsWithPoints': {
        'अनियमित(Irregular),अक्सर सही(Frequent), (Variable)': 1,
        'नियमित(Regular), अक्सर सही(Frequent), (More)': 2,
        'नियमित(Regular), कभी कभी सही(Infrequent), (Less)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'स्वाद वरीयता(Taste Preference)?',
      'optionsWithPoints': {
        'खट्टा(Sour), नमकीन(Salty)': 1,
        'तीखा(Pungent), कसैला(Astringent)': 2,
        'मीठा(Sweet), कड़वा(Bitter)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': true,
    },
    {
      'question':
          'क्या आप अपने द्वारा खाए गए भोजन की मात्रा को पचा पा रहे हैं?(Are you able to digest the amount of food consumed by you?)',
      'optionsWithPoints': {
        'हमेशा कठिनाई से, नहीं कह सकता(Always with difficulty, Cannot say)': 1,
        'हमेशा हाँ(Always yes)': 2,
        'यदि अधिक मात्रा में लिया जाता है तो अपच का कारण बनता है अन्यथा हाँ(If excess is taken causes in digestion other wise yes)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'क्या आप वसा से भरपूर भोजन लेना पसंद करते हैं जैसे(Do you prefer to take food rich in fats like)?',
      'optionsWithPoints': {
        'तैलीय वस्तु(oily articles)': 1,
        'मक्खनँ(Butter), घी(Ghee)': 2,
        'कोई भी नहीं(None)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': true,
    },
    {
      'question':
          'क्या आपके शरीर का तापमान सामान्य रहता है?(Does your body temperature in general remains ?)',
      'optionsWithPoints': {
        'बदलता रहता है(Variable)': 1,
        'दूसरों की तुलना में अधिक(Higher compared to others)': 2,
        'दूसरों की तुलना में कमं(Lower compared to others), औसत (Average)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपके पसीने के बारे में कैसे है?(How about your Perspiration?)',
      'optionsWithPoints': {
        'बदलता रहता है(Variable)': 1,
        'विपुल(Profuse)': 2,
        'कम(Less), संतुलित (Moderate)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'आपकी नींद कैसी है?(राशि)(How about your sleep ?(amount))',
      'optionsWithPoints': {
        'कम नींद (Less Sleep)(<6घंटे/hrs)': 1,
        'मध्यम नींद(Moderate sleep(6-8घंटे/hrs))': 2,
        'भारी नींद (Heavy sleep(>8घंटे/hrs))': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'क्या आपको बिस्तर पर जाने के तुरंत बाद नींद आती है?(Do you get sleep immediately after going to bed ?)',
      'optionsWithPoints': {
        'नहीं, सो जाने में लंबा समय लगता है(No it takes long time to fall asleep)':
            1,
        'कुछ मिनटों के बाद/पढ़ना आदि करना।(After few minutes/doing reading etc)':
            2,
        'हाँ (Yes)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'नींद की गुणवत्ता(Quality of Sleep)?',
      'optionsWithPoints': {
        'उथली(Shallow)': 1,
        'मध्यम / ध्वनि।(Moderate/Sound)': 2,
        'गहरा(Deep)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपकी शौच प्रवृत्तीआदतों के बारे में कैसे है ?(How about your bowel habits?)',
      'optionsWithPoints': {
        'अनियमित(Irregular)': 1,
        'नियमित(Regular)': 2,
        'कभी कभी अनियमित(Occasionally Irregular)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'शौच के प्रति आपकी प्रवृत्ती केसी है? (अधिकतर)(Do you tend to have ?)',
      'optionsWithPoints': {
        'कब्ज(Constipation)': 1,
        'पतले दस्त(Loose motions)': 2,
        'कोई भी नहीं(None)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'मल प्रवृत्ती कैसी होती है अधिकतर(Stool Consistency)?',
      'optionsWithPoints': {
        'सख्त(Hard)': 1,
        'ढीला(Loose)': 2,
        'मध्यम(Medium)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपके शरीर के वजन में परिवर्तन के बारे में आप कैसे?(How about changes in your body weight ?)',
      'optionsWithPoints': {
        'वजन बढ़ाने में कठिनाई(Difficulty in gaining weight)': 1,
        'स्थिर(Stable)': 2,
        'आसानी से वजन बढ़ाएं लेकिन कठिनाई से कम हो(Gain weight easily but loose with difficulty)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'क्या आपके शरीर से दुर्गंध आती है?(Do you have body odor ?)',
      'optionsWithPoints': {
        'बहुत हल्का(Very Mild)': 1,
        'बहुत अधिक(Strong)': 2,
        'हल्का(Mild)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आप कौन सा मौसम पसंद करते हैं?(Which weather do you prefer ?)',
      'optionsWithPoints': {
        'गरम(Warm)': 1,
        'ठंडा(Cold)': 2,
        'मौसमी परिवर्तन का समय(Seasonal Transition)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपको किस मौसम में स्वास्थ्य समस्याएं होती हैं?(In which weather do you have health problems ?)',
      'optionsWithPoints': {
        'ठंडा(Cold - Pain etc)': 1,
        'गरम(Warm)': 2,
        'ठंडा(Cold- Respiratory)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आप कितनी बार बीमार पड़ते हैं?(How frequently do you fall ill?)',
      'optionsWithPoints': {
        'बार-बार(Frequently)': 1,
        'मध्यम(Moderately)': 2,
        'कभी-कभार(Rarely)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'यदि आप बीमार पड़ते हैं तो क्या आप आसानी से ठीक हो जाते हैं?(If you fall ill do you get cured easily?)',
      'optionsWithPoints': {
        'नहीं, ठीक होने में लंबा समय और मेहनत लगती है(No, it takes long time & effort to get cured)':
            1,
        'मध्यम प्रयासों की आवश्यकता है जैसे आहार, आराम और दवा(Moderate efforts needed like diet, rest & medicine)':
            2,
        'हाँ, ज्यादातर अपने आप पर(Yes, mostly on its own)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'बोलने की मात्रा(Amount of speaking)?',
      'optionsWithPoints': {
        'अत्यधिक(Excessive)': 1,
        'संतुलित(Moderate)': 2,
        'कम(Less)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'आवाज की गुणवत्ता(Quality of voice)?',
      'optionsWithPoints': {
        'टूटी हुई(Broken), खुरदरी(Rough), ऊंची ऊंची(High pitched), हकलाना/तोत्लना(Stammering)':
            1,
        'अच्छा टोंड(Good Toned), तीखा(Sharp), साफ़(Clear), चीख कर(Loud)': 2,
        'कम(Low), धीरे(Feeble), बहुत धीरे(Weak), गहरा(Deep), कोमल(Soft), मनभावन(Pleasing)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'बोलने की गति/शैली(Speed/Style of Speaking)?',
      'optionsWithPoints': {
        'झटपट(Quick)': 1,
        'ऊमध्यम(Medium)': 2,
        'धीमा(Slow)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'स्वैच्छिक और अनैच्छिक गतियां(Voluntary and Involuntary Movements)?- हाथ की गति(Hand), टाँगों की गति(Leg), आइब्रो मूवमेंट(Eyebrow), कंधे की गति(Shoulder)-समग्र आंदोलन(Overall)',
      'optionsWithPoints': {
        'उच्च(High/Excessive)': 1,
        'मध्यम(Moderate)': 2,
        'अत्यधिक कम(Less)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'मानसिक शक्ति(Mental Strength)?',
      'optionsWithPoints': {
        'बार-बार तनावग्रस्त / परेशान होना और दूसरों द्वारा समझा दिया जा सकता है(Get stressed/disturbed frequently and can be counselled by others)':
            1,
        'आसानी से तनाव में आ जाते हैं और दूसरों द्वारा आसानी से सलाह नहीं दी जा सकती(Get stressed easily and cannot be counseled easily by others)':
            2,
        'कठिनाई से तनाव में आएं और स्वयं पर काबू पा सकते हैं(Get stressed difficulty and cannot be counseled easily by others)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आप कितनी बार थकान महसूस करते हैं?(How frequently you feel tired?)',
      'optionsWithPoints': {
        'नियमित कार्य के दौरान(On During routine work)': 1,
        'भारी मेहनत के बाद भी नहीं(Not even after heavy work)': 2,
        'अतिरिक्त काम/भारी काम करने के बादं(After doing extra work / heavy work)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आप कितनी जल्दी चीजों को याद कर सकते हैं?(How quickly you can memorize things?)',
      'optionsWithPoints': {
        'तुरंत(Quickly)': 1,
        'मध्यम(Moderately)': 2,
        'धीरे से(Slowly)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'आप कितने भुलक्कड़ हैं?(How forget ful you are?)',
      'optionsWithPoints': {
        'तुरंत(Quickly)': 1,
        'मध्यम(Moderately)': 2,
        'धीरे से(Slowly)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपकी मेमोरी रिटेंशन पावर कैसी है?(How is your memory retention power?)',
      'optionsWithPoints': {
        'बहुत कम(Poor)': 1,
        'मध्यम(Medium)': 2,
        'अच्छा(Good)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'क्या आप है एक…(Are you a…)?',
      'optionsWithPoints': {
        'दिनचर्या और बदलाव के साथ प्रयोग करना पसंद है(Loving to experiment with routines and change them very readily)':
            1,
        'नियमित और दैनिक पर्यवेक्षक(Regular and routine observer)': 2,
        'सहज और मध्यम नियमित पर्यवेक्षक(Spontaneous and moderate routine observer)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'क्या आपको पसंद है?(Do you like to ?)',
      'optionsWithPoints': {
        'घूमें और लोगों से बातचीत करें और एक्सप्लोर करें(Move around and interact with people and explore)':
            1,
        'मध्यम रूप से घूमें और बहुत लंबे समय तक न बैठें(Move around moderately and not sit for very long hours)':
            2,
        'बैठे रहें और अपने काम तक ही सीमित रहें(Beseated and keep confined to own work)':
            3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'Prakriti assessment of the individual by doctor',
      'optionsWithPoints': {
        'Vpk': 0,
        'Vkp': 0,
        'Pvk': 0,
        'Pkv': 0,
        'Kvp': 0,
        'Kpv': 0,
        'VPK': 0,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
  ];

  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize _isNextButtonEnabled based on the initial state of the first question
    _updateNextButtonState();
  }

  void _nextQuestion() {
    if (_currentPageIndex < 0 || _currentPageIndex >= _surveyQuestions.length) {
      // Ensure that the current page index is within valid bounds
      return;
    }

    final question = _surveyQuestions[_currentPageIndex];
    final selectedOptions = question['selectedOptions'];

    if (question.containsKey('allowMultipleSelection') &&
        question['allowMultipleSelection'] == true) {
      if (selectedOptions == null || selectedOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one option.'),
          ),
        );
        return;
      }
    } else {
      if (selectedOptions == null ||
          selectedOptions.isEmpty ||
          selectedOptions.length > 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select one option.'),
          ),
        );
        return;
      }
    }

    if (_currentPageIndex < _surveyQuestions.length - 1) {
      setState(() {
        _currentPageIndex++;
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
        _updateNextButtonState();
      });
    } else {
      _saveResponsesToFirebase(context);
    }
  }

  void _previousQuestion() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
        _pageController.previousPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
        _updateNextButtonState();
      });
    }
  }

  void _clearSelection() {
    setState(() {
      final question = _surveyQuestions[_currentPageIndex];
      question['selectedOptions'] = [];
    });
    _updateNextButtonState();
  }

  void _updateNextButtonState() {
    final question = _surveyQuestions[_currentPageIndex];
    final selectedOptions = question['selectedOptions'];
    final allowMultipleSelection = question['allowMultipleSelection'] ?? false;

    bool isButtonEnabled = false;

    if (allowMultipleSelection) {
      isButtonEnabled = selectedOptions.isNotEmpty;
    } else {
      isButtonEnabled = selectedOptions.length == 1;
    }

    setState(() {
      _isNextButtonEnabled = isButtonEnabled;
    });
  }

  void _saveResponsesToFirebase(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If the user is not signed in, return or handle the scenario accordingly
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return;
      }

      // Create a new map to store selected options and their points
      final Map<String, int> selectedOptionsWithPoints = {};

      for (final question in _surveyQuestions) {
        for (final selectedOption in question['selectedOptions']) {
          final option = selectedOption;
          final points = question['optionsWithPoints'][option];
          selectedOptionsWithPoints[option] = points;
        }
      }

      final userResponses = <Map<String, dynamic>>[];

      Map<String, int> optionCounts = {
        'Vata': 0,
        'Pitta': 0,
        'Kapha': 0,
        'NA': 0
      };

      for (final question in _surveyQuestions) {
        final questionResponse = {
          'question': question['question'],
        };

        if (question['selectedOptions'].isNotEmpty) {
          questionResponse['selectedOptions'] = <Map<String, dynamic>>[];
        }

        for (final selectedOption in question['selectedOptions']) {
          final option = selectedOption;
          final points = question['optionsWithPoints'][option];
          final optionResponse = {
            'option': option,
            'points': points,
          };

          final optionType = _getOptionFromPoints(optionResponse['points']);

          if (optionCounts.containsKey(optionType)) {
            if (optionType != 'NA')
              optionCounts[optionType] = (optionCounts[optionType] ?? 0) + 1;
          }

          if (question['selectedOptions'].isNotEmpty) {
            questionResponse['selectedOptions'].add(optionResponse);
          }
        }

        userResponses.add(questionResponse);
      }

      final totalPoints =
          optionCounts.values.reduce((sum, count) => sum + count);

      final prakritiDistribution = _calculatePrakritiDistribution(optionCounts);

      final userSurveyRef =
          _firestore.collection('users-survey-v02').doc(user.uid);

      // Check if the user document exists, and create it if not
      if (!(await userSurveyRef.get()).exists) {
        await userSurveyRef.set({
          'responses': userResponses,
          'surveyCompleted': true,
        });
      } else {
        // Update the surveyCompleted field for the current user
        await userSurveyRef.update({'surveyCompleted': true});
      }

      final userResponsesRef = userSurveyRef.collection('user-responses').doc();
      final userResponsesResult =
          userSurveyRef.collection('user-survey-result').doc();

      // Save user responses in the "user-responses" collection
      await userResponsesRef.set({
        'responses': userResponses,
      });

      await userResponsesResult.set({
        'totalPoints': totalPoints,
        'prakritiDistribution': prakritiDistribution,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ThankYouScreen()),
      );
    } catch (e) {
      print('Error saving responses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView.builder(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _surveyQuestions.length,
          itemBuilder: (context, index) {
            final question = _surveyQuestions[index];
            final questionText = question['question'];
            final optionsWithPoints = question['optionsWithPoints'];
            final allowMultipleSelection =
                question['allowMultipleSelection'] ?? false;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                key: ValueKey<int>(index),
                children: [
                  Card(
                    elevation: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            questionText,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Column(
                            children: optionsWithPoints.keys.map<Widget>(
                              (option) {
                                return allowMultipleSelection
                                    ? CheckboxListTile(
                                        title: Text(
                                          '$option (${optionsWithPoints[option]})',
                                        ),
                                        value:
                                            (question['selectedOptions'] ?? [])
                                                .contains(option),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value!) {
                                              question['selectedOptions']
                                                  .add(option);
                                            } else {
                                              question['selectedOptions']
                                                  .remove(option);
                                            }
                                            _updateNextButtonState();
                                          });
                                        },
                                      )
                                    : RadioListTile<String>(
                                        title: Text(
                                          '$option (${optionsWithPoints[option]})',
                                        ),
                                        value: option,
                                        groupValue: question['selectedOptions']
                                                .isNotEmpty
                                            ? question['selectedOptions'][0]
                                            : null,
                                        onChanged: (value) {
                                          setState(() {
                                            question['selectedOptions'] = [
                                              value!
                                            ];
                                            _updateNextButtonState();
                                          });
                                        },
                                      );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < _surveyQuestions.length - 1)
                    Divider(
                      thickness: 2.0,
                      height: 32.0,
                    ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPageIndex > 0)
                ElevatedButton.icon(
                  onPressed: _previousQuestion,
                  icon: Icon(Icons.navigate_before),
                  label: Text('Previous'),
                ),
              ElevatedButton.icon(
                onPressed: _clearSelection,
                icon: Icon(Icons.clear),
                label: Text('Clear'),
              ),
              ElevatedButton.icon(
                onPressed: _isNextButtonEnabled ? _nextQuestion : null,
                icon: Icon(Icons.navigate_next),
                label: Text(
                  _currentPageIndex < _surveyQuestions.length - 1
                      ? 'Next'
                      : 'Submit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculatePrakritiDistribution(
      Map<String, int> optionCounts) {
    final totalPoints = optionCounts.values.reduce((sum, count) => sum + count);

    final prakritiDistribution = {
      'Vata': (optionCounts['Vata']! / totalPoints) * 100.0,
      'Pitta': (optionCounts['Pitta']! / totalPoints) * 100.0,
      'Kapha': (optionCounts['Kapha']! / totalPoints) * 100.0,
      // 'NA': (optionCounts['NA']! / totalPoints) * 100.0,
    };

    return prakritiDistribution;
  }

  String _getOptionFromPoints(int points) {
    switch (points) {
      case 1:
        return 'Vata';
      case 2:
        return 'Pitta';
      case 3:
        return 'Kapha';
      case 4:
        return 'NA';
      default:
        return 'Other';
    }
  }
}

class ThankYouScreen extends StatefulWidget {
  @override
  _ThankYouScreenState createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  final _noteController = TextEditingController();
  String _userNote = "";

  void _saveNote() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userSurveyRef =
        FirebaseFirestore.instance.collection('users-survey-v02').doc(user.uid);

    final noteText =
        _noteController.text.trim(); // Trim any leading or trailing spaces

    if (noteText.isEmpty) {
      // Optionally, you can show a message to the user that the note is empty
      return;
    }

    final userResponsesRef = userSurveyRef.collection('note').doc();

    setState(() {
      _userNote = noteText;
    });

    await userResponsesRef.set({
      'note': _userNote,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thank You'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Thank you for completing the survey!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),

            // Note input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Add a Note',
              ),
            ),

            SizedBox(height: 16),

            // Save note button
            ElevatedButton(
              onPressed: _saveNote,
              child: Text('Save Note'),
            ),

            SizedBox(height: 16),

            // Display saved note
            Text('User Note: $_userNote', style: TextStyle(fontSize: 16)),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileHomeScreen(
                              user: FirebaseAuth.instance.currentUser,
                            )));
              },
              child: Text('Back to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
