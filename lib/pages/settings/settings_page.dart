import 'dart:io';

import 'package:flutter/material.dart';
import 'package:playboy/backend/storage.dart';
import 'package:playboy/l10n/i10n.dart';
import 'package:playboy/pages/settings/about_app.dart';
import 'package:playboy/pages/settings/bvtools_settings.dart';
import 'package:playboy/pages/settings/display_settings.dart';
import 'package:playboy/pages/settings/keymap_settings.dart';
import 'package:playboy/pages/settings/language_settings.dart';
import 'package:playboy/pages/settings/player_settings.dart';
import 'package:playboy/pages/settings/storage_settings.dart';
import 'package:playboy/pages/settings/developer_settings.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int _currentPage = 0;
  final List<IconData> _icons = [
    Icons.color_lens_outlined,
    Icons.play_circle_outline,
    Icons.keyboard_command_key,
    Icons.folder_outlined,
    Icons.translate_rounded,
    Icons.extension_outlined,
    Icons.info_outline,
    Icons.code_outlined,
  ];
  final List<Widget> _pages = [
    const DisplaySettingsPage(),
    const PlayerSettingsPage(),
    const KeymapSettings(),
    const StorageSettingsPage(),
    const LanguageSettingsPage(),
    const ExtensionSettings(),
    const AboutPage(),
    const DeveloperSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    // late final colorScheme = Theme.of(context).colorScheme;
    // late final backgroundColor = Color.alphaBlend(
    //     colorScheme.primary.withOpacity(0.08), colorScheme.surface);
    List<String> options = [
      context.l10n.appearance,
      context.l10n.player,
      '快捷键',
      context.l10n.storage,
      context.l10n.language,
      '扩展功能',
      context.l10n.about,
      'Developer',
    ];
    return Scaffold(
      appBar: !AppStorage().settings.enableTitleBar
          ? AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              toolbarHeight: 10 + AppStorage().settings.titleBarOffset,
            )
          : AppBar(
              leadingWidth: 40,
              automaticallyImplyLeading: false,
              leading: IconButton(
                iconSize: 20,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              titleSpacing: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              scrolledUnderElevation: 0,
              flexibleSpace: Column(
                children: [
                  SizedBox(
                    height: 8,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeUp,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          windowManager.startResizing(ResizeEdge.top);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (details) {
                        windowManager.startDragging();
                      },
                    ),
                  )
                ],
              ),
              toolbarHeight: 40,
              actions: [
                IconButton(
                    hoverColor: Colors.transparent,
                    iconSize: 20,
                    onPressed: () {
                      windowManager.minimize();
                    },
                    icon: const Icon(Icons.minimize)),
                IconButton(
                    hoverColor: Colors.transparent,
                    iconSize: 20,
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                    icon: const Icon(Icons.crop_square)),
                IconButton(
                    hoverColor: Colors.transparent,
                    iconSize: 20,
                    onPressed: () {
                      windowManager.close();
                    },
                    icon: const Icon(Icons.close)),
              ],
            ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          SizedBox(
              width: 160,
              child: Column(
                children: [
                  if (Platform.isAndroid)
                    const SizedBox(
                      height: 40,
                    ),
                  Container(
                      alignment: Alignment.topLeft,
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        context.l10n.settings,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: buildSettings(options),
                  )
                ],
              )),
          Expanded(
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _pages[_currentPage],
            )),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     heroTag: 'settings',
      //     backgroundColor: colorScheme.onTertiary,
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Icon(Icons.home_filled)),
    );
  }

  Widget buildSettings(List<String> options) {
    late final colorScheme = Theme.of(context).colorScheme;
    Widget buildItem(int id, String name, IconData icon) {
      final bool selected = id == _currentPage;
      return Material(
        color: selected ? colorScheme.secondary : null,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            setState(() {
              _currentPage = id;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
                child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Icon(
                  icon,
                  color: selected ? colorScheme.onSecondary : null,
                  size: 22,
                ),
                const SizedBox(
                  width: 14,
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: selected ? colorScheme.onSecondary : null,
                    fontSize: 16,
                  ),
                )
              ],
            )),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _icons.length,
      itemBuilder: (context, index) =>
          buildItem(index, options[index], _icons[index]),
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 6,
        );
      },
    );
  }
}
