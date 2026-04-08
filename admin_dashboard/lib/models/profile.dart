class Profile {
  final String? id;
  final String? aboutTextIntro;
  final String? aboutTextMore;
  final String? aboutImageUrl;
  final String? email;
  final String? instagramHandle;
  final String? instagramUrl;

  Profile({
    this.id,
    this.aboutTextIntro,
    this.aboutTextMore,
    this.aboutImageUrl,
    this.email,
    this.instagramHandle,
    this.instagramUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      aboutTextIntro: json['about_text_intro'],
      aboutTextMore: json['about_text_more'],
      aboutImageUrl: json['about_image_url'],
      email: json['email'],
      instagramHandle: json['instagram_handle'],
      instagramUrl: json['instagram_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'about_text_intro': aboutTextIntro,
      'about_text_more': aboutTextMore,
      'about_image_url': aboutImageUrl,
      'email': email,
      'instagram_handle': instagramHandle,
      'instagram_url': instagramUrl,
    };
    if (id != null) data['id'] = id!;
    return data;
  }
}
