// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// The physics of a FolderView scrollbar's own scroll view: it stops at the
/// ends as [ClampingScrollPhysics] does, and leaves everything else, the fling
/// included, to the physics it is applied to.
class FolderViewBarScrollPhysics extends ScrollPhysics {
  const FolderViewBarScrollPhysics({super.parent});

  @override
  FolderViewBarScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      FolderViewBarScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) =>
      const ClampingScrollPhysics().applyBoundaryConditions(position, value);
}
