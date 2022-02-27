import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageView extends StatelessWidget {
  const ImageView._({
    Key? key,
    required this.isAssetImage,
    required this.src,
    this.placeHolder,
    this.error,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
  }) : super(key: key);

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
      isAssetImage: true,
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
      isAssetImage: false,
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

  final bool isAssetImage;
  final Widget? placeHolder, error;

  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final BlendMode colorBlendMode;

  @override
  Widget build(BuildContext context) {
    if (isAssetImage) {
      if (src.trim().endsWith('svg')) {
        return SvgPicture.asset(
          src,
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
        src,
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
      src,
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
