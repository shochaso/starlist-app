import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

enum Gender { male, female, other, preferNotToSay }

@immutable
class ProfileInfoState {
  final XFile? profileImage;
  final Set<String> selectedGenres;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final bool isAffiliated;
  final String agencyName;
  final bool isFormValid;

  const ProfileInfoState({
    this.profileImage,
    this.selectedGenres = const {},
    this.dateOfBirth,
    this.gender,
    this.isAffiliated = false,
    this.agencyName = '',
    this.isFormValid = false,
  });

  ProfileInfoState copyWith({
    XFile? profileImage,
    Set<String>? selectedGenres,
    DateTime? dateOfBirth,
    Gender? gender,
    bool? isAffiliated,
    String? agencyName,
    bool? isFormValid,
  }) {
    return ProfileInfoState(
      profileImage: profileImage ?? this.profileImage,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isAffiliated: isAffiliated ?? this.isAffiliated,
      agencyName: agencyName ?? this.agencyName,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class ProfileInfoNotifier extends StateNotifier<ProfileInfoState> {
  ProfileInfoNotifier() : super(const ProfileInfoState());

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      state = state.copyWith(profileImage: image);
      _validateForm();
    }
  }

  void toggleGenre(String genre) {
    final newGenres = Set<String>.from(state.selectedGenres);
    if (newGenres.contains(genre)) {
      newGenres.remove(genre);
    } else {
      newGenres.add(genre);
    }
    state = state.copyWith(selectedGenres: newGenres);
    _validateForm();
  }
  
  void setDateOfBirth(DateTime dob) {
    state = state.copyWith(dateOfBirth: dob);
     _validateForm();
  }
  
  void setGender(Gender gender) {
    state = state.copyWith(gender: gender);
     _validateForm();
  }

  void setAffiliation(bool isAffiliated) {
    state = state.copyWith(isAffiliated: isAffiliated, agencyName: isAffiliated ? state.agencyName : '');
    _validateForm();
  }

  void updateAgencyName(String name) {
    state = state.copyWith(agencyName: name);
    _validateForm();
  }

  void _validateForm() {
    // 性別必須 + 少なくとも1ジャンル選択
    final isValid = state.gender != null && state.selectedGenres.isNotEmpty;
    state = state.copyWith(isFormValid: isValid);
  }
}

final profileInfoProvider =
    StateNotifierProvider<ProfileInfoNotifier, ProfileInfoState>((ref) {
  return ProfileInfoNotifier();
}); 