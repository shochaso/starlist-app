import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starlist/features/registration/application/profile_info_provider.dart';
import 'package:starlist/features/registration/presentation/widgets/registration_progress_indicator.dart';

class ProfileInfoScreen extends ConsumerWidget {
  const ProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileInfoProvider);
    final notifier = ref.read(profileInfoProvider.notifier);

    final genres = [
      '俳優/女優', '歌手/ミュージシャン', 'モデル', '芸人/タレント', '声優', 'アイドル',
      'インフルエンサー', 'YouTuber', 'VTuber', 'ストリーマー', 'ゲーマー', 'クリエイター',
      'イラストレーター', '漫画家', 'コスプレイヤー', 'アスリート', '専門家 (士業等)', 'その他'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール情報'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/basic-info');
            }
          },
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: RegistrationProgressIndicator(currentStep: 3),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'プロフィール情報',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'あなたの活動について教えてください。ファンがあなたをより深く知る手助けになります。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Profile Image Picker
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: notifier.pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: state.profileImage != null
                          ? FileImage(File(state.profileImage!.path))
                          : null,
                      child: state.profileImage == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: notifier.pickImage,
                    child: const Text('プロフィール写真を選択'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Genre Selection
            const Text('主な活動ジャンル (複数選択可)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: genres.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = state.selectedGenres.contains(genre);
                return GestureDetector(
                  onTap: () => notifier.toggleGenre(genre),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: Colors.blue) : null,
                    ),
                    child: Center(
                      child: Text(
                        genre,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.blue : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
             const SizedBox(height: 24),

            // Date of Birth
            const Text('生年月日 (任意)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: state.dateOfBirth ?? DateTime.now(),
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  notifier.setDateOfBirth(picked);
                }
              },
              child: Text(
                state.dateOfBirth != null
                    ? '${state.dateOfBirth!.year}年${state.dateOfBirth!.month}月${state.dateOfBirth!.day}日'
                    : '日付を選択',
              ),
            ),
            const SizedBox(height: 24),

            // Gender Selection
            const Text('性別 (必須)', style: TextStyle(fontWeight: FontWeight.bold)),
            ...Gender.values.map((gender) => RadioListTile<Gender>(
                  title: Text(_genderToString(gender)),
                  value: gender,
                  groupValue: state.gender,
                  onChanged: (Gender? value) {
                    if (value != null) {
                      notifier.setGender(value);
                    }
                  },
                )),
            const SizedBox(height: 24),
            
            // Agency Affiliation
            const Text('芸能・ライバー事務所への所属', style: TextStyle(fontWeight: FontWeight.bold)),
             RadioListTile<bool>(
                  title: const Text('はい'),
                  value: true,
                  groupValue: state.isAffiliated,
                  onChanged: (value) => notifier.setAffiliation(true),
                ),
            RadioListTile<bool>(
                  title: const Text('いいえ'),
                  value: false,
                  groupValue: state.isAffiliated,
                  onChanged: (value) => notifier.setAffiliation(false),
                ),

            if (state.isAffiliated)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  onChanged: notifier.updateAgencyName,
                  decoration: const InputDecoration(
                    hintText: '事務所名を入力',
                  ),
                ),
              ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: state.isFormValid
                  ? () => context.go('/verification')
                  : null,
              child: const Text('次へ進む'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _genderToString(Gender gender) {
    switch (gender) {
      case Gender.male:
        return '男性';
      case Gender.female:
        return '女性';
      case Gender.other:
        return 'その他';
      case Gender.preferNotToSay:
        return '回答しない';
    }
  }
} 