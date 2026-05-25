import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/profile_provider.dart';
import '../providers/onboarding_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final onboardingState = ref.watch(onboardingProvider);
    final turtleName = onboardingState.turtleName;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE2F6F8), // 부드러운 아침 파스텔 하늘색
              Color(0xFFEAF9F9), // 평온한 바다 안개색
              Color(0xFFF7FDFD), // 따뜻한 모래사장 연한 베이지색
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // 화면 타이틀
                const Text(
                  '여행자 가방',
                  style: TextStyle(
                    color: Color(0xFF1E5257),
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ).animate().fade(duration: 400.ms).slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 4),
                const Text(
                  '나의 항해 정보와 소중하게 모아둔 설정을 확인해 보세요.',
                  style: TextStyle(
                    color: Color(0xFF5A7D82),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fade(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // 1. [Top Section - Traveler ID Card]
                _buildTravelerIdCard(context, profile, profileNotifier, turtleName)
                    .animate()
                    .fade(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),

                const SizedBox(height: 32),

                // 2. [Middle Section - Inventory Placeholder]
                _buildInventorySection(context)
                    .animate()
                    .fade(delay: 350.ms, duration: 500.ms),

                const SizedBox(height: 32),

                // 3. [Bottom Section - Settings & Data Management]
                _buildSettingsSection(context, profile, profileNotifier, turtleName)
                    .animate()
                    .fade(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),

                // 바텀바 간섭 방지를 위한 하단 패딩 확보
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 1. 여행자 ID 카드 뷰 ──────────────────────────────────────────
  Widget _buildTravelerIdCard(
    BuildContext context,
    ProfileState profile,
    ProfileNotifier profileNotifier,
    String turtleName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4FA095),
            const Color(0xFF6DEBE1).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E5257).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // 좌측: 부기 캐릭터(🐢) 아바타
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🐢',
                style: TextStyle(fontSize: 44),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 2.seconds,
                curve: Curves.easeInOutQuad,
              ),

          const SizedBox(width: 20),

          // 우측: 항해자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '항해자 ${profile.nickname} 님',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 닉네임 수정 버튼
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        visualDensity: VisualDensity.compact,
                        tooltip: '닉네임 수정',
                        onPressed: () => _showEditNicknameDialog(context, profile, profileNotifier),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${turtleName.isNotEmpty ? "$turtleName부기" : "부기"}와 함께한 지 D+${profile.companionDays}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.accumulatedEnergy} E',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. 가방 속 물건들 섹션 ─────────────────────────────────────────
  Widget _buildInventorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '가방 속 물건들',
              style: TextStyle(
                color: Color(0xFF1E5257),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              '획득한 물건 0/3',
              style: TextStyle(
                color: const Color(0xFF5A7D82).withValues(alpha: 0.8),
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 1행 3열짜리 빈 슬롯
        Row(
          children: [
            _buildInventorySlot('🐚', '바람의 소라', 1),
            const SizedBox(width: 14),
            _buildInventorySlot('🧭', '모험의 나침반', 2),
            const SizedBox(width: 14),
            _buildInventorySlot('🗺️', '비밀 지도', 3),
          ],
        ),
      ],
    );
  }

  // 개별 인벤토리 슬롯
  Widget _buildInventorySlot(String itemEmoji, String itemName, int index) {
    return Expanded(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: const Color(0xFF4FA095).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 투명도 높은 잠금 아이콘
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: const Color(0xFF4FA095).withValues(alpha: 0.25),
                    ),
                  ),
                  // 희미한 물건 형상
                  Opacity(
                    opacity: 0.12,
                    child: Text(
                      itemEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .scale(
                delay: (150 * index).ms,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 6),
          Text(
            itemName,
            style: TextStyle(
              color: const Color(0xFF5A7D82).withValues(alpha: 0.6),
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── 3. 설정 메뉴 섹션 ─────────────────────────────────────────────
  Widget _buildSettingsSection(
    BuildContext context,
    ProfileState profile,
    ProfileNotifier profileNotifier,
    String turtleName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 및 설정',
          style: TextStyle(
            color: Color(0xFF1E5257),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        
        // 둥근 카드 형태의 설정 리스트 그룹화
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: const Color(0xFFE0F2F1).withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E5257).withValues(alpha: 0.03),
                blurRadius: 15.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. 알림 설정
              _buildSettingTile(
                iconWidget: _buildIconCircle(Icons.notifications_active_outlined, Colors.amber),
                title: '알림 설정',
                subtitle: profile.isNotificationsEnabled 
                    ? '매일 ${profile.notificationTime}에 알림 수신 중' 
                    : '알림이 비활성화되어 있습니다',
                trailing: Switch.adaptive(
                  value: profile.isNotificationsEnabled,
                  activeTrackColor: const Color(0xFF4FA095),
                  onChanged: (val) {
                    profileNotifier.toggleNotifications();
                  },
                ),
                onTap: () {
                  if (profile.isNotificationsEnabled) {
                    _showTimePicker(context, profile, profileNotifier, turtleName);
                  } else {
                    profileNotifier.toggleNotifications();
                  }
                },
              ),
              _buildDivider(),

              // 2. 데이터 동기화 및 백업
              _buildSettingTile(
                iconWidget: _buildIconCircle(Icons.cloud_sync_outlined, Colors.blue),
                title: '데이터 동기화 및 백업',
                subtitle: '소중한 마음 기록을 클라우드에 보관',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '마지막 백업: ${profile.lastBackupTime}',
                      style: TextStyle(
                        color: profile.lastBackupTime == '백업 중...'
                            ? const Color(0xFF4FA095)
                            : const Color(0xFF8BA6A1),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (profile.lastBackupTime == '백업 중...')
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FA095)),
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right, color: Color(0xFF8BA6A1), size: 16),
                  ],
                ),
                onTap: profile.lastBackupTime == '백업 중...'
                    ? null
                    : () => _showBackupConfirmDialog(context, profileNotifier),
              ),
              _buildDivider(),

              // 3. 공지사항 및 업데이트
              _buildSettingTile(
                iconWidget: _buildIconCircle(Icons.campaign_outlined, Colors.teal),
                title: '공지사항 및 업데이트',
                subtitle: '부기온앤온의 새로운 여정 정보',
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF8BA6A1), size: 18),
                onTap: () => _showNoticeDialog(context),
              ),
              _buildDivider(),

              // 4. 로그아웃
              _buildSettingTile(
                iconWidget: _buildIconCircle(Icons.logout_rounded, Colors.redAccent),
                title: '로그아웃',
                titleColor: Colors.redAccent.shade700,
                subtitle: '기기가 변경되더라도 백업 코드로 보관됩니다',
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF8BA6A1), size: 18),
                onTap: () => _showLogoutConfirmDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 개별 설정 타일 헬퍼
  Widget _buildSettingTile({
    required Widget iconWidget,
    required String title,
    Color? titleColor,
    required String subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? const Color(0xFF1E5257),
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8BA6A1),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  // 아이콘 원형 데코레이터
  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color.withValues(alpha: 0.85),
        size: 19,
      ),
    );
  }

  // 얇은 구분선
  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFFE0F2F1).withValues(alpha: 0.5),
      height: 1,
      thickness: 1.0,
      indent: 62,
      endIndent: 16,
    );
  }

  // ─── 4. 인터랙티브 팝업창 모음 ──────────────────────────────────────────

  // 닉네임 수정 다이얼로그
  void _showEditNicknameDialog(
    BuildContext context,
    ProfileState profile,
    ProfileNotifier profileNotifier,
  ) {
    final controller = TextEditingController(text: profile.nickname);
    showDialog(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: AlertDialog(
          backgroundColor: const Color(0xFFF7FDFD),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          title: const Row(
            children: [
              Text('🐢 ', style: TextStyle(fontSize: 20)),
              Text(
                '닉네임 변경',
                style: TextStyle(
                  color: Color(0xFF1E5257),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '항해에 어울리는 새로운 닉네임을 설정해 주세요.',
                style: TextStyle(
                  color: Color(0xFF5A7D82),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLength: 8,
                decoration: InputDecoration(
                  hintText: '새로운 이름 입력 (최대 8글자)',
                  hintStyle: const TextStyle(color: Color(0xFF8BA6A1), fontSize: 13.5),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Color(0xFF4FA095), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Color(0xFF4FA095), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Color(0xFFE0F2F1), width: 1.5),
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF1E5257),
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Color(0xFF8BA6A1), fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FA095),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                elevation: 0,
              ),
              onPressed: () {
                final trimmedText = controller.text.trim();
                if (trimmedText.isNotEmpty) {
                  profileNotifier.updateNickname(trimmedText);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('닉네임이 "$trimmedText" 님으로 변경되었습니다.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF4FA095),
                    ),
                  );
                }
              },
              child: const Text('저장', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 백업 실행 확인 팝업
  void _showBackupConfirmDialog(BuildContext context, ProfileNotifier profileNotifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7FDFD),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Text(
          '☁️ 데이터 클라우드 동기화',
          style: TextStyle(
            color: Color(0xFF1E5257),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '작성하신 소중한 항해 일지와 마음 상태 데이터가 안전하게 동기화 서버로 백업됩니다. 진행하시겠습니까?',
          style: TextStyle(
            color: Color(0xFF5A7D82),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              '취소',
              style: TextStyle(color: Color(0xFF8BA6A1), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FA095),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              profileNotifier.triggerBackup();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('클라우드 서버에 백업을 진행하고 있습니다...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFF4FA095),
                ),
              );
            },
            child: const Text('백업 시작', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 알림 시간 선택 팝업
  Future<void> _showTimePicker(
    BuildContext context,
    ProfileState profile,
    ProfileNotifier profileNotifier,
    String turtleName,
  ) async {
    // 임시로 편리하게 30분 단위의 시간대를 직접 고르는 다정하고 예쁜 바텀시트 제작
    final times = [
      '오전 08:00',
      '오전 09:00',
      '오후 18:00',
      '오후 20:00',
      '오후 21:00',
      '오후 22:00',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF7FDFD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔔 알림 수신 시간 선택',
                style: TextStyle(
                  color: Color(0xFF1E5257),
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${turtleName.isNotEmpty ? "$turtleName부기" : "부기"}가 항해를 점검하러 올 아름다운 저녁 또는 아침 시간을 정해보세요.',
                style: const TextStyle(
                  color: Color(0xFF5A7D82),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: times.length,
                  itemBuilder: (itemCtx, index) {
                    final time = times[index];
                    final isSelected = profile.notificationTime == time;
                    return InkWell(
                      onTap: () {
                        profileNotifier.updateNotificationTime(time);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('알림 시간이 $time으로 변경되었습니다.'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFF4FA095),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        margin: const EdgeInsets.only(bottom: 6.0),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF4FA095).withValues(alpha: 0.1) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF4FA095).withValues(alpha: 0.3) 
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              time,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF1E5257) : const Color(0xFF2E4E52),
                                fontSize: 14.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF4FA095),
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 공지사항 다이얼로그
  void _showNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7FDFD),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Text(
          '📜 공지사항 및 업데이트',
          style: TextStyle(
            color: Color(0xFF1E5257),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNoticeItem('v1.1.0 업데이트 예고', '더 다정한 익명 커뮤니티 "고수들의 바다" 릴레이 답장 및 줄노트 편지지 도입!'),
            const SizedBox(height: 14),
            _buildNoticeItem('안전한 마음 보관소 운영 안내', '부기온앤온의 모든 정보는 서버에 암호화되어 보관되며 익명성이 보장됩니다.'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FA095),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 공지사항 아이템 빌더
  Widget _buildNoticeItem(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE0F2F1), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E5257),
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF5A7D82),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃 다이얼로그
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7FDFD),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Text(
          '🚪 로그아웃',
          style: TextStyle(
            color: Color(0xFF1E5257),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '정말 로그아웃을 진행하시겠습니까? 데이터 동기화 백업이 무사히 진행되었는지 먼저 확인하시는 것을 권장합니다.',
          style: TextStyle(
            color: Color(0xFF5A7D82),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              '취소',
              style: TextStyle(color: Color(0xFF8BA6A1), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('정상적으로 로그아웃되었습니다.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.redAccent.shade700,
                ),
              );
            },
            child: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
