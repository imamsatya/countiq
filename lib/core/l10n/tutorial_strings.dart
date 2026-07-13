import 'dart:ui';
import '../../data/datasources/local_database.dart';

class TutorialStrings {
  TutorialStrings._();

  static String get _storedLocale => LocalDatabase.instance.getLocale();
  static String get _locale {
    if (_storedLocale == 'system') {
      try {
        final sysCode = PlatformDispatcher.instance.locale.languageCode;
        if (['en', 'es', 'pt', 'de', 'fr', 'ja', 'ko', 'id', 'zh', 'hi', 'ar'].contains(sysCode)) {
          return sysCode;
        }
      } catch (_) {}
      return 'en';
    }
    return _storedLocale;
  }

  static String get(String key) {
    return _strings[key]?[_locale] ?? _strings[key]?['en'] ?? key;
  }

  static final Map<String, Map<String, String>> _strings = {
    'how_to_play': {
      'en': 'How to Play', 'id': 'Cara Bermain', 'es': 'Cómo Jugar', 'pt': 'Como Jogar', 'de': 'Spielanleitung', 'fr': 'Comment Jouer', 'ja': '遊び方', 'ko': '게임 방법', 'zh': '如何游玩', 'hi': 'कैसे खेलें', 'ar': 'كيف تلعب'
    },
    'reach_the_target': {
      'en': 'Reach the Target', 'id': 'Capai Target', 'es': 'Alcanza el Objetivo', 'pt': 'Alcançar o Alvo', 'de': 'Erreiche das Ziel', 'fr': 'Atteindre la Cible', 'ja': '目標を達成', 'ko': '목표 도달', 'zh': '达到目标', 'hi': 'लक्ष्य तक पहुँचें', 'ar': 'الوصول للهدف'
    },
    'reach_target_desc': {
      'en': 'You are given a TARGET number and a set of available numbers. Use basic math operations (+, -, ×, ÷) to reach the exact target.',
      'id': 'Kamu diberi angka TARGET dan sekumpulan angka acak. Gunakan operasi matematika (+, -, ×, ÷) untuk mencapai target dengan tepat.',
      'es': 'Se te da un número OBJETIVO y números disponibles. Usa operaciones matemáticas (+, -, ×, ÷) para alcanzar el objetivo exacto.',
      'pt': 'Você recebe um número ALVO e números disponíveis. Use operações matemáticas (+, -, ×, ÷) para atingir o alvo exato.',
      'de': 'Sie erhalten eine ZIEL-Zahl und verfügbare Zahlen. Verwenden Sie Grundrechenarten (+, -, ×, ÷), um das Ziel zu erreichen.',
      'fr': 'Vous recevez un nombre CIBLE et des nombres disponibles. Utilisez les opérations (+, -, ×, ÷) pour atteindre la cible.',
      'ja': 'ターゲットとなる数字と利用可能な数字が与えられます。四則演算（+、-、×、÷）を使用して目標を達成してください。',
      'ko': '목표 숫자와 사용 가능한 숫자가 주어집니다. 사칙연산(+, -, ×, ÷)을 사용하여 정확한 목표에 도달하세요.',
      'zh': '系统会给您一个目标数字和一组可用数字。使用基本数学运算（+、-、×、÷）来达到目标。',
      'hi': 'आपको एक लक्ष्य संख्या और उपलब्ध संख्याएँ दी जाती हैं। लक्ष्य तक पहुँचने के लिए गणितीय संचालन (+, -, ×, ÷) का उपयोग करें।',
      'ar': 'يُعطى لك رقم هدف ومجموعة من الأرقام. استخدم العمليات الحسابية (+، -، ×، ÷) للوصول إلى الهدف.'
    },
    'reach_target_example': {
      'en': 'Target: 120\nNumbers: 75, 5, 8, 7, 6, 2',
      'id': 'Target: 120\nAngka: 75, 5, 8, 7, 6, 2',
      'es': 'Objetivo: 120\nNúmeros: 75, 5, 8, 7, 6, 2',
      'pt': 'Alvo: 120\nNúmeros: 75, 5, 8, 7, 6, 2',
      'de': 'Ziel: 120\nZahlen: 75, 5, 8, 7, 6, 2',
      'fr': 'Cible: 120\nNombres: 75, 5, 8, 7, 6, 2',
      'ja': '目標: 120\n数字: 75, 5, 8, 7, 6, 2',
      'ko': '목표: 120\n숫자: 75, 5, 8, 7, 6, 2',
      'zh': '目标: 120\n数字: 75, 5, 8, 7, 6, 2',
      'hi': 'लक्ष्य: 120\nसंख्या: 75, 5, 8, 7, 6, 2',
      'ar': 'الهدف: 120\nالأرقام: 75، 5، 8، 7، 6، 2'
    },
    'how_to_play_desc': {
      'en': '1. Select a number.\n2. Select an operation.\n3. Select another number.\n4. You get a new number as the result.\n5. Repeat until you reach the target!',
      'id': '1. Pilih sebuah angka.\n2. Pilih operasi matematika.\n3. Pilih angka lain.\n4. Kamu akan mendapat angka baru.\n5. Ulangi sampai mencapai target!',
      'es': '1. Selecciona un número.\n2. Selecciona una operación.\n3. Selecciona otro número.\n4. Obtienes un nuevo número.\n5. ¡Repite hasta alcanzar el objetivo!',
      'pt': '1. Selecione um número.\n2. Selecione uma operação.\n3. Selecione outro número.\n4. Você obtém um novo número.\n5. Repita até atingir o alvo!',
      'de': '1. Wähle eine Zahl.\n2. Wähle eine Operation.\n3. Wähle eine andere Zahl.\n4. Du erhältst eine neue Zahl.\n5. Wiederholen, bis das Ziel erreicht ist!',
      'fr': '1. Sélectionnez un nombre.\n2. Sélectionnez une opération.\n3. Sélectionnez un autre nombre.\n4. Vous obtenez un nouveau nombre.\n5. Répétez jusqu\'à la cible!',
      'ja': '1. 数字を選ぶ\n2. 演算子を選ぶ\n3. 別の数字を選ぶ\n4. 新しい数字が生成される\n5. 目標に到達するまで繰り返す！',
      'ko': '1. 숫자를 선택하세요.\n2. 연산자를 선택하세요.\n3. 다른 숫자를 선택하세요.\n4. 결과로 새 숫자를 얻습니다.\n5. 목표에 도달할 때까지 반복하세요!',
      'zh': '1. 选择一个数字。\n2. 选择一个运算。\n3. 选择另一个数字。\n4. 您会得到一个新数字。\n5. 重复直到达到目标！',
      'hi': '1. संख्या चुनें।\n2. संचालन चुनें।\n3. दूसरी संख्या चुनें।\n4. आपको नई संख्या मिलेगी।\n5. लक्ष्य तक पहुँचने तक दोहराएँ!',
      'ar': '1. اختر رقمًا.\n2. اختر عملية.\n3. اختر رقمًا آخر.\n4. ستحصل على رقم جديد.\n5. كرر حتى تصل للهدف!'
    },
    'how_to_play_example': {
      'en': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'id': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'es': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'pt': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'de': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'fr': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'ja': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'ko': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'zh': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'hi': '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
      'ar': '75 ÷ 5 = 15\n15 × 8 = 120 ✓'
    },
    'rules': {
      'en': 'Rules', 'id': 'Aturan', 'es': 'Reglas', 'pt': 'Regras', 'de': 'Regeln', 'fr': 'Règles', 'ja': 'ルール', 'ko': '규칙', 'zh': '规则', 'hi': 'नियम', 'ar': 'القواعد'
    },
    'rules_desc': {
      'en': 'Only positive whole numbers are allowed. You cannot use division if there is a remainder, and you cannot subtract to get a negative number.',
      'id': 'Hanya bilangan bulat positif yang diizinkan. Pembagian harus habis (tanpa sisa), dan pengurangan tidak boleh menghasilkan angka negatif.',
      'es': 'Solo se permiten enteros positivos. No puedes dividir si hay residuo y no puedes restar para obtener negativos.',
      'pt': 'Apenas números inteiros positivos. Você não pode dividir se houver resto, e não pode subtrair para obter negativo.',
      'de': 'Nur positive ganze Zahlen. Division mit Rest ist nicht erlaubt und Subtraktion darf nicht negativ werden.',
      'fr': 'Seuls les entiers positifs sont autorisés. La division avec reste ou la soustraction négative est interdite.',
      'ja': '正の整数のみ使用可能です。割り切れない割り算や、マイナスになる引き算はできません。',
      'ko': '양의 정수만 허용됩니다. 나머지가 있는 나눗셈은 불가하며, 빼서 음수가 될 수 없습니다.',
      'zh': '只允许正整数。如果有余数则不能除，也不能减去得到负数。',
      'hi': 'केवल सकारात्मक पूर्ण संख्याएँ। यदि शेष है तो आप विभाजित नहीं कर सकते हैं, और नकारात्मक प्राप्त करने के लिए घटा नहीं सकते।',
      'ar': 'يُسمح فقط بالأرقام الموجبة الصحيحة. لا يمكنك القسمة إذا كان هناك باقٍ، ولا يمكنك الطرح للحصول على سالب.'
    },
    'rules_example': {
      'en': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'id': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'es': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'pt': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'de': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'fr': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'ja': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'ko': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'zh': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'hi': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
      'ar': '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗'
    },
    'star_rating': {
      'en': 'Star Rating', 'id': 'Peringkat Bintang', 'es': 'Calificación de Estrellas', 'pt': 'Classificação de Estrelas', 'de': 'Sternebewertung', 'fr': 'Évaluation par Étoiles', 'ja': 'スター評価', 'ko': '별점 평가', 'zh': '星级评分', 'hi': 'स्टार रेटिंग', 'ar': 'تصنيف النجوم'
    },
    'star_rating_desc': {
      'en': 'You can earn up to 3 stars per puzzle based on your performance. Solving faster and using fewer hints yields more stars.',
      'id': 'Kamu bisa mendapat hingga 3 bintang per teka-teki. Selesaikan lebih cepat dan gunakan sedikit petunjuk untuk mendapat bintang maksimal.',
      'es': 'Puedes ganar hasta 3 estrellas por acertijo. Resolver más rápido y usar menos pistas da más estrellas.',
      'pt': 'Você pode ganhar até 3 estrelas por quebra-cabeça. Resolver mais rápido e usar menos dicas dá mais estrelas.',
      'de': 'Du kannst bis zu 3 Sterne pro Rätsel verdienen. Schnelleres Lösen und weniger Tipps bringen mehr Sterne.',
      'fr': 'Vous pouvez gagner jusqu\'à 3 étoiles par puzzle. Résolvez plus vite et utilisez moins d\'indices pour plus d\'étoiles.',
      'ja': 'パズルごとに最大3つの星を獲得できます。早く解き、ヒントを少なくすることでより多くの星を獲得できます。',
      'ko': '퍼즐당 최대 3개의 별을 획득할 수 있습니다. 더 빨리 풀고 힌트를 적게 사용할수록 더 많은 별을 얻습니다.',
      'zh': '每个难题您最多可以获得3颗星。解决得越快，使用的提示越少，获得的星星就越多。',
      'hi': 'आप प्रति पहेली 3 स्टार तक कमा सकते हैं। तेजी से हल करने और कम संकेत उपयोग से अधिक स्टार मिलते हैं।',
      'ar': 'يمكنك كسب ما يصل إلى 3 نجوم لكل لغز. الحل بشكل أسرع واستخدام تلميحات أقل يعطي نجومًا أكثر.'
    },
    'star_rating_example': {
      'en': 'Faster solve + fewer hints = more stars!',
      'id': 'Lebih cepat + minim petunjuk = bintang lebih banyak!',
      'es': '¡Solución rápida + menos pistas = más estrellas!',
      'pt': 'Resolução rápida + menos dicas = mais estrelas!',
      'de': 'Schneller lösen + weniger Tipps = mehr Sterne!',
      'fr': 'Résolution rapide + moins d\'indices = plus d\'étoiles!',
      'ja': '早く解く + ヒントが少ない = 星が多い！',
      'ko': '빠른 해결 + 적은 힌트 = 더 많은 별!',
      'zh': '更快解决 + 更少提示 = 更多星星！',
      'hi': 'तेज़ हल + कम संकेत = अधिक स्टार!',
      'ar': 'حل أسرع + تلميحات أقل = نجوم أكثر!'
    },
    'tips_hints_desc': {
      'en': 'If you are stuck, use a hint to reveal the next step. Hints cost 1 star from your potential rating.',
      'id': 'Jika kamu terjebak, gunakan petunjuk untuk membuka langkah berikutnya. Menggunakan petunjuk akan mengurangi 1 bintang dari penilaian.',
      'es': 'Si te quedas atascado, usa una pista. Las pistas cuestan 1 estrella de tu calificación potencial.',
      'pt': 'Se estiver travado, use uma dica. Dicas custam 1 estrela da sua classificação.',
      'de': 'Wenn du feststeckst, nutze einen Tipp. Tipps kosten 1 Stern von deiner potenziellen Bewertung.',
      'fr': 'Si vous êtes bloqué, utilisez un indice. Les indices coûtent 1 étoile de votre note potentielle.',
      'ja': '行き詰まったらヒントを使いましょう。ヒントを使用すると星が1つ減ります。',
      'ko': '막히면 힌트를 사용하여 다음 단계를 확인하세요. 힌트를 사용하면 별이 1개 줄어듭니다.',
      'zh': '如果卡住了，请使用提示来揭示下一步。提示会扣除您1颗星的评分。',
      'hi': 'यदि आप फंस गए हैं, तो संकेत का उपयोग करें। संकेत आपके स्टार रेटिंग से 1 स्टार कम कर देगा।',
      'ar': 'إذا كنت عالقًا، استخدم تلميحًا. استخدام تلميح يخصم نجمة واحدة من تقييمك.'
    },
    'tips_hints_example': {
      'en': 'Tip: 75 ÷ 5 = 15, then 15 × 8 = 120 🎉',
      'id': 'Tips: 75 ÷ 5 = 15, lalu 15 × 8 = 120 🎉',
      'es': 'Consejo: 75 ÷ 5 = 15, luego 15 × 8 = 120 🎉',
      'pt': 'Dica: 75 ÷ 5 = 15, então 15 × 8 = 120 🎉',
      'de': 'Tipp: 75 ÷ 5 = 15, dann 15 × 8 = 120 🎉',
      'fr': 'Astuce: 75 ÷ 5 = 15, puis 15 × 8 = 120 🎉',
      'ja': 'ヒント: 75 ÷ 5 = 15, そして 15 × 8 = 120 🎉',
      'ko': '팁: 75 ÷ 5 = 15, 그런 다음 15 × 8 = 120 🎉',
      'zh': '提示: 75 ÷ 5 = 15, 然后 15 × 8 = 120 🎉',
      'hi': 'सुझाव: 75 ÷ 5 = 15, फिर 15 × 8 = 120 🎉',
      'ar': 'نصيحة: 75 ÷ 5 = 15، ثم 15 × 8 = 120 🎉'
    },
    'lets_play': {
      'en': 'Let\'s Play!', 'id': 'Mulai Main!', 'es': '¡A Jugar!', 'pt': 'Vamos Jogar!', 'de': 'Lass uns spielen!', 'fr': 'Jouons!', 'ja': '遊ぼう！', 'ko': '게임 시작!', 'zh': '开始游戏！', 'hi': 'चलो खेलें!', 'ar': 'هيا نلعب!'
    }
  };
}
