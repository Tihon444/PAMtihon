import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorReducereApp());
}

class CalculatorReducereApp extends StatelessWidget {
  const CalculatorReducereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Reducere',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20B968),
        ),
      ),
      home: const CalculatorReducerePage(),
    );
  }
}

class CalculatorReducerePage extends StatefulWidget {
  const CalculatorReducerePage({super.key});

  @override
  State<CalculatorReducerePage> createState() =>
      _CalculatorReducerePageState();
}

class _CalculatorReducerePageState
    extends State<CalculatorReducerePage> {

  final TextEditingController pretController = TextEditingController();
  final TextEditingController reducereController = TextEditingController();

  String monedaSelectata = 'MDL';

  double valoareReducere = 0;
  double pretFinal = 0;
  bool areRezultat = false;

  void calculeazaReducerea() {
    final pret = double.tryParse(
      pretController.text.replaceAll(',', '.'),
    );

    final reducere = double.tryParse(
      reducereController.text.replaceAll(',', '.'),
    );

    if (pret == null || reducere == null) {
      afiseazaMesaj('Introduceți valori numerice valide.');
      return;
    }

    if (pret < 0 || reducere < 0 || reducere > 100) {
      afiseazaMesaj(
        'Prețul trebuie să fie pozitiv, iar reducerea între 0% și 100%.',
      );
      return;
    }

    setState(() {
      valoareReducere = pret * reducere / 100;
      pretFinal = pret - valoareReducere;
      areRezultat = true;
    });
  }

  void afiseazaMesaj(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void stergeDatele() {
    setState(() {
      pretController.clear();
      reducereController.clear();
      valoareReducere = 0;
      pretFinal = 0;
      areRezultat = false;
    });
  }

  @override
  void dispose() {
    pretController.dispose();
    reducereController.dispose();
    super.dispose();
  }

  InputDecoration decoratieCamp({
    required String eticheta,
    required String sugestie,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: eticheta,
      hintText: sugestie,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF20B968),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF20B968),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ANTET
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Economisește inteligent',
                        style: TextStyle(
                          color: Color(0xFF20B968),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Calculator Reducere',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111318),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: const Icon(
                      Icons.local_offer_outlined,
                      color: Color(0xFF20B968),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // CARD INFORMAȚIONAL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF141518),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [

                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF20B968),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.percent_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calculează economiile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Introdu prețul și procentul reducerii.',
                            style: TextStyle(
                              color: Color(0xFFB8BBC2),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // TITLU SECȚIUNE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalii produs',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111318),
                    ),
                  ),

                  if (areRezultat)
                    GestureDetector(
                      onTap: stergeDatele,
                      child: const Text(
                        'Șterge',
                        style: TextStyle(
                          color: Color(0xFF20B968),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // CARD INTRODUCERE DATE
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // PREȚ
                    TextField(
                      controller: pretController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: decoratieCamp(
                        eticheta: 'Preț inițial',
                        sugestie: 'Exemplu: 1000',
                        icon: Icons.payments_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // REDUCERE
                    TextField(
                      controller: reducereController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: decoratieCamp(
                        eticheta: 'Procent reducere',
                        sugestie: 'Exemplu: 20',
                        icon: Icons.percent_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // MONEDĂ
                    DropdownButtonFormField<String>(
                      initialValue: monedaSelectata,
                      decoration: InputDecoration(
                        labelText: 'Monedă',
                        prefixIcon: const Icon(
                          Icons.currency_exchange_rounded,
                          color: Color(0xFF20B968),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'MDL',
                          child: Text('MDL — Leu moldovenesc'),
                        ),
                        DropdownMenuItem(
                          value: 'EUR',
                          child: Text('EUR — Euro'),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('USD — Dolar american'),
                        ),
                      ],
                      onChanged: (valoare) {
                        if (valoare == null) return;

                        setState(() {
                          monedaSelectata = valoare;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // BUTON CALCUL
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: calculeazaReducerea,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF20B968),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate_outlined),
                            SizedBox(width: 10),
                            Text(
                              'Calculează reducerea',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // REZULTAT
              const Text(
                'Rezultatul calculului',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111318),
                ),
              ),

              const SizedBox(height: 16),

              // CARD REZULTAT
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9F0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFC7EED7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Economia ta',
                              style: TextStyle(
                                color: Color(0xFF557064),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              areRezultat
                                  ? '${valoareReducere.toStringAsFixed(2)} $monedaSelectata'
                                  : '0.00 $monedaSelectata',
                              style: const TextStyle(
                                color: Color(0xFF16834A),
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.savings_outlined,
                            color: Color(0xFF20B968),
                            size: 27,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
                      height: 1,
                      color: const Color(0xFFC7EED7),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Preț final',
                      style: TextStyle(
                        color: Color(0xFF557064),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      areRezultat
                          ? '${pretFinal.toStringAsFixed(2)} $monedaSelectata'
                          : '0.00 $monedaSelectata',
                      style: const TextStyle(
                        color: Color(0xFF111318),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (areRezultat)
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 17,
                            color: Color(0xFF20B968),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Reducerea a fost aplicată cu succes',
                            style: TextStyle(
                              color: Color(0xFF557064),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // FORMULA
              Center(
                child: Text(
                  'Preț final = Preț inițial − Valoarea reducerii',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}