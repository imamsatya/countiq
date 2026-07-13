import 'dart:ui';
import '../../data/datasources/local_database.dart';

class AppStrings {
  AppStrings._();
  
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
  
  static final Map<String, Map<String, String>> _strings = {
    'app_name': {'en': 'CountiQ', 'id': 'CountiQ', 'es': 'CountiQ', 'pt': 'CountiQ', 'de': 'CountiQ', 'fr': 'CountiQ', 'ja': 'CountiQ', 'ko': 'CountiQ', 'zh': 'CountiQ', 'hi': 'CountiQ', 'ar': 'CountiQ'},
    'app_subtitle': {'en': 'REACH THE NUMBER', 'id': 'RAIH ANGKANYA', 'es': 'ALCANZA EL NÚMERO', 'pt': 'ALCANCE O NÚMERO', 'de': 'ERREICHE DIE ZAHL', 'fr': 'ATTEIGNEZ LE NOMBRE', 'ja': '数字を目指せ', 'ko': '목표 숫자에 도달하세요', 'zh': '达到目标数字', 'hi': 'संख्या तक पहुँचें', 'ar': 'صل إلى الرقم'},
    'app_footer': {'en': 'A number puzzle game', 'id': 'Game teka-teki angka', 'es': 'Un juego de rompecabezas numérico', 'pt': 'Um jogo de quebra-cabeça numérico', 'de': 'Ein Zahlenrätselspiel', 'fr': 'Un jeu de puzzle numérique', 'ja': '数字パズルゲーム', 'ko': '숫자 퍼즐 게임', 'zh': '数字益智游戏', 'hi': 'एक संख्या पहेली खेल', 'ar': 'لعبة لغز الأرقام'},
    'play': {'en': 'PLAY', 'id': 'MAIN', 'es': 'JUGAR', 'pt': 'JOGAR', 'de': 'SPIELEN', 'fr': 'JOUER', 'ja': 'プレイ', 'ko': '플레이', 'zh': '开始游戏', 'hi': 'खेलें', 'ar': 'العب'},
    'continue_level': {'en': 'CONTINUE Level', 'id': 'LANJUT Level', 'es': 'CONTINUAR Nivel', 'pt': 'CONTINUAR Nível', 'de': 'WEITER Level', 'fr': 'CONTINUER Niveau', 'ja': 'レベルを続行', 'ko': '레벨 계속하기', 'zh': '继续关卡', 'hi': 'स्तर जारी रखें', 'ar': 'متابعة المستوى'},
    'daily_challenge': {'en': 'Daily Challenge', 'id': 'Tantangan Harian', 'es': 'Reto Diario', 'pt': 'Desafio Diário', 'de': 'Tägliche Herausforderung', 'fr': 'Défi Quotidien', 'ja': 'デイリーチャレンジ', 'ko': '일일 도전', 'zh': '每日挑战', 'hi': 'दैनिक चुनौती', 'ar': 'التحدي اليومي'},
    'daily_complete': {'en': 'Daily Complete ✓', 'id': 'Harian Selesai ✓', 'es': 'Diario Completado ✓', 'pt': 'Diário Concluído ✓', 'de': 'Täglich Abgeschlossen ✓', 'fr': 'Quotidien Terminé ✓', 'ja': 'デイリー完了 ✓', 'ko': '일일 완료 ✓', 'zh': '每日完成 ✓', 'hi': 'दैनिक पूर्ण ✓', 'ar': 'مكتمل يوميا ✓'},
    'easy': {'en': 'Easy', 'id': 'Mudah', 'es': 'Fácil', 'pt': 'Fácil', 'de': 'Leicht', 'fr': 'Facile', 'ja': '簡単', 'ko': '쉬움', 'zh': '简单', 'hi': 'आसान', 'ar': 'سهل'},
    'medium': {'en': 'Medium', 'id': 'Sedang', 'es': 'Medio', 'pt': 'Médio', 'de': 'Mittel', 'fr': 'Moyen', 'ja': '普通', 'ko': '보통', 'zh': '中等', 'hi': 'मध्यम', 'ar': 'متوسط'},
    'hard': {'en': 'Hard', 'id': 'Sulit', 'es': 'Difícil', 'pt': 'Difícil', 'de': 'Schwer', 'fr': 'Difficile', 'ja': '難しい', 'ko': '어려움', 'zh': '困难', 'hi': 'कठिन', 'ar': 'صعب'},
    'time_attack': {'en': 'Time Attack', 'id': 'Serangan Waktu', 'es': 'Contra el Reloj', 'pt': 'Contra o Tempo', 'de': 'Zeitangriff', 'fr': 'Contre-la-montre', 'ja': 'タイムアタック', 'ko': '타임 어택', 'zh': '时间挑战', 'hi': 'समय चुनौती', 'ar': 'تحدي الوقت'},
    'select_level': {'en': 'Select Level', 'id': 'Pilih Level', 'es': 'Seleccionar Nivel', 'pt': 'Selecionar Nível', 'de': 'Level Auswählen', 'fr': 'Sélectionner Niveau', 'ja': 'レベル選択', 'ko': '레벨 선택', 'zh': '选择关卡', 'hi': 'स्तर चुनें', 'ar': 'اختر المستوى'},
    'statistics': {'en': 'Statistics', 'id': 'Statistik', 'es': 'Estadísticas', 'pt': 'Estatísticas', 'de': 'Statistiken', 'fr': 'Statistiques', 'ja': '統計', 'ko': '통계', 'zh': '统计数据', 'hi': 'आँकड़े', 'ar': 'الإحصائيات'},
    'achievements': {'en': 'Achievements', 'id': 'Pencapaian', 'es': 'Logros', 'pt': 'Conquistas', 'de': 'Erfolge', 'fr': 'Réalisations', 'ja': '実績', 'ko': '업적', 'zh': '成就', 'hi': 'उपलब्धियां', 'ar': 'الإنجازات'},
    'how_to_play': {'en': 'How to Play', 'id': 'Cara Bermain', 'es': 'Cómo Jugar', 'pt': 'Como Jogar', 'de': 'Spielanleitung', 'fr': 'Comment Jouer', 'ja': '遊び方', 'ko': '플레이 방법', 'zh': '怎么玩', 'hi': 'कैसे खेलें', 'ar': 'كيف تلعب'},
    'settings': {'en': 'Settings', 'id': 'Pengaturan', 'es': 'Ajustes', 'pt': 'Configurações', 'de': 'Einstellungen', 'fr': 'Paramètres', 'ja': '設定', 'ko': '설정', 'zh': '设置', 'hi': 'सेटिंग्स', 'ar': 'الإعدادات'},
    'target': {'en': 'TARGET', 'id': 'TARGET', 'es': 'OBJETIVO', 'pt': 'ALVO', 'de': 'ZIEL', 'fr': 'CIBLE', 'ja': 'ターゲット', 'ko': '목표', 'zh': '目标', 'hi': 'लक्ष्य', 'ar': 'الهدف'},
    'target_reached': {'en': '🎉 TARGET REACHED!', 'id': '🎉 TARGET TERCAPAI!', 'es': '🎉 ¡OBJETIVO ALCANZADO!', 'pt': '🎉 ALVO ALCANÇADO!', 'de': '🎉 ZIEL ERREICHT!', 'fr': '🎉 CIBLE ATTEINTE!', 'ja': '🎉 ターゲット到達！', 'ko': '🎉 목표 달성!', 'zh': '🎉 达到目标！', 'hi': '🎉 लक्ष्य प्राप्त!', 'ar': '🎉 تم الوصول للهدف!'},
    'tap_to_start': {'en': 'Tap a number to start', 'id': 'Ketuk angka untuk mulai', 'es': 'Toca un número para empezar', 'pt': 'Toque num número para começar', 'de': 'Tippe auf eine Zahl, um zu beginnen', 'fr': 'Appuyez sur un nombre pour commencer', 'ja': '数字をタップして開始', 'ko': '숫자를 탭하여 시작', 'zh': '点击数字开始', 'hi': 'शुरू करने के लिए एक संख्या टैप करें', 'ar': 'اضغط على رقم للبدء'},
    'hint': {'en': 'Hint', 'id': 'Petunjuk', 'es': 'Pista', 'pt': 'Dica', 'de': 'Tipp', 'fr': 'Indice', 'ja': 'ヒント', 'ko': '힌트', 'zh': '提示', 'hi': 'संकेत', 'ar': 'تلميح'},
    'skip': {'en': 'Skip', 'id': 'Lewati', 'es': 'Omitir', 'pt': 'Pular', 'de': 'Überspringen', 'fr': 'Passer', 'ja': 'スキップ', 'ko': '건너뛰기', 'zh': '跳过', 'hi': 'छोड़ें', 'ar': 'تخطي'},
    'result': {'en': 'Result', 'id': 'Hasil', 'es': 'Resultado', 'pt': 'Resultado', 'de': 'Ergebnis', 'fr': 'Résultat', 'ja': '結果', 'ko': '결과', 'zh': '结果', 'hi': 'परिणाम', 'ar': 'النتيجة'},
    'solve_it': {'en': 'Solve it!', 'id': 'Selesaikan!', 'es': '¡A resolver!', 'pt': 'Resolva!', 'de': 'Löse es!', 'fr': 'Résolvez-le!', 'ja': '解いてみよう！', 'ko': '해결하세요!', 'zh': '解决它！', 'hi': 'इसे हल करें!', 'ar': 'حلها!'},
    'cannot_divide_zero': {'en': 'Cannot divide by zero', 'id': 'Tidak bisa dibagi nol', 'es': 'No se puede dividir por cero', 'pt': 'Não é possível dividir por zero', 'de': 'Teilen durch Null nicht möglich', 'fr': 'Impossible de diviser par zéro', 'ja': 'ゼロで除算できません', 'ko': '0으로 나눌 수 없습니다', 'zh': '不能除以零', 'hi': 'शून्य से विभाजित नहीं कर सकते', 'ar': 'لا يمكن القسمة على صفر'},
    'not_whole': {'en': 'is not a whole number', 'id': 'bukan bilangan bulat', 'es': 'no es un número entero', 'pt': 'não é um número inteiro', 'de': 'ist keine ganze Zahl', 'fr': 'n\'est pas un nombre entier', 'ja': 'は整数ではありません', 'ko': '는 정수가 아닙니다', 'zh': '不是整数', 'hi': 'पूर्ण संख्या नहीं है', 'ar': 'ليس رقما صحيحا'},
    'would_be_negative': {'en': 'would be negative or zero', 'id': 'hasilnya negatif atau nol', 'es': 'sería negativo o cero', 'pt': 'seria negativo ou zero', 'de': 'wäre negativ oder null', 'fr': 'serait négatif ou zéro', 'ja': 'ゼロまたは負になります', 'ko': '음수 또는 0이 됩니다', 'zh': '结果将为负数或零', 'hi': 'नकारात्मक या शून्य होगा', 'ar': 'سيكون سالبا أو صفرا'},
    'invalid_operation': {'en': 'Invalid operation', 'id': 'Operasi tidak valid', 'es': 'Operación inválida', 'pt': 'Operação inválida', 'de': 'Ungültige Operation', 'fr': 'Opération invalide', 'ja': '無効な操作', 'ko': '잘못된 작업', 'zh': '无效操作', 'hi': 'अवैध संचालन', 'ar': 'عملية غير صالحة'},
    'puzzle_solved': {'en': 'PUZZLE SOLVED!', 'id': 'TEKA-TEKI TERPECAHKAN!', 'es': '¡ROMPECABEZAS RESUELTO!', 'pt': 'QUEBRA-CABEÇA RESOLVIDO!', 'de': 'RÄTSEL GELÖST!', 'fr': 'PUZZLE RÉSOLU!', 'ja': 'パズルクリア！', 'ko': '퍼즐 해결!', 'zh': '难题已解决！', 'hi': 'पहेली हल हो गई!', 'ar': 'تم حل اللغز!'},
    'next_puzzle': {'en': 'NEXT PUZZLE', 'id': 'SOAL BERIKUTNYA', 'es': 'SIGUIENTE ROMPECABEZAS', 'pt': 'PRÓXIMO QUEBRA-CABEÇA', 'de': 'NÄCHSTES RÄTSEL', 'fr': 'PUZZLE SUIVANT', 'ja': '次のパズル', 'ko': '다음 퍼즐', 'zh': '下一个难题', 'hi': 'अगली पहेली', 'ar': 'اللغز التالي'},
    'share': {'en': 'Share', 'id': 'Bagikan', 'es': 'Compartir', 'pt': 'Partilhar', 'de': 'Teilen', 'fr': 'Partager', 'ja': '共有', 'ko': '공유', 'zh': '分享', 'hi': 'साझा करें', 'ar': 'مشاركة'},
    'replay': {'en': 'Replay', 'id': 'Ulang', 'es': 'Repetir', 'pt': 'Repetir', 'de': 'Wiederholen', 'fr': 'Rejouer', 'ja': 'リプレイ', 'ko': '다시하기', 'zh': '重玩', 'hi': 'दोबारा खेलें', 'ar': 'إعادة اللعب'},
    'home': {'en': 'Home', 'id': 'Beranda', 'es': 'Inicio', 'pt': 'Início', 'de': 'Start', 'fr': 'Accueil', 'ja': 'ホーム', 'ko': '홈', 'zh': '主页', 'hi': 'होम', 'ar': 'الرئيسية'},
    'time': {'en': 'Time', 'id': 'Waktu', 'es': 'Tiempo', 'pt': 'Tempo', 'de': 'Zeit', 'fr': 'Temps', 'ja': '時間', 'ko': '시간', 'zh': '时间', 'hi': 'समय', 'ar': 'الوقت'},
    'steps': {'en': 'Steps', 'id': 'Langkah', 'es': 'Pasos', 'pt': 'Passos', 'de': 'Schritte', 'fr': 'Étapes', 'ja': 'ステップ', 'ko': '단계', 'zh': '步数', 'hi': 'कदम', 'ar': 'خطوات'},
    'hints': {'en': 'Hints', 'id': 'Petunjuk', 'es': 'Pistas', 'pt': 'Dicas', 'de': 'Tipps', 'fr': 'Indices', 'ja': 'ヒント', 'ko': '힌트', 'zh': '提示', 'hi': 'संकेत', 'ar': 'تلميحات'},
    'come_back_tomorrow': {'en': 'Come back tomorrow!', 'id': 'Kembali besok!', 'es': '¡Vuelve mañana!', 'pt': 'Volte amanhã!', 'de': 'Komm morgen wieder!', 'fr': 'Revenez demain!', 'ja': 'また明日！', 'ko': '내일 다시 오세요!', 'zh': '明天再来！', 'hi': 'कल वापस आना!', 'ar': 'عد غدا!'},
    'streak': {'en': 'Streak', 'id': 'Beruntun', 'es': 'Racha', 'pt': 'Sequência', 'de': 'Serie', 'fr': 'Série', 'ja': 'ストリーク', 'ko': '연속', 'zh': '连续', 'hi': 'लगातार', 'ar': 'سلسلة'},
    'completed': {'en': 'Completed', 'id': 'Selesai', 'es': 'Completado', 'pt': 'Concluído', 'de': 'Abgeschlossen', 'fr': 'Terminé', 'ja': '完了', 'ko': '완료', 'zh': '已完成', 'hi': 'पूर्ण', 'ar': 'مكتمل'},
    'level_select': {'en': 'LEVEL SELECT', 'id': 'PILIH LEVEL', 'es': 'SELECCIÓN DE NIVEL', 'pt': 'SELEÇÃO DE NÍVEL', 'de': 'LEVEL AUSWÄHLEN', 'fr': 'SÉLECTION DE NIVEAU', 'ja': 'レベル選択', 'ko': '레벨 선택', 'zh': '选择关卡', 'hi': 'स्तर चुनें', 'ar': 'اختيار المستوى'},
    'locked': {'en': 'Locked', 'id': 'Terkunci', 'es': 'Bloqueado', 'pt': 'Bloqueado', 'de': 'Gesperrt', 'fr': 'Verrouillé', 'ja': 'ロック', 'ko': '잠김', 'zh': '已锁定', 'hi': 'लॉक है', 'ar': 'مغلق'},
    'sound_effects': {'en': 'Sound Effects', 'id': 'Efek Suara', 'es': 'Efectos de Sonido', 'pt': 'Efeitos Sonoros', 'de': 'Toneffekte', 'fr': 'Effets Sonores', 'ja': '効果音', 'ko': '효과음', 'zh': '音效', 'hi': 'ध्वनि प्रभाव', 'ar': 'تأثيرات الصوت'},
    'haptic_feedback': {'en': 'Haptic Feedback', 'id': 'Getaran Haptic', 'es': 'Vibración', 'pt': 'Feedback Tátil', 'de': 'Haptisches Feedback', 'fr': 'Retour Haptique', 'ja': '触覚フィードバック', 'ko': '햅틱 피드백', 'zh': '触觉反馈', 'hi': 'हैप्टिक फीडबैक', 'ar': 'ردود الفعل اللمسية'},
    'language': {'en': 'Language', 'id': 'Bahasa', 'es': 'Idioma', 'pt': 'Idioma', 'de': 'Sprache', 'fr': 'Langue', 'ja': '言語', 'ko': '언어', 'zh': '语言', 'hi': 'भाषा', 'ar': 'اللغة'},
    'english': {'en': 'English', 'id': 'English', 'es': 'English', 'pt': 'English', 'de': 'English', 'fr': 'English', 'ja': 'English', 'ko': 'English', 'zh': 'English', 'hi': 'English', 'ar': 'English'},
    'indonesian': {'en': 'Bahasa Indonesia', 'id': 'Bahasa Indonesia', 'es': 'Bahasa Indonesia', 'pt': 'Bahasa Indonesia', 'de': 'Bahasa Indonesia', 'fr': 'Bahasa Indonesia', 'ja': 'Bahasa Indonesia', 'ko': 'Bahasa Indonesia', 'zh': 'Bahasa Indonesia', 'hi': 'Bahasa Indonesia', 'ar': 'Bahasa Indonesia'},
    'game': {'en': 'Game', 'id': 'Permainan', 'es': 'Juego', 'pt': 'Jogo', 'de': 'Spiel', 'fr': 'Jeu', 'ja': 'ゲーム', 'ko': '게임', 'zh': '游戏', 'hi': 'खेल', 'ar': 'لعبة'},
    'about': {'en': 'About', 'id': 'Tentang', 'es': 'Acerca de', 'pt': 'Sobre', 'de': 'Über', 'fr': 'À propos', 'ja': '情報', 'ko': '정보', 'zh': '关于', 'hi': 'के बारे में', 'ar': 'حول'},
    'version': {'en': 'Version', 'id': 'Versi', 'es': 'Versión', 'pt': 'Versão', 'de': 'Version', 'fr': 'Version', 'ja': 'バージョン', 'ko': '버전', 'zh': '版本', 'hi': 'संस्करण', 'ar': 'إصدار'},
    'rate_app': {'en': 'Rate This App', 'id': 'Beri Rating', 'es': 'Califica Esta App', 'pt': 'Avalie Este Aplicativo', 'de': 'App Bewerten', 'fr': 'Évaluer Cette App', 'ja': 'アプリを評価', 'ko': '앱 평가하기', 'zh': '评价此应用', 'hi': 'ऐप को रेट करें', 'ar': 'قيّم هذا التطبيق'},
    'share_friends': {'en': 'Share with Friends', 'id': 'Bagikan ke Teman', 'es': 'Compartir con Amigos', 'pt': 'Compartilhar com Amigos', 'de': 'Mit Freunden Teilen', 'fr': 'Partager avec des Amis', 'ja': '友達と共有', 'ko': '친구와 공유', 'zh': '与朋友分享', 'hi': 'दोस्तों के साथ साझा करें', 'ar': 'شارك مع الأصدقاء'},
    'data': {'en': 'Data', 'id': 'Data', 'es': 'Datos', 'pt': 'Dados', 'de': 'Daten', 'fr': 'Données', 'ja': 'データ', 'ko': '데이터', 'zh': '数据', 'hi': 'डेटा', 'ar': 'البيانات'},
    'reset_progress': {'en': 'Reset All Progress', 'id': 'Reset Semua Progres', 'es': 'Restablecer Progreso', 'pt': 'Redefinir Todo o Progresso', 'de': 'Fortschritt Zurücksetzen', 'fr': 'Réinitialiser la Progression', 'ja': '進行状況をリセット', 'ko': '모든 진행 상황 초기화', 'zh': '重置所有进度', 'hi': 'सभी प्रगति रीसेट करें', 'ar': 'إعادة تعيين كل التقدم'},
    'reset_confirm_title': {'en': 'Reset All Progress?', 'id': 'Reset Semua Progres?', 'es': '¿Restablecer Progreso?', 'pt': 'Redefinir Progresso?', 'de': 'Fortschritt Zurücksetzen?', 'fr': 'Réinitialiser la Progression?', 'ja': 'すべてリセットしますか？', 'ko': '진행 상황 초기화?', 'zh': '重置所有进度？', 'hi': 'प्रगति रीसेट करें?', 'ar': 'إعادة تعيين التقدم؟'},
    'reset_confirm_body': {
      'en': 'This will delete all your level progress, stars, and statistics. This action cannot be undone.',
      'id': 'Ini akan menghapus semua progres level, bintang, dan statistik. Tindakan ini tidak bisa dibatalkan.',
      'es': 'Esto eliminará todo tu progreso de niveles, estrellas y estadísticas. Esta acción no se puede deshacer.',
      'pt': 'Isto apagará todo o seu progresso, estrelas e estatísticas. Esta ação não pode ser desfeita.',
      'de': 'Dies löscht deinen gesamten Levelfortschritt, Sterne und Statistiken. Diese Aktion kann nicht rückgängig gemacht werden.',
      'fr': 'Cela supprimera toute votre progression, étoiles et statistiques. Cette action est irréversible.',
      'ja': 'これにより、すべてのレベルの進行状況、星、統計が削除されます。この操作は元に戻せません。',
      'ko': '이렇게 하면 모든 레벨 진행 상황, 별, 통계가 삭제됩니다. 이 작업은 취소할 수 없습니다.',
      'zh': '这将删除您的所有关卡进度、星星和统计数据。此操作无法撤消。',
      'hi': 'इससे आपकी सभी स्तर की प्रगति, सितारे और आँकड़े हटा दिए जाएंगे। इस क्रिया को पूर्ववत नहीं किया जा सकता है।',
      'ar': 'سيؤدي هذا إلى حذف كل تقدمك في المستوى والنجوم والإحصائيات. لا يمكن التراجع عن هذا الإجراء.'
    },
    'cancel': {'en': 'Cancel', 'id': 'Batal', 'es': 'Cancelar', 'pt': 'Cancelar', 'de': 'Abbrechen', 'fr': 'Annuler', 'ja': 'キャンセル', 'ko': '취소', 'zh': '取消', 'hi': 'रद्द करें', 'ar': 'إلغاء'},
    'reset': {'en': 'Reset', 'id': 'Reset', 'es': 'Restablecer', 'pt': 'Redefinir', 'de': 'Zurücksetzen', 'fr': 'Réinitialiser', 'ja': 'リセット', 'ko': '초기화', 'zh': '重置', 'hi': 'रीसेट', 'ar': 'إعادة تعيين'},
    'reset_done': {'en': 'All progress has been reset', 'id': 'Semua progres telah direset', 'es': 'Se ha restablecido todo el progreso', 'pt': 'Todo o progresso foi redefinido', 'de': 'Gesamter Fortschritt wurde zurückgesetzt', 'fr': 'Toute la progression a été réinitialisée', 'ja': 'すべての進行状況がリセットされました', 'ko': '모든 진행 상황이 초기화되었습니다', 'zh': '所有进度均已重置', 'hi': 'सभी प्रगति रीसेट कर दी गई है', 'ar': 'تم إعادة تعيين كل التقدم'},
    'overview': {'en': 'Overview', 'id': 'Ringkasan', 'es': 'Resumen', 'pt': 'Visão Geral', 'de': 'Übersicht', 'fr': 'Aperçu', 'ja': '概要', 'ko': '개요', 'zh': '概览', 'hi': 'अवलोकन', 'ar': 'نظرة عامة'},
    'puzzles_solved': {'en': 'Puzzles Solved', 'id': 'Teka-teki Selesai', 'es': 'Acertijos Resueltos', 'pt': 'Quebra-cabeças Resolvidos', 'de': 'Gelöste Rätsel', 'fr': 'Puzzles Résolus', 'ja': '解決したパズル', 'ko': '해결된 퍼즐', 'zh': '解决的难题', 'hi': 'हल की गई पहेलियाँ', 'ar': 'الألغاز المحلولة'},
    'stars_earned': {'en': 'Stars Earned', 'id': 'Bintang Didapat', 'es': 'Estrellas Ganadas', 'pt': 'Estrelas Ganhas', 'de': 'Verdiente Sterne', 'fr': 'Étoiles Gagnées', 'ja': '獲得した星', 'ko': '획득한 별', 'zh': '获得的星星', 'hi': 'अर्जित सितारे', 'ar': 'النجوم المكتسبة'},
    'total_time': {'en': 'Total Time', 'id': 'Total Waktu', 'es': 'Tiempo Total', 'pt': 'Tempo Total', 'de': 'Gesamtzeit', 'fr': 'Temps Total', 'ja': '合計時間', 'ko': '총 시간', 'zh': '总时间', 'hi': 'कुल समय', 'ar': 'الوقت الإجمالي'},
    'best_time': {'en': 'Best Time', 'id': 'Waktu Terbaik', 'es': 'Mejor Tiempo', 'pt': 'Melhor Tempo', 'de': 'Beste Zeit', 'fr': 'Meilleur Temps', 'ja': 'ベストタイム', 'ko': '최고 시간', 'zh': '最佳时间', 'hi': 'सबसे अच्छा समय', 'ar': 'أفضل وقت'},
    'campaign_progress': {'en': 'Campaign Progress', 'id': 'Progres Kampanye', 'es': 'Progreso de Campaña', 'pt': 'Progresso da Campanha', 'de': 'Kampagnenfortschritt', 'fr': 'Progression de Campagne', 'ja': 'キャンペーン進行', 'ko': '캠페인 진행', 'zh': '战役进度', 'hi': 'अभियान प्रगति', 'ar': 'تقدم الحملة'},
    'levels': {'en': 'Levels', 'id': 'Level', 'es': 'Niveles', 'pt': 'Níveis', 'de': 'Level', 'fr': 'Niveaux', 'ja': 'レベル', 'ko': '레벨', 'zh': '关卡', 'hi': 'स्तर', 'ar': 'مستويات'},
    'quick_play': {'en': 'Quick Play', 'id': 'Main Cepat', 'es': 'Juego Rápido', 'pt': 'Jogo Rápido', 'de': 'Schnelles Spiel', 'fr': 'Jeu Rapide', 'ja': 'クイックプレイ', 'ko': '빠른 플레이', 'zh': '快速游戏', 'hi': 'त्वरित खेल', 'ar': 'لعب سريع'},
    'total_hints_used': {'en': 'Total Hints Used', 'id': 'Total Petunjuk Digunakan', 'es': 'Total Pistas Usadas', 'pt': 'Dicas Totais Usadas', 'de': 'Gesamte Tipps', 'fr': 'Indices Totaux', 'ja': '使用したヒント', 'ko': '총 사용 힌트', 'zh': '总共使用的提示', 'hi': 'कुल संकेत उपयोग', 'ar': 'إجمالي التلميحات'},
    'best_score': {'en': 'Best Score', 'id': 'Skor Terbaik', 'es': 'Mejor Puntuación', 'pt': 'Melhor Pontuação', 'de': 'Bester Punktestand', 'fr': 'Meilleur Score', 'ja': 'ベストスコア', 'ko': '최고 점수', 'zh': '最高得分', 'hi': 'सर्वश्रेष्ठ स्कोर', 'ar': 'أفضل نتيجة'},
    'games_played': {'en': 'Games Played', 'id': 'Game Dimainkan', 'es': 'Juegos Jugados', 'pt': 'Jogos Jogados', 'de': 'Gespielte Spiele', 'fr': 'Jeux Joués', 'ja': 'プレイ回数', 'ko': '플레이한 게임', 'zh': '游戏次数', 'hi': 'खेले गए खेल', 'ar': 'الألعاب التي تم لعبها'},
    'total_solved': {'en': 'Total Solved', 'id': 'Total Selesai', 'es': 'Total Resueltos', 'pt': 'Total Resolvidos', 'de': 'Gesamt Gelöst', 'fr': 'Total Résolus', 'ja': '合計解決', 'ko': '총 해결', 'zh': '总共解决', 'hi': 'कुल हल', 'ar': 'إجمالي المحلولة'},
    'avg_per_game': {'en': 'Avg per Game', 'id': 'Rata-rata per Game', 'es': 'Promedio por Juego', 'pt': 'Média por Jogo', 'de': 'Durchschnitt', 'fr': 'Moyenne', 'ja': '1ゲーム平均', 'ko': '게임당 평균', 'zh': '场均', 'hi': 'प्रति खेल औसत', 'ar': 'المتوسط لكل لعبة'},
    'time_attack_empty': {
      'en': 'Play Time Attack to see your stats here!',
      'id': 'Main Time Attack untuk melihat statistik di sini!',
      'es': '¡Juega Contra el Reloj para ver tus estadísticas aquí!',
      'pt': 'Jogue Contra o Tempo para ver suas estatísticas aqui!',
      'de': 'Spiele Zeitangriff, um hier deine Statistiken zu sehen!',
      'fr': 'Jouez au Contre-la-montre pour voir vos stats ici!',
      'ja': 'タイムアタックをプレイして統計を表示！',
      'ko': '타임 어택을 플레이하여 여기에서 통계를 확인하세요!',
      'zh': '玩时间挑战，在这里查看你的统计数据！',
      'hi': 'अपने आँकड़े यहाँ देखने के लिए समय चुनौती खेलें!',
      'ar': 'العب تحدي الوقت لرؤية إحصائياتك هنا!'
    },
    'time_attack_title': {'en': 'Time Attack', 'id': 'Serangan Waktu', 'es': 'Contra el Reloj', 'pt': 'Contra o Tempo', 'de': 'Zeitangriff', 'fr': 'Contre-la-montre', 'ja': 'タイムアタック', 'ko': '타임 어택', 'zh': '时间挑战', 'hi': 'समय चुनौती', 'ar': 'تحدي الوقت'},
    'time_attack_desc': {
      'en': 'Solve as many puzzles as you can\nin 60 seconds!',
      'id': 'Selesaikan sebanyak mungkin teka-teki\ndalam 60 detik!',
      'es': '¡Resuelve todos los rompecabezas que puedas\nen 60 segundos!',
      'pt': 'Resolva o máximo de quebra-cabeças que puder\nem 60 segundos!',
      'de': 'Löse so viele Rätsel wie möglich\nin 60 Sekunden!',
      'fr': 'Résolvez autant de puzzles que possible\nen 60 secondes!',
      'ja': '60秒でできるだけ多くの\nパズルを解け！',
      'ko': '60초 안에 가능한 많은\n퍼즐을 해결하세요!',
      'zh': '在60秒内尽可能多地\n解决难题！',
      'hi': '60 सेकंड में अधिक से अधिक\nपहेलियां हल करें!',
      'ar': 'حل أكبر عدد ممكن من الألغاز\nفي 60 ثانية!'
    },
    'bonus_time': {'en': '+5 seconds bonus per solve!', 'id': '+5 detik bonus per soal!', 'es': '¡+5 segundos por resolver!', 'pt': 'Bônus de +5 segundos!', 'de': '+5 Sekunden Bonus!', 'fr': '+5 secondes de bonus!', 'ja': '1問正解で+5秒！', 'ko': '해결 시 +5초 보너스!', 'zh': '每次解决奖励+5秒！', 'hi': 'प्रति हल +5 सेकंड बोनस!', 'ar': '+5 ثوانٍ مكافأة لكل لغز!'},
    'start': {'en': 'START', 'id': 'MULAI', 'es': 'INICIAR', 'pt': 'INICIAR', 'de': 'START', 'fr': 'DÉMARRER', 'ja': 'スタート', 'ko': '시작', 'zh': '开始', 'hi': 'प्रारंभ', 'ar': 'ابدأ'},
    'times_up': {'en': "TIME'S UP!", 'id': 'WAKTU HABIS!', 'es': '¡SE ACABÓ EL TIEMPO!', 'pt': 'FIM DO TEMPO!', 'de': 'ZEIT ABGELAUFEN!', 'fr': 'TEMPS ÉCOULÉ!', 'ja': '時間切れ！', 'ko': '시간 종료!', 'zh': '时间到！', 'hi': 'समय समाप्त!', 'ar': 'انتهى الوقت!'},
    'new_best': {'en': 'NEW BEST!', 'id': 'REKOR BARU!', 'es': '¡NUEVO RÉCORD!', 'pt': 'NOVO RECORDE!', 'de': 'NEUER REKORD!', 'fr': 'NOUVEAU RECORD!', 'ja': '新記録！', 'ko': '신기록!', 'zh': '新纪录！', 'hi': 'नया रिकॉर्ड!', 'ar': 'رقم جديد!'},
    'puzzles_solved_count': {'en': 'PUZZLES SOLVED', 'id': 'SOAL TERPECAHKAN', 'es': 'ROMPECABEZAS RESUELTOS', 'pt': 'QUEBRA-CABEÇAS RESOLVIDOS', 'de': 'RÄTSEL GELÖST', 'fr': 'PUZZLES RÉSOLUS', 'ja': '解いたパズル', 'ko': '해결한 퍼즐', 'zh': '解决的难题', 'hi': 'हल की गई पहेलियां', 'ar': 'الألغاز المحلولة'},
    'again': {'en': 'Again', 'id': 'Lagi', 'es': 'De nuevo', 'pt': 'Novamente', 'de': 'Nochmal', 'fr': 'Encore', 'ja': 'もう一度', 'ko': '다시', 'zh': '再来', 'hi': 'फिर से', 'ar': 'مرة أخرى'},
    'how_to_play_title': {'en': 'HOW TO PLAY', 'id': 'CARA BERMAIN', 'es': 'CÓMO JUGAR', 'pt': 'COMO JOGAR', 'de': 'SPIELANLEITUNG', 'fr': 'COMMENT JOUER', 'ja': '遊び方', 'ko': '플레이 방법', 'zh': '怎么玩', 'hi': 'कैसे खेलें', 'ar': 'كيف تلعب'},
    'goal': {'en': 'Goal', 'id': 'Tujuan', 'es': 'Objetivo', 'pt': 'Objetivo', 'de': 'Ziel', 'fr': 'Objectif', 'ja': '目標', 'ko': '목표', 'zh': '目标', 'hi': 'लक्ष्य', 'ar': 'الهدف'},
    'rules': {'en': 'Rules', 'id': 'Aturan', 'es': 'Reglas', 'pt': 'Regras', 'de': 'Regeln', 'fr': 'Règles', 'ja': 'ルール', 'ko': '규칙', 'zh': '规则', 'hi': 'नियम', 'ar': 'القواعد'},
    'star_rating': {'en': 'Star Rating', 'id': 'Rating Bintang', 'es': 'Calificación', 'pt': 'Classificação', 'de': 'Sternebewertung', 'fr': 'Évaluation', 'ja': '星の評価', 'ko': '별점', 'zh': '星级评价', 'hi': 'स्टार रेटिंग', 'ar': 'تقييم النجوم'},
    'tips_hints': {'en': 'Tips & Hints', 'id': 'Tips & Petunjuk', 'es': 'Consejos', 'pt': 'Dicas', 'de': 'Tipps', 'fr': 'Conseils', 'ja': 'ヒント', 'ko': '팁 & 힌트', 'zh': '提示与技巧', 'hi': 'सुझाव और संकेत', 'ar': 'نصائح وتلميحات'},
    'next': {'en': 'Next', 'id': 'Lanjut', 'es': 'Siguiente', 'pt': 'Próximo', 'de': 'Weiter', 'fr': 'Suivant', 'ja': '次へ', 'ko': '다음', 'zh': '下一步', 'hi': 'अगला', 'ar': 'التالي'},
    'got_it': {'en': 'Got It!', 'id': 'Mengerti!', 'es': '¡Entendido!', 'pt': 'Entendi!', 'de': 'Verstanden!', 'fr': 'Compris!', 'ja': 'わかった！', 'ko': '알겠습니다!', 'zh': '明白了！', 'hi': 'समझ गया!', 'ar': 'فهمت!'},
    'share_text_header': {'en': 'CountiQ — Target:', 'id': 'CountiQ — Target:', 'es': 'CountiQ — Objetivo:', 'pt': 'CountiQ — Alvo:', 'de': 'CountiQ — Ziel:', 'fr': 'CountiQ — Cible:', 'ja': 'CountiQ — 目標:', 'ko': 'CountiQ — 목표:', 'zh': 'CountiQ — 目标:', 'hi': 'CountiQ — लक्ष्य:', 'ar': 'CountiQ — الهدف:'},
    'share_no_hints': {'en': 'No hints!', 'id': 'Tanpa petunjuk!', 'es': '¡Sin pistas!', 'pt': 'Sem dicas!', 'de': 'Keine Tipps!', 'fr': 'Sans indices!', 'ja': 'ヒントなし！', 'ko': '힌트 없음!', 'zh': '没有提示！', 'hi': 'कोई संकेत नहीं!', 'ar': 'بدون تلميحات!'},
    'share_cta': {'en': 'Can you solve it? #CountiQ #MathPuzzle', 'id': 'Bisakah kamu memecahkannya? #CountiQ #MathPuzzle', 'es': '¿Puedes resolverlo? #CountiQ #MathPuzzle', 'pt': 'Consegues resolver? #CountiQ #MathPuzzle', 'de': 'Kannst du es lösen? #CountiQ #MathPuzzle', 'fr': 'Pouvez-vous le résoudre ? #CountiQ #MathPuzzle', 'ja': '解けるかな？ #CountiQ #MathPuzzle', 'ko': '풀 수 있나요? #CountiQ #MathPuzzle', 'zh': '你能解决吗？ #CountiQ #MathPuzzle', 'hi': 'क्या आप इसे हल कर सकते हैं? #CountiQ #MathPuzzle', 'ar': 'هل يمكنك حلها؟ #CountiQ #MathPuzzle'},
    'onboarding_welcome': {'en': 'Welcome to CountiQ!', 'id': 'Selamat Datang di CountiQ!', 'es': '¡Bienvenido a CountiQ!', 'pt': 'Bem-vindo ao CountiQ!', 'de': 'Willkommen bei CountiQ!', 'fr': 'Bienvenue sur CountiQ!', 'ja': 'CountiQへようこそ！', 'ko': 'CountiQ에 오신 것을 환영합니다!', 'zh': '欢迎来到CountiQ！', 'hi': 'CountiQ में आपका स्वागत है!', 'ar': 'مرحبا بك في CountiQ!'},
    'onboarding_subtitle': {
      'en': 'A number puzzle game where you\nreach the target number',
      'id': 'Game teka-teki angka di mana kamu\nharus meraih angka target',
      'es': 'Un juego de números donde debes\nalcanzar el objetivo',
      'pt': 'Um jogo numérico onde deves\nalcançar o alvo',
      'de': 'Ein Zahlenrätsel, bei dem du\ndas Ziel erreichen musst',
      'fr': 'Un jeu de nombres où vous\ndevez atteindre la cible',
      'ja': '目標の数字に到達する\n数字パズルゲーム',
      'ko': '목표 숫자에 도달하는\n숫자 퍼즐 게임',
      'zh': '你需要达到目标数字的\n数字益智游戏',
      'hi': 'एक नंबर पज़ल गेम जहाँ आपको\nलक्ष्य संख्या तक पहुँचना है',
      'ar': 'لعبة لغز الأرقام حيث تصل\nإلى الرقم الهدف'
    },
    'onboarding_how_title': {'en': 'How It Works', 'id': 'Cara Bermain', 'es': 'Cómo Funciona', 'pt': 'Como Funciona', 'de': 'Wie es Funktioniert', 'fr': 'Comment ça Marche', 'ja': '遊び方', 'ko': '게임 방법', 'zh': '怎么玩', 'hi': 'यह कैसे काम करता है', 'ar': 'كيف تعمل'},
    'onboarding_how_step1': {'en': 'Tap a number', 'id': 'Ketuk angka', 'es': 'Toca un número', 'pt': 'Toque num número', 'de': 'Tippe eine Zahl an', 'fr': 'Appuyez sur un nombre', 'ja': '数字をタップ', 'ko': '숫자를 탭하세요', 'zh': '点击数字', 'hi': 'संख्या टैप करें', 'ar': 'اضغط على رقم'},
    'onboarding_how_step2': {'en': 'Pick an operator', 'id': 'Pilih operator', 'es': 'Elige un operador', 'pt': 'Escolha um operador', 'de': 'Wähle einen Operator', 'fr': 'Choisissez un opérateur', 'ja': '演算子を選択', 'ko': '연산자를 선택하세요', 'zh': '选择运算符', 'hi': 'ऑपरेटर चुनें', 'ar': 'اختر عاملا'},
    'onboarding_how_step3': {'en': 'Tap second number', 'id': 'Ketuk angka kedua', 'es': 'Toca el segundo número', 'pt': 'Toque no segundo número', 'de': 'Tippe zweite Zahl an', 'fr': 'Appuyez sur le second nombre', 'ja': '2つ目の数字をタップ', 'ko': '두 번째 숫자를 탭하세요', 'zh': '点击第二个数字', 'hi': 'दूसरी संख्या टैप करें', 'ar': 'اضغط على الرقم الثاني'},
    'onboarding_how_step4': {'en': 'Get the result!', 'id': 'Dapat hasilnya!', 'es': '¡Obtén el resultado!', 'pt': 'Obtém o resultado!', 'de': 'Erhalte das Ergebnis!', 'fr': 'Obtenez le résultat!', 'ja': '結果を取得！', 'ko': '결과를 확인하세요!', 'zh': '得到结果！', 'hi': 'परिणाम प्राप्त करें!', 'ar': 'احصل على النتيجة!'},
    'onboarding_rules_title': {'en': 'The Rules', 'id': 'Aturan Permainan', 'es': 'Las Reglas', 'pt': 'As Regras', 'de': 'Die Regeln', 'fr': 'Les Règles', 'ja': 'ルール', 'ko': '규칙', 'zh': '游戏规则', 'hi': 'नियम', 'ar': 'القواعد'},
    'onboarding_rule1': {'en': 'Each number used ONCE', 'id': 'Setiap angka dipakai SEKALI', 'es': 'Cada número se usa UNA VEZ', 'pt': 'Cada número é usado UMA VEZ', 'de': 'Jede Zahl nur EINMAL', 'fr': 'Chaque nombre est utilisé UNE FOIS', 'ja': '各数字は1回のみ使用可能', 'ko': '각 숫자는 한 번만 사용 가능', 'zh': '每个数字只能使用一次', 'hi': 'प्रत्येक संख्या केवल एक बार प्रयुक्त', 'ar': 'يستخدم كل رقم مرة واحدة'},
    'onboarding_rule2': {'en': 'Whole positive numbers only', 'id': 'Hanya bilangan bulat positif', 'es': 'Solo números enteros positivos', 'pt': 'Apenas números inteiros positivos', 'de': 'Nur positive ganze Zahlen', 'fr': 'Seulement des nombres entiers', 'ja': '正の整数のみ', 'ko': '양의 정수만 가능', 'zh': '仅限正整数', 'hi': 'केवल पूर्ण धनात्मक संख्याएँ', 'ar': 'الأرقام الصحيحة الموجبة فقط'},
    'onboarding_rule3': {'en': 'Only +, −, ×, ÷ allowed', 'id': 'Hanya +, −, ×, ÷ yang boleh', 'es': 'Solo se permiten +, −, ×, ÷', 'pt': 'Apenas +, −, ×, ÷ permitidos', 'de': 'Nur +, −, ×, ÷ erlaubt', 'fr': 'Seulement +, −, ×, ÷', 'ja': '+, −, ×, ÷ のみ許可', 'ko': '+, −, ×, ÷ 만 허용됨', 'zh': '仅允许 +, −, ×, ÷', 'hi': 'केवल +, −, ×, ÷ अनुमत हैं', 'ar': 'يسمح فقط بـ +, −, ×, ÷'},
    'onboarding_ready': {'en': "You're Ready!", 'id': 'Kamu Siap!', 'es': '¡Estás Listo!', 'pt': 'Estás Pronto!', 'de': 'Du bist bereit!', 'fr': 'Vous êtes prêt !', 'ja': '準備完了！', 'ko': '준비 완료!', 'zh': '准备好了！', 'hi': 'आप तैयार हैं!', 'ar': 'أنت جاهز!'},
    'onboarding_ready_desc': {
      'en': 'Solve puzzles, earn stars,\nand challenge yourself daily!',
      'id': 'Pecahkan teka-teki, kumpulkan bintang,\ndan tantang dirimu setiap hari!',
      'es': '¡Resuelve rompecabezas, gana estrellas\ny asume el reto diario!',
      'pt': 'Resolve quebra-cabeças, ganha estrelas\ne desafia-te diariamente!',
      'de': 'Löse Rätsel, verdiene Sterne\nund fordere dich täglich heraus!',
      'fr': 'Résolvez des puzzles, gagnez des étoiles\net mettez-vous au défi !',
      'ja': 'パズルを解いて星を獲得し、\n毎日挑戦しよう！',
      'ko': '퍼즐을 풀고, 별을 모으고,\n매일 도전하세요!',
      'zh': '解决难题，获得星星，\n每天挑战自己！',
      'hi': 'पहेलियां हल करें, सितारे कमाएं,\nऔर प्रतिदिन खुद को चुनौती दें!',
      'ar': 'حل الألغاز، واكسب النجوم،\nوتحدى نفسك يوميا!'
    },
    'onboarding_letsgo': {'en': "LET'S GO!", 'id': 'AYO MAIN!', 'es': '¡VAMOS!', 'pt': 'VAMOS!', 'de': 'LOS GEHT\'S!', 'fr': 'C\'EST PARTI !', 'ja': 'レッツゴー！', 'ko': '시작하기!', 'zh': '开始！', 'hi': 'शुरू करें!', 'ar': 'لننطلق!'},
    'onboarding_skip': {'en': 'Skip', 'id': 'Lewati', 'es': 'Saltar', 'pt': 'Pular', 'de': 'Überspringen', 'fr': 'Passer', 'ja': 'スキップ', 'ko': '건너뛰기', 'zh': '跳过', 'hi': 'छोड़ें', 'ar': 'تخطي'},
  };

  static String get(String key) {
    final map = _strings[key];
    if (map == null) return key;
    return map[_locale] ?? map['en'] ?? key;
  }

  static String get appName => get('app_name');
  static String get appSubtitle => get('app_subtitle');
  static String get play => get('play');
  static String get target => get('target');
  static String get targetReached => get('target_reached');
  static String get tapToStart => get('tap_to_start');
  static String get hint => get('hint');
  static String get skip => get('skip');
  static String get home => get('home');
  static String get share => get('share');
  static String get replay => get('replay');
  static String get puzzleSolved => get('puzzle_solved');
  static String get nextPuzzle => get('next_puzzle');
  static String get dailyChallenge => get('daily_challenge');
  static String get dailyComplete => get('daily_complete');
  static String get settings => get('settings');
}
