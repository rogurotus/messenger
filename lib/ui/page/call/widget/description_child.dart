// Copyright © 2022-2023 IT ENGINEERING MANAGEMENT INC,
//                       <https://github.com/team113>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

import 'package:flutter/material.dart';

import '/themes.dart';

/// [Widget] displaying its [child] with the provided [description].
class DescriptionChild extends StatelessWidget {
  const DescriptionChild({
    super.key,
    this.show = true,
    this.description,
    required this.child,
  });

  /// [Widget] displayed along with the description.
  final Widget child;

  /// Description of the [child].
  final String? description;

  /// Indicator whether the [description] should be showed.
  final bool show;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        if (description != null)
          DefaultTextStyle(
            style: style.fonts.small.regular.onPrimary,
            textAlign: TextAlign.center,
            maxLines: 2,
            child: AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(description!),
            ),
          ),
      ],
    );
  }
}
