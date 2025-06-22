import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/voting_providers.dart';
import '../../../features/auth/providers/user_provider.dart';

/// 投票投稿作成画面
class CreateVotingPostScreen extends ConsumerStatefulWidget {
  const CreateVotingPostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateVotingPostScreen> createState() => _CreateVotingPostScreenState();
}

class _CreateVotingPostScreenState extends ConsumerState<CreateVotingPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionAImageController = TextEditingController();
  final _optionBImageController = TextEditingController();
  
  int _votingCost = 1;
  DateTime? _expiresAt;
  bool _hasExpiration = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionAImageController.dispose();
    _optionBImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final createPostNotifier = ref.watch(createVotingPostActionProvider);
    final createPostState = ref.watch(createVotingPostActionProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null || !user.isStar) {
          return Scaffold(
            appBar: AppBar(title: const Text('アクセス拒否')),
            body: const Center(
              child: Text('スターのみが投票投稿を作成できます'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('投票投稿を作成'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              createPostState.when(
                data: (_) => TextButton(
                  onPressed: () => _submitForm(user.id, createPostNotifier),
                  child: const Text(
                    '投稿',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                error: (_, __) => TextButton(
                  onPressed: () => _submitForm(user.id, createPostNotifier),
                  child: const Text(
                    '再試行',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTitleSection(),
                const SizedBox(height: 24),
                _buildDescriptionSection(),
                const SizedBox(height: 24),
                _buildOptionsSection(),
                const SizedBox(height: 24),
                _buildSettingsSection(),
                const SizedBox(height: 32),
                _buildPreviewSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(createPostNotifier, createPostState, user.id),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '投票のタイトル',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '例: 今日の夕食はどっち？',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'タイトルは必須です';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '説明（任意）',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: '投票の詳細や背景を説明してください',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '選択肢',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildOptionInput('A', _optionAController, _optionAImageController),
        const SizedBox(height: 16),
        _buildOptionInput('B', _optionBController, _optionBImageController),
      ],
    );
  }

  Widget _buildOptionInput(String label, TextEditingController textController, TextEditingController imageController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '選択肢 $label',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: textController,
              decoration: InputDecoration(
                hintText: '選択肢 $label のテキスト',
                border: const OutlineInputBorder(),
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '選択肢 $label は必須です';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: imageController,
              decoration: InputDecoration(
                hintText: '画像URL（任意）',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.image),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return '有効なURLを入力してください';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '投票設定',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('投票コスト:'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _votingCost.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_votingCost SP',
                    onChanged: (value) {
                      setState(() {
                        _votingCost = value.toInt();
                      });
                    },
                  ),
                ),
                Text('$_votingCost SP'),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('有効期限を設定'),
              subtitle: _hasExpiration 
                  ? Text(_expiresAt != null 
                      ? '${_expiresAt!.month}/${_expiresAt!.day} ${_expiresAt!.hour}:${_expiresAt!.minute.toString().padLeft(2, '0')}'
                      : '未設定')
                  : const Text('無期限'),
              value: _hasExpiration,
              onChanged: (value) {
                setState(() {
                  _hasExpiration = value;
                  if (!value) {
                    _expiresAt = null;
                  }
                });
              },
            ),
            if (_hasExpiration) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _selectExpirationDateTime,
                icon: const Icon(Icons.schedule),
                label: Text(_expiresAt != null ? '期限を変更' : '期限を設定'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    if (_titleController.text.isEmpty && 
        _optionAController.text.isEmpty && 
        _optionBController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プレビュー',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPreviewCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _titleController.text.isNotEmpty ? _titleController.text : 'タイトル',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_votingCost SP',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (_descriptionController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_descriptionController.text),
          ],
          const SizedBox(height: 16),
          if (_optionAController.text.isNotEmpty)
            _buildPreviewOption('A', _optionAController.text),
          const SizedBox(height: 8),
          if (_optionBController.text.isNotEmpty)
            _buildPreviewOption('B', _optionBController.text),
        ],
      ),
    );
  }

  Widget _buildPreviewOption(String label, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }

  Widget _buildSubmitButton(CreateVotingPostNotifier notifier, AsyncValue state, String userId) {
    return state.when(
      data: (post) {
        if (post != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('投票投稿を作成しました！'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }
          });
        }
        
        return ElevatedButton(
          onPressed: () => _submitForm(userId, notifier),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            '投票投稿を作成',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
      loading: () => const ElevatedButton(
        onPressed: null,
        style: ButtonStyle(
          minimumSize: MaterialStatePropertyAll(Size(double.infinity, 48)),
        ),
        child: Text('作成中...'),
      ),
      error: (error, _) => Column(
        children: [
          Text(
            'エラー: $error',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _submitForm(userId, notifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectExpirationDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _expiresAt ?? now.add(const Duration(hours: 1)),
        ),
      );

      if (time != null) {
        setState(() {
          _expiresAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm(String userId, CreateVotingPostNotifier notifier) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasExpiration && _expiresAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('有効期限を設定してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await notifier.createVotingPost(
      starId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      optionA: _optionAController.text.trim(),
      optionB: _optionBController.text.trim(),
      optionAImageUrl: _optionAImageController.text.trim().isNotEmpty 
          ? _optionAImageController.text.trim() 
          : null,
      optionBImageUrl: _optionBImageController.text.trim().isNotEmpty 
          ? _optionBImageController.text.trim() 
          : null,
      votingCost: _votingCost,
      expiresAt: _expiresAt,
    );
  }
}