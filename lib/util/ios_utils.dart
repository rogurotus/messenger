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

import 'package:flutter/services.dart';

/// Helper providing direct access to iOS-only features.
class IosUtils {
  /// [MethodChannel] to communicate with iOS via.
  static const platform = MethodChannel('team113.flutter.dev/ios_utils');

  /// Returns the architecture of this device.
  static Future<String> getArchitecture() async {
    return await platform.invokeMethod('getArchitecture');
  }
}
