// lib/screens/match_results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:servel/config/app_config.dart';
import 'package:servel/models/candidato_model.dart';
import 'package:servel/screens/match/candidate_detail_screen.dart';
import 'package:servel/screens/match/match_over_screen.dart';
import 'package:servel/services/candidate_service.dart';
import 'package:servel/widgets/widget_progress.dart';
import 'package:tcard/tcard.dart';

class MatchResultScreen extends StatefulWidget {
  final int tipoEleccionId; // ID del tipo de elección (e.g., presidencial)
  const MatchResultScreen({super.key, required this.tipoEleccionId});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  late Future<List<MatchResult>> _matchResultsFuture;
  final CandidateService _candidateService = CandidateService();
  final TCardController _controller = TCardController();
  bool _hasShownRightSwipeMessage = false;

  @override
  void initState() {
    super.initState();
    _fetchMatchResults();
  }

  void _fetchMatchResults() {
    setState(() {
      _matchResultsFuture = _candidateService.getMatchCandidatos(widget.tipoEleccionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text("Conoce tu voto", style: TextStyle(
                    fontSize: 17.sp, 
                    fontWeight: FontWeight.bold
                  ),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildProgressRow(total: 2, activeIndex: 0),
              )
            ],
          ),
          
      ),
      body: FutureBuilder<List<MatchResult>>(
        future: _matchResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras se cargan los datos, muestra un indicador de carga
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Si hay un error, muestra un mensaje de error
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar resultados: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Si no hay datos, o la lista está vacía
            return const Center(
              child: Text(
                'No se encontraron candidatos o resultados de coincidencia para esta elección.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
      final matchResults = snapshot.data!;
      final cards = matchResults
      .where((result) => result.candidato != null)
      .map((result) => _buildCandidateCard(result.candidato!))
      .toList();
    
      return Column(
    children: [
      Expanded(
        child: TCard(
          cards: cards,
          controller: _controller,
          onForward: (index, info) {
            if (!_hasShownRightSwipeMessage && info.direction == SwipDirection.Right) {
              _hasShownRightSwipeMessage = true;
    
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ahora verás más información sobre este candidato'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
    
            if (index == cards.length) {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchOverScreen(),
                  ),
                );
              });
            }
          },
        ),
    
      ),
    
    ],
      );
    }
    
        },
      ),
      
      );
      }
  Widget _buildCandidateCard(Candidato candidato) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CandidateDetailScreen(candidatoId: candidato.id),
        ),
      );
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(16),
      elevation: 8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo
          candidato.perfilePicture != null && candidato.perfilePicture!.isNotEmpty
              ? Image.network(
                  '${AppConfig.baseUrl}${candidato.perfilePicture}',
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.blueGrey[200],
                  child: const Center(
                    child: Icon(Icons.person, size: 100, color: Colors.white),
                  ),
                ),
          // Capa de gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Información del candidato
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${candidato.nombre} ${candidato.apellido}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  candidato.partido,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


}

