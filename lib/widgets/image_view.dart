// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lzma/lzma.dart';

enum _ImageType {
  asset,
  lzMemory,
  lzSvgMemory,
  memory,
  svgMemory,
  file,
  network,
}

class ImageView extends StatelessWidget {
  const ImageView._({
    super.key,
    required this.type,
    required this.src,
    this.placeHolder,
    this.error,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
  });

  factory ImageView.asset({
    Key? key,
    required String src,
    Widget? placeHolder,
    Widget? error,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.asset,
      src: src,
      placeHolder: placeHolder,
      error: error,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  factory ImageView.lzMemory({
    Key? key,
    required String src,
    Widget? placeHolder,
    Widget? error,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.lzMemory,
      src: src,
      placeHolder: placeHolder,
      error: error,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  factory ImageView.lzSvgMemory({
    Key? key,
    required String src,
    Widget? placeHolder,
    Widget? error,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.lzSvgMemory,
      src: src,
      placeHolder: placeHolder,
      error: error,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  factory ImageView.memory({
    Key? key,
    required Uint8List src,
    Widget? placeHolder,
    Widget? error,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.memory,
      src: src,
      placeHolder: placeHolder,
      error: error,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  factory ImageView.svgMemory({
    Key? key,
    required Uint8List src,
    Widget? placeHolder,
    Widget? error,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.svgMemory,
      src: src,
      placeHolder: placeHolder,
      error: error,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  factory ImageView.file({
    Key? key,
    required String src,
    Widget? placeHolder,
    Widget? error,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.file,
      src: src,
      placeHolder: placeHolder,
      error: error,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  factory ImageView.network({
    Key? key,
    required String src,
    Widget? placeHolder,
    Widget? error,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
  }) {
    return ImageView._(
      key: key,
      type: _ImageType.network,
      src: src,
      placeHolder: placeHolder,
      error: error,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
    );
  }

  final _ImageType type;
  final Widget? placeHolder, error;

  final Object src;

  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final BlendMode colorBlendMode;

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

    if (type == _ImageType.lzMemory) {
      final realSrc = src as String;
      final decoded = base64Decode(realSrc);
      final decompressed = Uint8List.fromList(lzma.decode(decoded));
      return Image.memory(
        decompressed,
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

    if (type == _ImageType.lzSvgMemory) {
      final realSrc = src as String;
      final decoded = base64Decode(realSrc);
      final decompressed = Uint8List.fromList(lzma.decode(decoded));
      return SvgPicture.memory(
        decompressed,
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
        if (state.extendedImageLoadState == LoadState.loading) {
          return placeHolder ?? const SizedBox.shrink();
        }
        if (state.extendedImageLoadState == LoadState.failed) {
          return error ?? placeHolder ?? const SizedBox.shrink();
        }
        return state.completedWidget;
      },
    );
  }
}
