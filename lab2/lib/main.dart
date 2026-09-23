import 'package:flutter/material.dart';

void main() {
  runApp(const MedicalAppointmentApp());
}

// ======================================================
// COLORS
// ======================================================

const Color teal = Color(0xFF159DB5);
const Color darkText = Color(0xFF17171B);
const Color grayText = Color(0xFF92929A);
const Color softBg = Color(0xFFF8F8FA);
const Color lightTeal = Color(0xFFE0F1EF);

// ======================================================
// APP
// ======================================================

class MedicalAppointmentApp extends StatelessWidget {
  const MedicalAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Appointment',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// ======================================================
// HOME SCREEN
// ======================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ----------------------------------------------------
  // HEALTH SERVICE
  // ----------------------------------------------------

  Widget serviceItem(String image, String title) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/$image',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: grayText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // DOCTOR ITEM
  // ----------------------------------------------------

  Widget doctorItem({
    required String image,
    required String name,
    required String specialty,
    required String address,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/$image',
              width: 47,
              height: 47,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 47,
                height: 47,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7EFF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: teal),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: grayText, fontSize: 12),
                ),

                const SizedBox(height: 9),

                Row(
                  children: [
                    const Icon(Icons.location_on, color: teal, size: 16),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: darkText, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const SizedBox(
            width: 25,
            height: 30,
            child: Icon(
              Icons.favorite_border,
              color: Color(0xFF8D8D98),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 27),

                // ==================================================
                // HEADER
                // ==================================================
                Row(
                  children: [
                    SizedBox(
                      width: 45,
                      height: 45,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/home_avatar.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFE7EFF0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: teal),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Jonathan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'May you always be healthy',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: grayText, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Center(
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 29,
                              color: darkText,
                            ),
                          ),

                          Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ==================================================
                // SEARCH
                // ==================================================
                Container(
                  height: 55,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(17),
                  ),

                  child: Row(
                    children: [
                      const SizedBox(width: 16),

                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFA4A8B7),
                        size: 27,
                      ),

                      const SizedBox(width: 13),

                      const Expanded(
                        child: Text(
                          'Search something',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFA4A8B7),
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFFA4A8B7),
                        size: 24,
                      ),

                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 21),

                // ==================================================
                // APPOINTMENT CARD
                // ==================================================
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppointmentScreen(),
                      ),
                    );
                  },

                  child: Container(
                    width: double.infinity,
                    height: 173,

                    decoration: BoxDecoration(
                      color: teal,
                      borderRadius: BorderRadius.circular(7),
                    ),

                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Appointment',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: Colors.white,
                                    size: 21,
                                  ),

                                  SizedBox(width: 9),

                                  Text(
                                    '22 October, 2023',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 21,
                                  ),

                                  SizedBox(width: 9),

                                  Text(
                                    '08:00 AM - 10.30 AM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ==================================================
                        // DOCTOR CARD
                        // ==================================================
                        Positioned(
                          left: 22,
                          right: 22,
                          bottom: -25,

                          child: Container(
                            height: 68,

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),

                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x11000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                const SizedBox(width: 13),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),

                                  child: Image.asset(
                                    'assets/appointment_card_doctor.png',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 44,
                                      height: 44,
                                      color: const Color(0xFFE7EFF0),
                                      child: const Icon(
                                        Icons.person,
                                        color: teal,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        'Dr. Richar Kandowen',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      SizedBox(height: 4),

                                      Text(
                                        'Child Specialist',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: grayText,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Container(
                                  width: 27,
                                  height: 27,

                                  margin: const EdgeInsets.only(right: 13),

                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: darkText,
                                      width: 1.5,
                                    ),

                                    borderRadius: BorderRadius.circular(8),
                                  ),

                                  child: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 53),

                // ==================================================
                // HEALTH SERVICES
                // ==================================================
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Health Services',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'See All',
                      style: TextStyle(color: teal, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 52),

                Row(
                  children: [
                    serviceItem('service_tooth.png', 'Tooth'),

                    serviceItem('service_eye.png', 'Eye'),

                    serviceItem('service_lungs.png', 'Lungs'),

                    serviceItem('service_ear.png', 'Ear'),
                  ],
                ),

                const SizedBox(height: 27),

                // ==================================================
                // NEARBY DOCTOR
                // ==================================================
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nearby Doctor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'See All',
                      style: TextStyle(color: teal, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                doctorItem(
                  image: 'home_doctor1.png',
                  name: 'Dr. Emily Lestiryno',
                  specialty: 'General Practitioner',
                  address: '3167 Durgan Shores - 500M from you',
                ),

                doctorItem(
                  image: 'home_doctor2.png',
                  name: 'Dr. Sonja Littel',
                  specialty: 'Dental Specialist',
                  address: '950 Sigrid Port - 753M from you',
                ),

                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// APPOINTMENT SCREEN
// ======================================================

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int selectedHour = 1;
  int selectedDate = 0;

  // ====================================================
  // ACTION BUTTON
  // ====================================================

  Widget actionButton(IconData icon) {
    return SizedBox(
      width: 32,
      height: 32,

      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: lightTeal,
          shape: BoxShape.circle,
        ),

        child: Icon(icon, size: 17, color: Color(0xFF3C7774)),
      ),
    );
  }

  // ====================================================
  // TIME BUTTON
  // ====================================================

  Widget timeButton(String text, int index) {
    final bool selected = selectedHour == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHour = index;
        });
      },

      child: Container(
        width: 136,
        height: 57,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: selected ? teal : const Color(0xFFF6F6F7),

          borderRadius: BorderRadius.circular(10),
        ),

        child: Text(
          text,

          style: TextStyle(
            color: selected ? Colors.white : darkText,

            fontSize: 17,
          ),
        ),
      ),
    );
  }

  // ====================================================
  // DATE BUTTON
  // ====================================================

  Widget dateButton(String day, String number, int index) {
    final bool selected = selectedDate == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = index;
        });
      },

      child: Container(
        width: double.infinity,
        height: 57,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: selected ? teal : const Color(0xFFF6F6F7),

          borderRadius: BorderRadius.circular(10),
        ),

        child: Text(
          '$day $number',

          maxLines: 1,

          style: TextStyle(
            color: selected ? Colors.white : darkText,

            fontSize: 17,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 18),

                // ==================================================
                // HEADER
                // ==================================================
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: const SizedBox(
                        width: 30,
                        height: 30,

                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 23),
                      ),
                    ),

                    const Expanded(
                      child: Center(
                        child: Text(
                          'Appointment',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            color: teal,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 30),
                  ],
                ),

                const SizedBox(height: 31),

                // ==================================================
                // DOCTOR
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),

                      child: Image.asset(
                        'assets/appointment_doctor.png',

                        width: 132,
                        height: 133,

                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 132,
                          height: 133,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7EFF0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            size: 48,
                            color: teal,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Dr.Upul',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              actionButton(Icons.chat_bubble_outline),
                              const SizedBox(width: 12),
                              actionButton(Icons.phone_outlined),
                              const SizedBox(width: 12),
                              actionButton(Icons.videocam_outlined),
                            ],
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Denteeth',

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              color: Color(0xFF68BEB0),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 31),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Payment',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Text(
                                '\$120.00',
                                style: TextStyle(
                                  color: Color(0xFF68BEB0),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 38),

                // ==================================================
                // DETAILS
                // ==================================================
                const Text(
                  'Details',

                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 13),

                const Text(
                  'Worem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Nunc vulputate libero et velit interdum, ac aliquet odio mattis. '
                  'Class aptent taciti sociosqu ad litora torquent per conubia nostra, '
                  'inceptos himenaeos. Curabitur tempus urna at turpis condimentum '
                  'lobortis. Ut commodo efficitur neque. Ut diam quam, semper iaculis '
                  'condimentum ac, vestibulum eu nisl.',

                  style: TextStyle(
                    color: Color(0xFF929292),
                    fontSize: 13.5,
                    height: 1.23,
                  ),
                ),

                const SizedBox(height: 48),

                // ==================================================
                // WORKING HOURS TITLE
                // ==================================================
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Working Hours',

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text('See All', style: TextStyle(fontSize: 14)),
                  ],
                ),

                const SizedBox(height: 21),

                // ==================================================
                // WORKING HOURS
                // ==================================================
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  physics: const BouncingScrollPhysics(),

                  child: Row(
                    children: [
                      timeButton('10.00 AM', 0),

                      const SizedBox(width: 15),

                      timeButton('11.00 AM', 1),

                      const SizedBox(width: 15),

                      timeButton('12.00 PM', 2),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // DATE TITLE
                // ==================================================
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Date',

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text('See All', style: TextStyle(fontSize: 14)),
                  ],
                ),

                const SizedBox(height: 21),

                // ==================================================
                // DATE BUTTONS
                //
                // FIXED:
                // NO HORIZONTAL OVERFLOW
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 57,

                  child: Row(
                    children: [
                      Expanded(child: dateButton('Sun', '4', 0)),

                      const SizedBox(width: 12),

                      Expanded(child: dateButton('Mon', '5', 1)),

                      const SizedBox(width: 12),

                      Expanded(child: dateButton('Tue', '6', 2)),
                    ],
                  ),
                ),

                const SizedBox(height: 72),

                // ==================================================
                // BOOK APPOINTMENT
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 60,

                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Appointment booked successfully!'),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),

                    child: const Text(
                      'Book an Appointment',

                      maxLines: 1,

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
