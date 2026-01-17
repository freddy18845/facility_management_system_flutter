import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/dailogs/profile.dart';
import '../providers/app_Manager.dart';
import '../utils/app_theme.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool _isHoveringProfile = false;

  bool get _isDesktop =>
      kIsWeb || MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isMobile = size.width < 600;
    final avatarSize = isMobile ? 32.0 : 38.0;

    return MouseRegion(
      onEnter: _isDesktop ? (_) => setState(() => _isHoveringProfile = true) : null,
      onExit: _isDesktop ? (_) => setState(() => _isHoveringProfile = false) : null,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => ProfileDialog.show(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: !_isHoveringProfile
                ? Theme.of(context).focusColor.withOpacity(0.4)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    "assets/images/profile.png",
                    height: avatarSize,
                    width: avatarSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              if (!isMobile) ...[
                const SizedBox(width: 8),

                // User info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      capitalizeFirst(
                        AppManager().loginResponse["user"]["first_name"],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isHoveringProfile
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 140,
                      child: Text(
                        AppManager().loginResponse["user"]["email"],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color:!_isHoveringProfile
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_isHoveringProfile)
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue,
                    size: 22,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
