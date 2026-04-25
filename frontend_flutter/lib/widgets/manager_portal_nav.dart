/// Controller that lets the app shell's back button pop one level inside the
/// Student Manager Portal (from a sub-pane back to the portal's tool grid)
/// before leaving the portal entirely.
///
/// The portal section registers a handler via [attach] when it is shown, and
/// removes it via [detach] when disposed. The shell calls [tryPop] before it
/// would otherwise leave the portal; if the portal has an inner pane to close
/// the handler closes it and returns `true`, signalling "consumed, do not
/// pop the portal view itself".
class ManagerPortalBackController {
  bool Function()? _handler;

  void attach(bool Function() handler) {
    _handler = handler;
  }

  void detach(bool Function() handler) {
    if (identical(_handler, handler)) {
      _handler = null;
    }
  }

  bool tryPop() {
    final h = _handler;
    if (h == null) return false;
    return h();
  }
}
