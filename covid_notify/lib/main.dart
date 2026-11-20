import 'package:flutter/material.dart';
import 'covid_api.dart';
import 'covid_data.dart';
import 'notification_service.dart';

class Palette {
  static const cherryRose = Color(0xFFB5185F);
  static const lightYellow = Color(0xFFFEFFE0);
  static const limeCream = Color(0xFFD0E86E);
  static const strongCyan = Color(0xFF35C1C2);

  static const canvasPastel = Color(0xFFF6F7EE);
  static const softRose = Color(0xFFF9E6EF);
  static const softCyan = Color(0xFFE1F6F6);
  static const ink = Color(0xFF192423);
  static const inkSubtle = Color(0xFF4B5C5A);
}

class CountryOption {
  final String labelEs;
  final String apiQuery;

  const CountryOption({
    required this.labelEs,
    required this.apiQuery,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Datos COVID-19',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.cherryRose,
          brightness: Brightness.light,
          primary: Palette.cherryRose,
          onPrimary: Palette.lightYellow,
          secondary: Palette.strongCyan,
          onSecondary: Palette.ink,
          tertiary: Palette.limeCream,
          surface: Palette.lightYellow,
          onSurface: Palette.ink,
        ),
        scaffoldBackgroundColor: Palette.canvasPastel,
      ),
      home: const HomePage(),
    ),
  );
}

String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${two(d.year)} ${two(d.hour)}:${two(d.minute)}';
}

String formatNumber(int n) {
  final str = n.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(str[i]);
  }
  return n < 0 ? '-${buffer.toString()}' : buffer.toString();
}

String translateCountryName(String apiName) {
  switch (apiName.toLowerCase()) {
    case 'colombia':
      return 'Colombia';
    case 'mexico':
      return 'México';
    case 'argentina':
      return 'Argentina';
    case 'peru':
      return 'Perú';
    case 'chile':
      return 'Chile';
    case 'spain':
      return 'España';
    case 'usa':
      return 'Estados Unidos';
    default:
      return apiName;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const countries = [
    CountryOption(labelEs: 'Colombia', apiQuery: 'Colombia'),
    CountryOption(labelEs: 'México', apiQuery: 'Mexico'),
    CountryOption(labelEs: 'Argentina', apiQuery: 'Argentina'),
    CountryOption(labelEs: 'Perú', apiQuery: 'Peru'),
    CountryOption(labelEs: 'Chile', apiQuery: 'Chile'),
    CountryOption(labelEs: 'España', apiQuery: 'Spain'),
    CountryOption(labelEs: 'Estados Unidos', apiQuery: 'USA'),
  ];

  String selected = 'Colombia';
  late Future<CovidData> future = fetchCountry(selected);

  String get _selectedLabelEs {
    for (final item in countries) {
      if (item.apiQuery == selected) return item.labelEs;
    }
    return translateCountryName(selected);
  }

  void _reload() {
    setState(() {
      future = fetchCountry(selected);
    });
  }

  Future<void> _notify(CovidData d) async {
    final countryEs = translateCountryName(d.country);
    await NotificationService.show(
      title: 'COVID-19: $countryEs',
      body: 'Casos: ${d.cases}  Muertes: ${d.deaths} | Hoy: ${d.todayCases}',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Palette.limeCream,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          'Notificación enviada para $countryEs',
          style: const TextStyle(
            color: Palette.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.canvasPastel,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera en español con acento Cherry Rose y Lime Cream
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.limeCream,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'REPORTE POR PAÍS',
                            style: TextStyle(
                              color: Palette.ink,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Datos COVID-19',
                          style: TextStyle(
                            color: Palette.ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Palette.cherryRose,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _reload,
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Palette.lightYellow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Selector de país en español tipo cápsula Light Yellow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                decoration: BoxDecoration(
                  color: Palette.lightYellow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Palette.strongCyan, width: 2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected,
                    isExpanded: true,
                    dropdownColor: Palette.lightYellow,
                    iconEnabledColor: Palette.cherryRose,
                    style: const TextStyle(
                      color: Palette.ink,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                    items: countries
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.apiQuery,
                            child: Text(c.labelEs),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      selected = value;
                      _reload();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contenido del FutureBuilder
              Expanded(
                child: FutureBuilder<CovidData>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Palette.cherryRose,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Consultando datos...',
                              style: TextStyle(
                                color: Palette.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Palette.lightYellow,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Palette.cherryRose,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'No se pudo consultar: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Palette.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              FilledButton(
                                onPressed: _reload,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Palette.cherryRose,
                                  foregroundColor: Palette.lightYellow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final d = snapshot.data!;
                    final countryEs = translateCountryName(
                      d.country.isEmpty ? _selectedLabelEs : d.country,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Encabezado del país con bandera y fecha
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.lightYellow,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Palette.limeCream,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              _FlagBadge(flagUrl: d.flag),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      countryEs,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Palette.cherryRose,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Actualizado: ${formatDate(d.updated)}',
                                      style: const TextStyle(
                                        color: Palette.inkSubtle,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Composición asimétrica Bento: izquierda alta + derecha doble
                        SizedBox(
                          height: 182,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Tarjeta protagonista: Casos acumulados (Strong Cyan)
                              Expanded(
                                flex: 11,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Palette.strongCyan,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Palette.lightYellow,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'ACUMULADO',
                                          style: TextStyle(
                                            color: Palette.ink,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Casos acumulados',
                                            style: TextStyle(
                                              color: Palette.ink,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formatNumber(d.cases),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Palette.ink,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Columna derecha: Casos del día y Muertes del día
                              Expanded(
                                flex: 10,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Palette.limeCream,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Casos del día',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Palette.inkSubtle,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              formatNumber(d.todayCases),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Palette.ink,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Palette.cherryRose,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Muertes del día',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Palette.lightYellow,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              formatNumber(d.todayDeaths),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Palette.lightYellow,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Franjas horizontales para Muertes acumuladas y Recuperados
                        _HorizontalMetricStrip(
                          label: 'Muertes acumuladas',
                          value: formatNumber(d.deaths),
                          fillColor: Palette.softRose,
                          accentColor: Palette.cherryRose,
                        ),
                        const SizedBox(height: 10),
                        _HorizontalMetricStrip(
                          label: 'Recuperados',
                          value: formatNumber(d.recovered),
                          fillColor: Palette.softCyan,
                          accentColor: Palette.ink,
                        ),

                        const Spacer(),

                        // Botón principal de notificación local
                        FilledButton(
                          onPressed: () => _notify(d),
                          style: FilledButton.styleFrom(
                            backgroundColor: Palette.cherryRose,
                            foregroundColor: Palette.lightYellow,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(
                                color: Palette.limeCream,
                                width: 2,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Enviar notificación',
                            style: TextStyle(
                              color: Palette.lightYellow,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
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
}

class _FlagBadge extends StatelessWidget {
  final String flagUrl;

  const _FlagBadge({required this.flagUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 38,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Palette.softCyan,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.strongCyan, width: 1.5),
      ),
      child: flagUrl.isEmpty
          ? const SizedBox.shrink()
          : Image.network(
              flagUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );
  }
}

class _HorizontalMetricStrip extends StatelessWidget {
  final String label;
  final String value;
  final Color fillColor;
  final Color accentColor;

  const _HorizontalMetricStrip({
    required this.label,
    required this.value,
    required this.fillColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Palette.inkSubtle,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}