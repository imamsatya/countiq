import os
import re

files = {
    'home_screen.dart': {'type': 'ConsumerStatefulWidget', 'needs_import': True},
    'level_select_screen.dart': {'type': 'StatefulWidget', 'needs_import': True},
    'achievements_screen.dart': {'type': 'StatelessWidget', 'needs_import': True},
    'how_to_play_screen.dart': {'type': 'StatefulWidget', 'needs_import': True},
    'statistics_screen.dart': {'type': 'StatelessWidget', 'needs_import': True},
    'campaign_game_screen.dart': {'type': 'StatefulWidget', 'needs_import': True},
    'daily_challenge_screen.dart': {'type': 'StatefulWidget', 'needs_import': True},
    'time_attack_screen.dart': {'type': 'StatefulWidget', 'needs_import': True},
    'game_screen.dart': {'type': 'ConsumerStatefulWidget', 'needs_import': True},
    'result_screen.dart': {'type': 'ConsumerStatefulWidget', 'needs_import': True},
}

screens_dir = 'lib/presentation/screens'

for filename, info in files.items():
    filepath = os.path.join(screens_dir, filename)
    if not os.path.exists(filepath):
        continue
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Add imports if missing
    if 'flutter_riverpod.dart' not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';")
    if 'locale_provider.dart' not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../providers/locale_provider.dart';")
    
    # Replace StatefulWidget -> ConsumerStatefulWidget
    if info['type'] == 'StatefulWidget':
        content = re.sub(r'class\s+(\w+)\s+extends\s+StatefulWidget', r'class \1 extends ConsumerStatefulWidget', content)
        content = re.sub(r'class\s+_(\w+)\s+extends\s+State<(\w+)>', r'class _\1 extends ConsumerState<\2>', content)
        content = re.sub(r'State<(\w+)>', r'ConsumerState<\1>', content)
    
    # Replace StatelessWidget -> ConsumerWidget
    if info['type'] == 'StatelessWidget':
        content = re.sub(r'class\s+(\w+)\s+extends\s+StatelessWidget', r'class \1 extends ConsumerWidget', content)
        content = re.sub(r'Widget\s+build\(BuildContext\s+context\)', r'Widget build(BuildContext context, WidgetRef ref)', content)
    
    # Inject ref.watch(localeProvider); at the start of the build method
    # For Stateful/ConsumerStateful: Widget build(BuildContext context) {
    # For Stateless/Consumer: Widget build(BuildContext context, WidgetRef ref) {
    
    if info['type'] in ['StatefulWidget', 'ConsumerStatefulWidget']:
        # Find Widget build(BuildContext context) {
        content = re.sub(r'(Widget\s+build\(BuildContext\s+context\)\s*\{)', r'\1\n    ref.watch(localeProvider);', content)
    elif info['type'] in ['StatelessWidget', 'ConsumerWidget']:
        content = re.sub(r'(Widget\s+build\(BuildContext\s+context,\s*WidgetRef\s+ref\)\s*\{)', r'\1\n    ref.watch(localeProvider);', content)

    # Some widgets might already have been converted or have slightly different signatures, let's just make sure it's injected if not present.
    # To avoid double injection, we could do:
    if 'ref.watch(localeProvider);' not in content:
        # Actually my regex above just did it, let's clean up if there's any duplication manually, 
        pass

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Processed {filename}")
