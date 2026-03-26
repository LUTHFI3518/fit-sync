import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workout_controller.dart';
import '../../widgets/auth_background.dart';
import 'workout_camera_page.dart';

class ExercisePreviewPage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExercisePreviewPage({super.key, required this.exercise});

  @override
  State<ExercisePreviewPage> createState() => _ExercisePreviewPageState();
}

class _ExercisePreviewPageState extends State<ExercisePreviewPage> {
  String? _description;
  String? _gifUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    final ctrl = context.read<WorkoutController>();
    final info = await ctrl.fetchExerciseInfo(widget.exercise['name'] ?? '');

    if (mounted) {
      if (info != null) {
        setState(() {
          _description = info['description'];
          _gifUrl = info['gifUrl'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = ctrl.error ?? 'Failed to load details';
          _isLoading = false;
        });
      }
    }
  }

  void _startExercise() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutCameraPage(
          exercise: widget.exercise,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.exercise['name'] ?? 'Exercise';
    final reps = widget.exercise['targetReps'] ?? 0;
    final seconds = widget.exercise['avgRepSeconds'] ?? 0;
    
    final detailString = reps == 0 ? '$seconds sec hold' : '$reps reps';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AuthBackground(child: SizedBox.expand()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : Colors.black87,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCFF00).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    detailString,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFFCCFF00) : const Color(0xFF5B3FE8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Dynamic content section
                      Expanded(
                        child: _isLoading 
                          ? Center(
                              child: CircularProgressIndicator(
                                color: isDark ? const Color(0xFFCCFF00) : const Color(0xFF5B3FE8),
                              ),
                            )
                          : _error != null 
                            ? Center(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // GIF visualizer
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: double.infinity,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: (_gifUrl != null && _gifUrl!.isNotEmpty)
                                            ? Image.network(
                                                _gifUrl!,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, progress) {
                                                  if (progress == null) return child;
                                                  return const Center(child: CircularProgressIndicator());
                                                },
                                                errorBuilder: (context, error, stackTrace) => 
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: const [
                                                      Icon(Icons.broken_image_rounded, size: 40, color: Colors.white54),
                                                      SizedBox(height: 12),
                                                      Text('GIF Unavailable', style: TextStyle(color: Colors.white54)),
                                                    ],
                                                  ),
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.play_circle_outline_rounded, size: 50, color: Colors.white54),
                                                  SizedBox(height: 12),
                                                  Text('No visual preview available', style: TextStyle(color: Colors.white54)),
                                                ],
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Description Panel
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _description ?? 'No description properly loaded for this specific exercise.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Start Action Button
                      GestureDetector(
                        onTap: _isLoading ? null : _startExercise,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFCCFF00), Color(0xFF99CC00)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'START EXERCISE',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.black87),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
