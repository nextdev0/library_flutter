// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef NetworkImageWidgetBuilder = Widget Function(Widget, NetworkImageState);

enum _ImageType {
  asset,
  memory,
  svgMemory,
  file,
  network,
}

enum NetworkImageState {
  loading,
  error,
  done,
}

class ImageView extends StatelessWidget {
  const ImageView._({
    super.key,
    required this.type,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.placeHolder,
    this.error,
    this.networkBuilder,
  });

  factory ImageView.asset({
    Key? key,
    required String src,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    Widget? placeHolder,
    Widget? error,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.asset,
      src: src,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      placeHolder: placeHolder,
      error: error,
    );
  }

  factory ImageView.memory({
    Key? key,
    required Uint8List src,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    Widget? placeHolder,
    Widget? error,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.memory,
      src: src,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      placeHolder: placeHolder,
      error: error,
    );
  }

  factory ImageView.svgMemory({
    Key? key,
    required Uint8List src,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    Widget? placeHolder,
    Widget? error,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.svgMemory,
      src: src,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      placeHolder: placeHolder,
      error: error,
    );
  }

  factory ImageView.file({
    Key? key,
    required File src,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    Widget? placeHolder,
    Widget? error,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.file,
      src: src,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      placeHolder: placeHolder,
      error: error,
    );
  }

  factory ImageView.network({
    Key? key,
    required String src,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    Widget? placeHolder,
    Widget? error,
    NetworkImageWidgetBuilder? networkBuilder,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.network,
      src: src,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      placeHolder: placeHolder,
      error: error,
      networkBuilder: networkBuilder,
    );
  }

  final _ImageType type;
  final Object src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final BlendMode colorBlendMode;
  final Widget? placeHolder;
  final Widget? error;
  final NetworkImageWidgetBuilder? networkBuilder;

  @override
  Widget build(BuildContext context) {
    if (type == _ImageType.asset) {
      final realSrc = src as String;
      if (realSrc.trim().endsWith('svg')) {
        return SvgPicture.asset(
          realSrc,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          color: color,
          colorBlendMode: colorBlendMode,
          placeholderBuilder: (_) =>
              error ?? placeHolder ?? const SizedBox.shrink(),
        );
      }

      return Image.asset(
        realSrc,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (_, __, ___) =>
            error ?? placeHolder ?? const SizedBox.shrink(),
      );
    }

    if (type == _ImageType.memory) {
      final realSrc = src as Uint8List;
      return Image.memory(
        realSrc,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (_, __, ___) =>
            error ?? placeHolder ?? const SizedBox.shrink(),
      );
    }

    if (type == _ImageType.svgMemory) {
      final realSrc = src as Uint8List;
      return SvgPicture.memory(
        realSrc,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        placeholderBuilder: (_) =>
            error ?? placeHolder ?? const SizedBox.shrink(),
      );
    }

    if (type == _ImageType.file) {
      final realSrc = src as String;
      if (realSrc.trim().endsWith('svg')) {
        return SvgPicture.file(
          File(realSrc),
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          color: color,
          colorBlendMode: colorBlendMode,
          placeholderBuilder: (_) =>
              error ?? placeHolder ?? const SizedBox.shrink(),
        );
      }

      return Image.file(
        File(realSrc),
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (_, __, ___) =>
            error ?? placeHolder ?? const SizedBox.shrink(),
      );
    }

    return ExtendedImage.network(
      src as String,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      loadStateChanged: (state) {
        final imageWidget = state.extendedImageLoadState == LoadState.loading
            ? placeHolder ?? const SizedBox.shrink()
            : state.extendedImageLoadState == LoadState.failed
                ? error ?? placeHolder ?? const SizedBox.shrink()
                : state.completedWidget;
        return (networkBuilder ?? _defaultNetworkWidgetBuilder)(
          imageWidget,
          state.extendedImageLoadState == LoadState.loading
              ? NetworkImageState.loading
              : state.extendedImageLoadState == LoadState.failed
                  ? NetworkImageState.error
                  : NetworkImageState.done,
        );
      },
    );
  }

  static Widget _defaultNetworkWidgetBuilder(
    Widget imageWidget,
    NetworkImageState state,
  ) {
    return AnimatedOpacity(
      opacity: state == NetworkImageState.loading ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: imageWidget,
    );
  }
}
