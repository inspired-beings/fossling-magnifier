import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:floss_magnifier/l10n/generated/app_localizations.dart';

import '../features/magnifier/components/camera_error_view.dart';
import '../features/magnifier/components/camera_view.dart';
import '../features/magnifier/components/control_bar.dart';
import '../features/magnifier/components/frozen_view.dart';
import '../features/magnifier/components/torch_button.dart';
import '../features/magnifier/libs/magnifier_camera.dart';
import '../features/magnifier/libs/plugin_magnifier_camera.dart';
import '../features/magnifier/magnifier_state.dart';
import '../features/magnifier/types.dart';

class MagnifierScreen extends StatefulWidget {
  const MagnifierScreen({super.key, this.createCamera});

  final MagnifierCamera Function()? createCamera;

  @override
  State<MagnifierScreen> createState() => _MagnifierScreenState();
}

sealed class _ScreenStatus {}

class _Initializing extends _ScreenStatus {}

class _Ready extends _ScreenStatus {}

class _PermissionDenied extends _ScreenStatus {}

class _Failed extends _ScreenStatus {}

class _MagnifierScreenState extends State<MagnifierScreen>
    with WidgetsBindingObserver {
  late MagnifierCamera _camera;
  MagnifierState? _state;
  _ScreenStatus _status = _Initializing();
  bool _releasedByLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _camera = (widget.createCamera ?? PluginMagnifierCamera.new)();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() => _status = _Initializing());
    try {
      await _camera.initialize();
      if (!mounted) return;
      final previous = _state;
      final state = MagnifierState(minZoom: _camera.minZoom, maxZoom: _camera.maxZoom);
      // Survive a lifecycle re-init without losing a frozen still.
      if (previous != null && previous.mode.value is FrozenMode) {
        state.freeze((previous.mode.value as FrozenMode).imagePath);
      }
      previous?.dispose();
      state.zoom.addListener(() => _camera.setZoom(state.zoom.value));
      setState(() {
        _state = state;
        _status = _Ready();
      });
    } on CameraPermissionDeniedException {
      if (!mounted) return;
      setState(() => _status = _PermissionDenied());
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _Failed());
    }
  }

  Future<void> _retry() async {
    await _camera.dispose();
    await _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final state = _state;
    if (lifecycleState == AppLifecycleState.paused) {
      state?.isTorchOn.value = false;
      _camera.dispose();
      _releasedByLifecycle = true;
      // Never leave the live preview pointing at a disposed camera.
      if (_status is _Ready && state != null && state.mode.value is LiveMode && mounted) {
        setState(() => _status = _Initializing());
      }
    } else if (lifecycleState == AppLifecycleState.resumed &&
        state != null &&
        _releasedByLifecycle) {
      _releasedByLifecycle = false;
      _initCamera();
    }
  }

  Future<void> _freeze() async {
    final l10n = AppLocalizations.of(context);
    try {
      final path = await _camera.takePicture();
      _state!.freeze(path);
      if (!mounted) return;
      SemanticsService.sendAnnouncement(
          View.of(context), l10n.imageFrozenAnnouncement, TextDirection.ltr);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.captureFailed)));
    }
  }

  void _resume() {
    _state!.resume();
    SemanticsService.sendAnnouncement(
        View.of(context), AppLocalizations.of(context).imageLiveAnnouncement, TextDirection.ltr);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera.dispose();
    _state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (_status) {
        _Initializing() => const Center(child: CircularProgressIndicator()),
        _PermissionDenied() => CameraErrorView(
            title: l10n.permissionTitle,
            body: l10n.permissionBody,
            buttonLabel: l10n.permissionRetry,
            onRetry: _retry,
          ),
        _Failed() => CameraErrorView(
            title: l10n.cameraErrorTitle,
            buttonLabel: l10n.cameraErrorRetry,
            onRetry: _retry,
          ),
        _Ready() => _buildReady(l10n),
      },
    );
  }

  Widget _buildReady(AppLocalizations l10n) {
    final state = _state!;
    return ValueListenableBuilder<MagnifierMode>(
      valueListenable: state.mode,
      builder: (context, mode, _) => switch (mode) {
        FrozenMode(:final imagePath) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _resume();
            },
            child: FrozenView(image: FileImage(File(imagePath)), onResume: _resume),
          ),
        LiveMode() => Stack(
            fit: StackFit.expand,
            children: [
              CameraView(camera: _camera, state: state, onFocus: _camera.setFocusPoint),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _camera.hasTorch
                        ? TorchButton(state: state, onChanged: _camera.setTorch)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ValueListenableBuilder<double>(
                      valueListenable: state.zoom,
                      builder: (context, zoom, _) => Semantics(
                        button: true,
                        label: l10n.zoomReset,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            foregroundColor: Colors.black,
                            minimumSize: const Size(64, 48),
                          ),
                          onPressed: state.resetZoom,
                          child: Text('${zoom.toStringAsFixed(1)}×',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ControlBar(state: state, onFreeze: _freeze),
              ),
            ],
          ),
      },
    );
  }
}
