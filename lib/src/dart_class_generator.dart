/*
 * Copyright © $YEAR Birju Vachhani
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Author: Birju Vachhani
// Created Date: February 03, 2020

import 'package:meta/meta.dart';

/// Generates dart class code using given data
class DartClassGenerator {
  final String className;
  bool useStatic = false;
  bool useConst = false;
  bool use_underscores = false;
  String prefix = '';
  final Map<String, Object> properties;

  static final String _CAPITALIZE_REGEX = r'(_)(\S)';
  static final String _SPECIAL_SYMBOLS =
      "[,.\\/;'\\[\\]\\-=<>?:\\\"\\{}_+!@#\$%^&*()\\\\|\\s]+";
  static final Pattern _SPECIAL_SYMBOL_REGEX = RegExp(_SPECIAL_SYMBOLS);

  DartClassGenerator(
      {@required this.className,
      @required this.properties,
        this.use_underscores = false,
        this.useConst = true,
        this.useStatic = true,
        this.prefix = ''});

  /// generates dart class code and returns it as a single string
  String generate() {
    var properties_strings = properties.keys.map<String>((name) {
      var str = useStatic ? '\tstatic ' : '\t';
      str += useConst ? 'const ' : '';
      str +=
          'String ${formatName(name)} = \'${formatPath(properties[name])}\';';
      return str;
    }).toList();
    var dart_class = '''// Generated by spider on ${DateTime.now()}
    
class ${className} {
${properties_strings.join('\n')}
}''';
    return dart_class;
  }

  // Formats variable name to be pascal case or with underscores
  // if [use_underscores] is true
  String formatName(String name) {
    // appending prefix if provided any
    name = (prefix.isEmpty ? '' : prefix + '_') + name;
    name = name
        // adds preceding _ for capital letters and lowers them
        .replaceAllMapped(
            RegExp(r'[A-Z]+'), (match) => '_' + match.group(0).toLowerCase())
        // replaces all the special characters with _
        .replaceAll(_SPECIAL_SYMBOL_REGEX, '_')
        // removes _ in the beginning of the name
        .replaceFirst(RegExp(r'^_+'), '')
        // removes any numbers in the beginning of the name
        .replaceFirst(RegExp(r'^[0-9]+'), '')
        // lowers the first character of the string
        .replaceFirstMapped(
            RegExp(r'^[A-Za-z]'), (match) => match.group(0).toLowerCase());
    return use_underscores
        ? name
        : name
            // removes _ and capitalize the next character of the _
            .replaceAllMapped(RegExp(_CAPITALIZE_REGEX),
                (match) => match.group(2).toUpperCase());
  }

  /// formats path string to match with flutter's standards
  String formatPath(String value) => value.replaceAll('\\', '/');
}
