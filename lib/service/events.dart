class TriggerLogin {}

class ChangeTheme {
  ChangeTheme(this.val);

  final bool val;
}

class MainButtonNavDoubleClickToTop {
  final MainStack key;

  MainButtonNavDoubleClickToTop(this.key);
}

enum MainStack { home, ugc }

class HomeTabScrollToTop {
  final HomeTab key;

  HomeTabScrollToTop(this.key);
}

enum HomeTab { recommend, lasted }
