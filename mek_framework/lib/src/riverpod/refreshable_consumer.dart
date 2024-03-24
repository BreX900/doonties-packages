// import 'package:flutter/cupertino.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mek/src/riverpod/riverpod_extensions.dart';
//
// class ProviderInvalidator extends ConsumerStatefulWidget {
//   final ProviderBase<Object?> provider;
//   final Widget child;
//
//   const ProviderInvalidator({
//     super.key,
//     required this.provider,
//     required this.child,
//   });
//
//   @override
//   ConsumerState<ProviderInvalidator> createState() => _ProviderRefresherState();
// }
//
// class _ProviderRefresherState extends ConsumerState<ProviderInvalidator> {
//   late bool _exist;
//   bool? _isCurrent;
//
//   @override
//   void initState() {
//     super.initState();
//     _exist = ref.exists(widget.provider);
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final isCurrent = ModalRoute.of(context)?.isCurrent;
//
//     if (_isCurrent != isCurrent) {
//       _isCurrent = isCurrent;
//       if (_isCurrent ?? false) {
//         invalidate();
//       }
//     }
//   }
//
//   void invalidate() {
//     ProviderScope.containerOf(context, listen: false).invalidateFrom(widget.provider);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
//
// mixin ProviderInvalidatorMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
//   late ProviderBase<Object?> _provider;
//   // late bool _exist;
//   bool? _isCurrent;
//
//   ProviderBase<Object?> get provider;
//
//   @override
//   void initState() {
//     super.initState();
//     _provider = provider;
//     final exist = ref.exists(provider);
//     print('${widget.runtimeType}.initState _exist:$exist _isCurrent:$_isCurrent');
//     if (exist) invalidate();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final isCurrent = ModalRoute.of(context)?.isCurrent;
//
//     if (_isCurrent != isCurrent) {
//       final isOldCurrent = _isCurrent;
//       _isCurrent = isCurrent;
//
//       if (isOldCurrent == null) return;
//       print('${widget.runtimeType}.didChangeDependencies _isCurrent:$_isCurrent');
//       if (_isCurrent ?? false) invalidate();
//     }
//   }
//
//   @override
//   void didUpdateWidget(covariant T oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (_provider != provider) {
//       _provider = provider;
//       final exist = ref.exists(provider);
//       print('${widget.runtimeType}.didUpdateWidget _exist:$exist _isCurrent:$_isCurrent');
//       if (exist && (_isCurrent ?? false)) invalidate();
//     }
//   }
//
//   void invalidate() {
//     ProviderScope.containerOf(context, listen: false).invalidateFrom(_provider);
//   }
// }
