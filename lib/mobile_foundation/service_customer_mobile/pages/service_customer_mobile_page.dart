import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../models/service_customer_model.dart';
import '../../../services/service_customer_api.dart';
import 'service_customer_detail_mobile_page.dart';
import 'service_customer_form_mobile_page.dart';

class ServiceCustomerMobilePage extends StatefulWidget {
  const ServiceCustomerMobilePage({super.key});

  @override
  State<ServiceCustomerMobilePage> createState() =>
      _ServiceCustomerMobilePageState();
}

class _ServiceCustomerMobilePageState
    extends State<ServiceCustomerMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);

  final TextEditingController _searchController =
  TextEditingController();

  List<ServiceCustomer> _services = [];
  List<ServiceCustomer> _filteredServices = [];

  bool _loading = true;
  bool _refreshing = false;
  String? _errorMessage;

  String _selectedStatus = 'Semua';

  final List<String> _statusFilters = const [
    'Semua',
    'Waiting',
    'On Progress',
    'Finished',
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchServices({
    bool refresh = false,
  }) async {
    if (!mounted) return;

    setState(() {
      if (refresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }

      _errorMessage = null;
    });

    try {
      final result = await ServiceCustomerApi.getAll();

      if (!mounted) return;

      setState(() {
        _services = result;
        _applyFilter();

        _loading = false;
        _refreshing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _refreshing = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchServices(refresh: true);
  }

  void _applyFilter() {
    final query =
    _searchController.text.trim().toLowerCase();

    _filteredServices = _services.where((service) {
      final serviceNo =
      (service.serviceNo ?? '').toLowerCase();

      final customer =
      (service.namaCustomer ?? '').toLowerCase();

      final jenisBarang =
      (service.jenisBarang ?? '').toLowerCase();

      final typeUnit =
      (service.typeUnit ?? '').toLowerCase();

      final partNo =
      (service.partNo ?? '').toLowerCase();

      final status =
      (service.status ?? 'Waiting').toLowerCase();

      final matchSearch =
          query.isEmpty ||
              serviceNo.contains(query) ||
              customer.contains(query) ||
              jenisBarang.contains(query) ||
              typeUnit.contains(query) ||
              partNo.contains(query) ||
              status.contains(query);

      final matchStatus =
          _selectedStatus == 'Semua' ||
              service.status == _selectedStatus;

      return matchSearch && matchStatus;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(_applyFilter);
  }

  void _changeStatusFilter(String status) {
    setState(() {
      _selectedStatus = status;
      _applyFilter();
    });
  }

  int _countStatus(String status) {
    return _services.where((service) {
      return service.status == status;
    }).length;
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Finished':
        return const Color(0xff69f0ae);

      case 'On Progress':
        return const Color(0xff64b5f6);

      case 'Waiting':
      default:
        return accent;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Finished':
        return Icons.check_circle_outline_rounded;

      case 'On Progress':
        return Icons.build_circle_outlined;

      case 'Waiting':
      default:
        return Icons.schedule_rounded;
    }
  }

  String _safeText(
      String? value, {
        String fallback = '-',
      }) {
    final text = value?.trim();

    if (text == null ||
        text.isEmpty ||
        text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  String _formatDate(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value.toLowerCase() == 'null') {
      return '-';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value.split('T').first;
    }

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }

  Future<void> _openAddService() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
        const ServiceCustomerFormMobilePage(),
      ),
    );

    if (result == true) {
      await _fetchServices(refresh: true);
    }
  }

  Future<void> _openDetail(
      ServiceCustomer service,
      ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ServiceCustomerDetailMobilePage(
          service: service,
        ),
      ),
    );

    if (result == true) {
      await _fetchServices(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddService,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            right: -130,
            child: _buildGlow(
              color: accent,
              size: 300,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -150,
            child: _buildGlow(
              color: const Color(0xff64b5f6),
              size: 300,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: accent,
              backgroundColor:
              const Color(0xff1a1a1a),
              child: CustomScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                physics:
                const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      14,
                      18,
                      120,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _buildHeader(),
                          const SizedBox(height: 18),
                          _buildSummary(),
                          const SizedBox(height: 18),
                          _buildSearchField(),
                          const SizedBox(height: 14),
                          _buildStatusFilters(),
                          const SizedBox(height: 22),
                          _buildListHeader(),
                          const SizedBox(height: 12),
                          _buildContent(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_refreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: accent,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlow({
    required Color color,
    required double size,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.02),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 120,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.045),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                size: 19,
              ),
            ),
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Service Customer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola barang service milik customer',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _refresh,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.11),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withOpacity(0.22),
                ),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: accent,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final waiting = _countStatus('Waiting');
    final progress = _countStatus('On Progress');
    final finished = _countStatus('Finished');

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.035),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryItem(
                      title: 'Total',
                      value: _services.length,
                      icon:
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _summaryItem(
                      title: 'Waiting',
                      value: waiting,
                      icon: Icons.schedule_rounded,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _summaryItem(
                      title: 'Dikerjakan',
                      value: progress,
                      icon:
                      Icons.build_circle_outlined,
                      color:
                      const Color(0xff64b5f6),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _summaryItem(
                      title: 'Selesai',
                      value: finished,
                      icon: Icons
                          .check_circle_outline_rounded,
                      color:
                      const Color(0xff69f0ae),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withOpacity(0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText:
        'Cari no service, customer, barang...',
        hintStyle: const TextStyle(
          color: Colors.white30,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: accent,
          size: 21,
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            _searchController.clear();
            _onSearchChanged('');
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white38,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.045),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: accent.withOpacity(0.70),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 39,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final selected =
              _selectedStatus == status;

          final color = status == 'Finished'
              ? const Color(0xff69f0ae)
              : status == 'On Progress'
              ? const Color(0xff64b5f6)
              : status == 'Waiting'
              ? accent
              : Colors.white;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  _changeStatusFilter(status),
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration:
                const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withOpacity(0.16)
                      : Colors.white.withOpacity(0.035),
                  borderRadius:
                  BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? color.withOpacity(0.45)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: selected
                        ? color
                        : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Tekan card untuk melihat detail',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withOpacity(0.17),
            ),
          ),
          child: Text(
            '${_filteredServices.length} data',
            style: const TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return _buildLoading();
    }

    if (_errorMessage != null &&
        _services.isEmpty) {
      return _buildError();
    }

    if (_filteredServices.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: List.generate(
        _filteredServices.length,
            (index) {
          final service =
          _filteredServices[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom:
              index < _filteredServices.length - 1
                  ? 11
                  : 0,
            ),
            child: _buildServiceCard(service),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(
      ServiceCustomer service,
      ) {
    final status =
    _safeText(service.status, fallback: 'Waiting');

    final statusColor = _statusColor(status);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openDetail(service),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.035),
                borderRadius:
                BorderRadius.circular(22),
                border: Border.all(
                  color:
                  Colors.white.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color:
                          accent.withOpacity(0.11),
                          borderRadius:
                          BorderRadius.circular(17),
                          border: Border.all(
                            color:
                            accent.withOpacity(0.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.build_circle_outlined,
                          color: accent,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _safeText(
                                service.namaCustomer,
                                fallback:
                                'Customer tidak diketahui',
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _safeText(
                                service.serviceNo,
                                fallback:
                                'No service belum tersedia',
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor
                              .withOpacity(0.12),
                          borderRadius:
                          BorderRadius.circular(30),
                          border: Border.all(
                            color: statusColor
                                .withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              _statusIcon(status),
                              color: statusColor,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Divider(
                    height: 1,
                    color:
                    Colors.white.withOpacity(0.06),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _serviceInfo(
                          icon:
                          Icons.inventory_2_outlined,
                          label: 'Barang',
                          value: _safeText(
                            service.jenisBarang,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _serviceInfo(
                          icon:
                          Icons.precision_manufacturing_outlined,
                          label: 'Type Unit',
                          value: _safeText(
                            service.typeUnit,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: _serviceInfo(
                          icon:
                          Icons.calendar_month_outlined,
                          label: 'Tanggal Masuk',
                          value: _formatDate(
                            service.tanggalIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _serviceInfo(
                          icon:
                          Icons.numbers_rounded,
                          label: 'Part Number',
                          value: _safeText(
                            service.partNo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: Colors.white30,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: 230,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: accent,
            strokeWidth: 3,
          ),
          SizedBox(height: 15),
          Text(
            'Mengambil data service...',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff1a1010),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.redAccent,
            size: 36,
          ),
          const SizedBox(height: 13),
          const Text(
            'Gagal mengambil data service',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _fetchServices,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: TextButton.styleFrom(
              foregroundColor: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      height: 210,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.build_circle_outlined,
            color: Colors.white24,
            size: 43,
          ),
          SizedBox(height: 13),
          Text(
            'Data service tidak ditemukan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Coba ubah pencarian atau filter status',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}