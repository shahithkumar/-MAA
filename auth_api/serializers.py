from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    UserProfile, Guardian, Category, MeditationSession, YogaSession,
    UserPreferences, BackgroundMusic, CalmingSession, GroundingSession,
    PanicSession, StressBusterSession, MoodLog, AffirmationCategory,
    GenericAffirmation, CustomAffirmation, AffirmationTemplate, MusicCategory, MusicTrack,
    MusicSession, CBTTopic, CBTSession, Disorder, Article, CopingMethod, RoadmapStep, EmotionJournal,
    TherapySession, ReflectionQuestion, TherapyRecord, TherapyRecordAnswer
)

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['id', 'user', 'name', 'age', 'phone_number', 'email', 'gender', 'medical_history', 'streak_count', 'last_activity_date']

class GuardianSerializer(serializers.ModelSerializer):
    class Meta:
        model = Guardian
        fields = ['id', 'user', 'name', 'relationship', 'phone_number', 'email']

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'emoji']  # ✅ NO created_at

class MeditationSessionSerializer(serializers.ModelSerializer):
    category_id = serializers.IntegerField(allow_null=True, source='category.id', read_only=True)
    class Meta:
        model = MeditationSession
        fields = ['id', 'title', 'description', 'duration', 'audio_file', 'category_id', 'emoji', 'guidance_text', 'image']  # ✅ NO created_at

class YogaSessionSerializer(serializers.ModelSerializer):
    type_id = serializers.IntegerField(allow_null=True, source='type.id', read_only=True)
    class Meta:
        model = YogaSession
        fields = ['id', 'title', 'description', 'duration', 'audio_file', 'type_id', 'emoji', 'video_url', 'channel_name', 'image']  # ✅ NO created_at

class UserPreferencesSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserPreferences
        fields = ['id', 'user', 'meditation_music_on']  # ✅ NO created_at

class BackgroundMusicSerializer(serializers.ModelSerializer):
    class Meta:
        model = BackgroundMusic
        fields = ['id', 'title', 'audio_file', 'emoji']  # ✅ NO created_at

class CalmingSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CalmingSession
        fields = ['id', 'user', 'actions', 'end_time']

class GroundingSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroundingSession
        fields = ['id', 'user', 'five_see', 'four_touch', 'three_hear', 'two_smell', 'one_taste', 'feedback', 'end_time']

class PanicSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = PanicSession
        fields = ['id', 'user', 'actions', 'end_time']

class StressBusterSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = StressBusterSession
        fields = ['id', 'user', 'session_type', 'duration', 'note_text', 'voice_file', 'feedback', 'end_time']

class MoodLogSerializer(serializers.ModelSerializer):
    created_at = serializers.DateTimeField(source='date_time', read_only=True)

    class Meta:
        model = MoodLog
        fields = ['id', 'user', 'date_time', 'created_at', 'mood_emoji', 'mood_label', 'note', 'tag']
        read_only_fields = ['user', 'date_time', 'created_at']

# ✅ FIXED AFFIRMATION SERIALIZERS (NO created_at/updated_at)
class AffirmationCategorySerializer(serializers.ModelSerializer):
    affirmation_count = serializers.SerializerMethodField()
    
    class Meta:
        model = AffirmationCategory
        fields = ['id', 'name', 'icon', 'description', 'affirmation_count']  # ✅ REMOVED created_at, updated_at
    
    def get_affirmation_count(self, obj):
        return GenericAffirmation.objects.filter(category=obj, is_active=True).count()

class GenericAffirmationSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_icon = serializers.CharField(source='category.icon', read_only=True)
    
    class Meta:
        model = GenericAffirmation
        fields = [
            'id', 'text', 'category', 'category_name', 'category_icon', 
            'is_active'  # ✅ REMOVED created_at, updated_at, author (if doesn't exist)
        ]
    
    def validate_category(self, value):
        if not value:
            raise serializers.ValidationError("Category is required")
        return value

class CustomAffirmationSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomAffirmation
        fields = ['id', 'user', 'affirmation_text', 'focus_area', 'challenge', 
                 'positive_direction', 'created_at']
        read_only_fields = ['user', 'created_at', 'affirmation_text']  # ✅ Added affirmation_text
    
    def create(self, validated_data):
        # ✅ Backend auto-generates affirmation_text in VIEW
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

class AffirmationTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = AffirmationTemplate
        fields = ['id', 'template', 'focus_areas']  # ✅ NO created_at

# MUSIC SERIALIZERS (NEW - FIXED)
class MusicCategorySerializer(serializers.ModelSerializer):
    track_count = serializers.SerializerMethodField()
    
    class Meta:
        model = MusicCategory
        fields = ['id', 'name', 'emoji', 'color', 'description', 'track_count']
    
    def get_track_count(self, obj):
        return obj.tracks.count()

class MusicTrackSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_emoji = serializers.CharField(source='category.emoji', read_only=True)
    
    class Meta:
        model = MusicTrack
        fields = ['id', 'title', 'category', 'category_name', 'category_emoji', 
                 'audio_file', 'duration', 'emoji']  # FIXED: 'audio_file' instead of 'audio_url'

class MusicSessionSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    user_id = serializers.IntegerField(source='user.id', read_only=True)

    class Meta:
        model = MusicSession
        fields = [
            'id', 'user', 'user_id', 'category', 'category_name',
            'tracks_played', 'mood_change', 'current_emotion',
            'session_duration', 'created_at'
        ]
        extra_kwargs = {
            'user': {'write_only': True}  # Accept input, don't return
        }
# CBT SERIALIZERS (NEW)
class CBTTopicSerializer(serializers.ModelSerializer):
    class Meta:
        model = CBTTopic
        fields = ['id', 'title', 'emoji', 'color', 'description']

class CBTSessionSerializer(serializers.ModelSerializer):
    topic_name = serializers.CharField(source='topic.title', read_only=True)
    user_id = serializers.IntegerField(source='user.id', read_only=True)

    class Meta:
        model = CBTSession
        fields = [
            'id', 'user', 'user_id', 'topic', 'topic_name',
            'situation', 'automatic_thought', 'emotions',
            'evidence_for', 'evidence_against', 'balanced_thought',
            'session_duration', 'created_at'
        ]
        extra_kwargs = {
            'user': {'write_only': True},
        }

    def create(self, validated_data):
        return super().create(validated_data)
class DisorderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Disorder
        fields = ['id', 'name', 'emoji', 'summary', 'roadmap_image', 'article_url', 'youtube_url']

class ArticleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Article
        fields = ['id', 'title', 'content', 'url']

class CopingMethodSerializer(serializers.ModelSerializer):
    class Meta:
        model = CopingMethod
        fields = ['id', 'title', 'instructions']

class RoadmapStepSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoadmapStep
        fields = ['id', 'title', 'description', 'image', 'order']

class EmotionJournalSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmotionJournal
        fields = '__all__'
        read_only_fields = [
            'user', 'voice_emotion', 'text_emotion', 'face_emotion',
            'final_emotion', 'confidence', 'created_at'
        ]

# THERAPY SERIALIZERS (NEW)
class ReflectionQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReflectionQuestion
        fields = ['id', 'question_text', 'question_type', 'options', 'order']

class TherapySessionSerializer(serializers.ModelSerializer):
    questions = ReflectionQuestionSerializer(many=True, read_only=True)
    
    class Meta:
        model = TherapySession
        fields = ['id', 'title', 'therapy_type', 'audio_file', 'duration', 'prompt_text', 'image', 'questions', 'created_at']

class TherapyRecordAnswerSerializer(serializers.ModelSerializer):
    class Meta:
        model = TherapyRecordAnswer
        fields = ['question', 'answer_text']

class TherapyRecordSerializer(serializers.ModelSerializer):
    answers = TherapyRecordAnswerSerializer(many=True, read_only=True)
    session_title = serializers.CharField(source='session.title', read_only=True)
    session_type = serializers.CharField(source='session.therapy_type', read_only=True)

    class Meta:
        model = TherapyRecord
        fields = ['id', 'user', 'session', 'session_title', 'session_type', 'mood_before', 'mood_after', 'drawing_file', 'reflection_notes', 'answers', 'created_at']
        read_only_fields = ['user', 'created_at']
