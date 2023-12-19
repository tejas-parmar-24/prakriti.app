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
  final user = FirebaseAuth.instance.currentUser;
  int _currentPageIndex = 0;
  bool _doctorIdEntered = false;
  String _doctorId = '';

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
        'फटा(Cracked)': 1,
        'खुरदुरा(Rough)': 1,
        'झुर्रियां(Wrinkles)': 1,
        'तिल और मस्से(Moles)': 2,
        'निशान(Marks)': 2,
        'चहरे पर दाने(Pimples)': 2,
        'झाईयां(Freckles)': 2,
        'शोभायमान(Lustrous)': 3,
        'कोई भी नहीं(None)': 4,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'त्वचा का रंग/आभा(Skin Colour/Complexion)?',
      'optionsWithPoints': {
        'गहरा सांवला(Dark)': 1,
        'काला(Dusky)': 1,
        'लाल रंग के साथ गोरा(Fair with reddishtinge)': 2,
        'पीले रंग के साथ गोरा(Fair with yellowishtinge)': 2,
        'पीताभ रंग के साथ गोरा(Fair with paletinge)': 2,
        'गेहुआ रंग(Wheatish)': 3,
        'गुलाबी रंग के साथ गोरा(Fair with pinktinge)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'त्वचा की प्रकृति(Skin Nature)?',
      'optionsWithPoints': {
        'सूखी(Dry)': 1,
        'मौसमी(Seasonal)': 2,
        'तेलीय(Oily)': 3,
        'सामान्य (General)': 4,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'त्वचा की बनावट(Skin Texture)?',
      'optionsWithPoints': {
        'पतला(Thin)': 1,
        'मोटा(Thick)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'बालों की बनावट(Hair Texture)?',
      'optionsWithPoints': {
        'पतला(Thin)': 1,
        'मोटा(Thick)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'सर पर बाल किस प्रकार के है(Is your scalp hair prone to?(Nature))?',
      'optionsWithPoints': {
        'गिरने वाले(Breaking)': 1,
        'सिरों पर विभाजित(Splitatends)': 1,
        'दोनो(Both)': 1,
        'जल्दी गिरने वाले(Falling)': 2,
        'जल्दी पकने वाले(Graying)': 2,
        'कोई भी नहीं(None)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'बालों की प्रकृति(Hair Nature)?',
      'optionsWithPoints': {
        'सूखा(Dry)': 1,
        'मौसमी(Seasonal)': 2,
        'सामान्य (Normal)': 2,
        'तेलीय(Oily)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'क्या आप देखते हैं कि आपके पास है?(Do you observe you have?)?',
      'optionsWithPoints': {
        'Nails(नाखून): भंगुर(Brittle)': 1,
        'Palm(हथेली): फटा(Cracked)': 1,
        'Sole(सोल): क्रैक्ड(Cracked)': 1,
        'Lips(होंठ): क्रैक्ड(Cracked)': 1,
        'Nails(नाखून): गैर भंगुर(Non-Brittle)': 2,
        'Palm(हथेली): गैर-फटा(Non-cracked)': 2,
        'Sole(सोल): नॉन-क्रैक्ड(Non-cracked)': 2,
        'Lips(होंठ): नॉन-क्रैक्ड(Non-cracked)': 2,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': true,
    },
    {
      'question':
          'आपकी भूख कैसी है?(नियमितता)(How is your appetite?(Regularity))?',
      'optionsWithPoints': {
        'अनियमित(Irregular)': 1,
        'नियमित(Regular)': 2,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपकी भूख कैसी है?(फ्रीक्वेंसी)(How is your appetite?(Frequency))?',
      'optionsWithPoints': {
        'कभी कभी सही(Infrequent)': 1,
        'अक्सर सही(Frequent)': 2,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'स्वाद वरीयता(Taste Preference)?',
      'optionsWithPoints': {
        'खट्टा(Sour)': 1,
        'नमकीन(Salty)': 1,
        'मीठा(Sweet)': 2,
        'कड़वा(Bitter)': 3,
        'तीखा(Pungent)': 3,
        'कसैला(Astringent)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आप किस प्रकार का भोजन/पेय पदार्थ पसंद करते हैं?(What type of food/beverages do you prefer?)',
      'optionsWithPoints': {
        'गरम (Warm)': 1,
        'ठंडा(Cold)': 2,
        'नहीं (None)': 4,
        'कोई भी(Any)': 4,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'भूख लगने पर आप कितनी मात्रा में भोजन कर सकते हैं?(How much quantity of food can you consume on feeling hungry?)',
      'optionsWithPoints': {
        'मध्यम(Medium)': 1,
        'उच्च(High)': 2,
        'कम(Low)': 3,
        'बदलता रहता हैं(Variable)': 4,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
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
        'चीज (पनीर)(Cheese)': 1,
        'पशु चर्बी(AnimalFat)': 1,
        'तेल या तैलीय वस्तु(Oil or oily articles)': 1,
        'मक्खनँ(Butter)': 2,
        'घी(Ghee)': 2,
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
        'दूसरों की तुलना में कमं(Lower compared to others)': 3,
        'औसत (Average)': 3,
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
        'कम(Less)': 3,
        'संतुलित (Moderate)': 3,
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
        'बदलती रहती है(Variable)': 4,
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
        'कोमल(Soft)': 3,
        'अर्ध ठोस(Semi Solid)': 3,
        'मध्यम(Medium)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपके शरीर के वजन में परिवर्तन के बारे में आप कैसे?(How about changes in your body weight ?)',
      'optionsWithPoints': {
        'आसानी से वजन बढ़ाएं और आसानी से कम करें(Gain weight easily and loose easily)':
            1,
        'वजन बढ़ाने में कठिनाई(Difficulty in gaining weight)': 2,
        'आसानी से वजन बढ़ाएं लेकिन कठिनाई से कम हो(Gain weight easily but loose with difficulty)':
            3,
        'स्थिर(Stable)': 4,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question': 'क्या आपके शरीर से दुर्गंध आती है?(Do you have body odor ?)',
      'optionsWithPoints': {
        'बहुत हल्का(Very Mild)': 1,
        'हल्का(Mild)': 2,
        'बहुत अधिक(Strong)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आप कौन सा मौसम पसंद करते हैं?(Which weather do you prefer ?)',
      'optionsWithPoints': {
        'गरम(Warm)': 1,
        'सभी(All)': 3,
        'ठंडा(Cold)': 2,
        'कोई भी नहीं(None)': 4,
        'ठंडा और गर्म दोनों(Both Cold & Warm)': 4,
        'मौसमी परिवर्तन का समय(Seasonal Transition)': 4,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपको किस मौसम में स्वास्थ्य समस्याएं होती हैं?(In which weather do you have health problems ?)',
      'optionsWithPoints': {
        'ठंडा(Cold)': 1,
        'ठंडा और गर्म दोनों(Both Cold & Warm)': 1,
        'मौसमी परिवर्तन का समय(Seasonal Transition)': 1,
        'गरम(Warm)': 2,
        'सभी (All)': 4,
        'कोई भी नहीं(None)': 4,
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
        'टूटी हुई(Broken)': 1,
        'खुरदरी(Rough)': 1,
        'ऊंची ऊंची(High pitched)': 1,
        'अच्छा टोंड(Good Toned)': 2,
        'तीखा(Sharp)': 2,
        'साफ़(Clear)': 2,
        'चीख कर(Loud)': 2,
        'कम(Low)': 3,
        'धीरे(Feeble)': 3,
        'बहुत धीरे(Weak)': 3,
        'गहरा(Deep)': 3,
        'कोमल, मनभावन(Soft,Pleasing)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': true,
    },
    {
      'question': 'बोलने की गति/शैली(Speed/Style of Speaking)?',
      'optionsWithPoints': {
        'झटपट(Quick)': 1,
        'भिन्न रूप से(Variably)': 1,
        'ऊमध्यम(Medium)': 2,
        'धीमा(Slow)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'स्वैच्छिक और अनैच्छिक गतियां(Voluntary and Involuntary Movements)?',
      'optionsWithPoints': {
        'हाथ की गति(Hand Movement):उच्च(High/Excessive)': 1,
        'हाथ की गति(Hand Movement):अत्यधिक कम(Less)': 2,
        'हाथ की गति(Hand Movement):मध्यम(Moderate)': 3,
        'टाँगों की गति(Leg Movement):उच्च(High/Excessive)': 1,
        'टाँगों की गति(Leg Movement):अत्यधिक कम(Less)': 2,
        'टाँगों की गति(Leg Movement):मध्यम(Moderate)': 3,
        'आइब्रो मूवमेंट(Eyebrow Movement):उच्च(High/Excessive)': 1,
        'आइब्रो मूवमेंट(Eyebrow Movement):अत्यधिक कम(Less)': 2,
        'आइब्रो मूवमेंट(Eyebrow Movement):मध्यम(Moderate)': 3,
        'कंधे की गति(Shoulder Movement):उच्च(High/Excessive)': 1,
        'कंधे की गति(Shoulder Movement):अत्यधिक कम(Less)': 2,
        'कंधे की गति(Shoulder Movement):मध्यम(Moderate)': 3,
        'समग्र आंदोलन(Overall Movement):उच्च(High/Excessive)': 1,
        'समग्र आंदोलन(Overall Movement):अत्यधिक कम(Less)': 2,
        'समग्र आंदोलन(Overall Movement):मध्यम(Moderate)': 3,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': true,
    },
    {
      'question': 'मानसिक शक्ति(Mental Strength)?',
      'optionsWithPoints': {
        'बार-बार तनावग्रस्त / परेशान होना और दूसरों द्वारा समझा दिया जा सकता है(Get stressed/disturbed frequently and can be counselled by others)':
            1,
        'आसानी से तनाव में आ जाते हैं और दूसरों द्वारा आसानी से सलाह नहीं दी जा सकती(Get stressed easily and cannot be counseled easily by others)':
            1,
        'तनावग्रस्त / आसानी से परेशान हो जाते हैं और इसे स्वयं / कुछ समय के साथ दूर कर लेते हैं(Get stressed/disturbed easily and over come it by own / with sometime)':
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
        'भिन्न रूप से(variably)': 4,
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
        'भिन्न रूप से(variably)': 1,
      },
      'selectedOptions': <String>[],
      'allowMultipleSelection': false,
    },
    {
      'question':
          'आपकी मेमोरी रिटेंशन पावर कैसी है?(How is your memory retention power?)',
      'optionsWithPoints': {
        'बहुत कम(Poor)': 1,
        'बदलती रहती है(Variable)': 1,
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
  ];

  bool _isNextButtonEnabled = false;
  @override
  void initState() {
    super.initState();
    // Initialize _isNextButtonEnabled based on the initial state of the first question
    _updateNextButtonState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _showDoctorIdInputDialog();
    });
  }

  Future<void> _showDoctorIdInputDialog() async {
    String enteredDoctorId = '';

    await showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by clicking outside
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Doctor ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  enteredDoctorId = value;
                },
                decoration: InputDecoration(
                  labelText: 'Doctor ID',
                ),
              ),
              Divider(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Check if the doctor ID is already associated with the user
                  final doctorIdExists =
                      await _checkDoctorIdExists(enteredDoctorId);
                  if (doctorIdExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Doctor ID is already used.'),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop(enteredDoctorId);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    ).then((result) {
      // Check if a doctor ID was entered
      if (result != null && result.isNotEmpty) {
        setState(() {
          _doctorId = result;
          _doctorIdEntered = true;
        });
      }
    });
  }

  Future<bool> _checkDoctorIdExists(String doctorId) async {
    try {
      final userSurveyRef =
          _firestore.collection('users-survey').doc(user!.uid);

      final userResponsesCollection =
          await userSurveyRef.collection('user-responses').get();

      for (final userResponsesDoc in userResponsesCollection.docs) {
        final userResponsesData =
            userResponsesDoc.data() as Map<String, dynamic>;
        if (userResponsesData['doctorId'] != null &&
            userResponsesData['doctorId'] == doctorId) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error checking doctor ID: $e');
      return false;
    }
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
      if (user == null) {
        // If the user is not signed in, return or handle the scenario accordingly
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return;
      }

      final DocumentSnapshot userDocument = await FirebaseFirestore.instance
          .collection('users-survey')
          .doc(user?.uid)
          .get();

      final userData = userDocument.data() as Map<String, dynamic>;

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
          _firestore.collection('users-survey').doc(user!.uid);

      // Check if the user document exists, and create it if not
      if (!(await userSurveyRef.get()).exists) {
        await userSurveyRef.set({
          'responses': userResponses,
          'surveyCompleted': false,
        });
      } else {
        // Update the surveyCompleted field for the current user
        await userSurveyRef.update({'surveyCompleted': false});
        await userSurveyRef
            .update({'surveyCount': (userData['surveyCount'] ?? 0) + 1});
      }

      final userResponsesRef = userSurveyRef.collection('user-responses').doc();
      final userResponsesResult =
          userSurveyRef.collection('user-survey-result').doc();

      // Save user responses in the "user-responses" collection
      await userResponsesRef.set({
        'doctorId': _doctorId,
        'responses': userResponses,
      });

      await userResponsesResult.set({
        'doctorId': _doctorId,
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

  // bool _doctorIdSubmitted = false;
  // TextEditingController _doctorIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Prevent going back if the doctor ID is not submitted
          return _doctorIdEntered;
        },
        child: Scaffold(
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
                                                (question['selectedOptions'] ??
                                                        [])
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
                                            groupValue: question[
                                                        'selectedOptions']
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        ));
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

class ThankYouScreen extends StatelessWidget {
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
