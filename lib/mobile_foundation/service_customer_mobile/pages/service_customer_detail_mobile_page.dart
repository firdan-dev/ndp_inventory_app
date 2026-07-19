import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../models/mechanic_model.dart';
import '../../../models/service_customer_model.dart';
import '../../../services/service_customer_api.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/service_customer_image_model.dart';
import '../../../models/service_customer_video_model.dart';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class ServiceCustomerDetailMobilePage extends StatefulWidget {
  final ServiceCustomer service;

  const ServiceCustomerDetailMobilePage({
    super.key,
    required this.service,
  });

  @override
  State<ServiceCustomerDetailMobilePage> createState() =>
      _ServiceCustomerDetailMobilePageState();
}

class _ServiceVideoPlayerDialog
    extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onDownload;

  const _ServiceVideoPlayerDialog({
    required this.videoUrl,
    required this.onDownload,
  });

  @override
  State<_ServiceVideoPlayerDialog>
  createState() =>
      _ServiceVideoPlayerDialogState();
}

class _ServiceVideoPlayerDialogState
    extends State<_ServiceVideoPlayerDialog> {
  late final VideoPlayerController
  _controller;

  bool _initialized = false;
  bool _showControls = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();

      if (!mounted) return;

      await _controller.play();

      setState(() {
        _initialized = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(
      Duration duration,
      ) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding:
      const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: _initialized &&
            _controller
                .value
                .aspectRatio >
                0
            ? _controller
            .value
            .aspectRatio
            : 16 / 9,
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  alignment:
                  Alignment.center,
                  child: _errorMessage != null
                      ? Padding(
                    padding:
                    const EdgeInsets
                        .all(20),
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons
                              .error_outline_rounded,
                          color: Colors
                              .redAccent,
                          size: 40,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          'Video gagal diputar',
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          _errorMessage!,
                          textAlign:
                          TextAlign.center,
                          maxLines: 4,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color: Colors
                                .white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  )
                      : !_initialized
                      ? const Column(
                    mainAxisSize:
                    MainAxisSize
                        .min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(
                          0xffff6a00,
                        ),
                      ),
                      SizedBox(
                        height: 13,
                      ),
                      Text(
                        'Memuat video...',
                        style:
                        TextStyle(
                          color: Colors
                              .white54,
                        ),
                      ),
                    ],
                  )
                      : FittedBox(
                    fit: BoxFit
                        .contain,
                    child: SizedBox(
                      width:
                      _controller
                          .value
                          .size
                          .width,
                      height:
                      _controller
                          .value
                          .size
                          .height,
                      child:
                      VideoPlayer(
                        _controller,
                      ),
                    ),
                  ),
                ),
              ),

              if (_initialized &&
                  _showControls)
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withOpacity(0.60),
                      shape:
                      BoxShape.circle,
                    ),
                    child: Icon(
                      _controller
                          .value
                          .isPlaying
                          ? Icons
                          .pause_rounded
                          : Icons
                          .play_arrow_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),

              if (_initialized &&
                  _showControls)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 13,
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withOpacity(0.68),
                      borderRadius:
                      BorderRadius
                          .circular(13),
                    ),
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing:
                          true,
                          colors:
                          const VideoProgressColors(
                            playedColor:
                            Color(
                              0xffff6a00,
                            ),
                            bufferedColor:
                            Colors.white38,
                            backgroundColor:
                            Colors.white12,
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: [
                            ValueListenableBuilder<
                                VideoPlayerValue>(
                              valueListenable:
                              _controller,
                              builder: (
                                  context,
                                  value,
                                  child,
                                  ) {
                                return Text(
                                  '${_formatDuration(value.position)}'
                                      ' / '
                                      '${_formatDuration(value.duration)}',
                                  style:
                                  const TextStyle(
                                    color: Colors
                                        .white70,
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            IconButton(
                              visualDensity:
                              VisualDensity
                                  .compact,
                              onPressed:
                              widget
                                  .onDownload,
                              icon:
                              const Icon(
                                Icons
                                    .download_rounded,
                                color: Colors
                                    .white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  decoration:
                  BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.65),
                    shape:
                    BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () =>
                        Navigator.pop(
                          context,
                        ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
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

class _ServiceCustomerDetailMobilePageState
    extends State<ServiceCustomerDetailMobilePage> {
  final ImagePicker _picker = ImagePicker();

  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color blueAccent = Color(0xff64b5f6);
  static const Color greenAccent = Color(0xff69f0ae);

  late Future<List<dynamic>> _futureParts;
  late Future<List<Mechanic>> _futureMechanics;
  late Future<List<ServiceCustomerImage>> _futureImages;
  late Future<List<ServiceCustomerVideo>> _futureVideos;


  bool _uploadingPhoto = false;
  bool _uploadingVideo = false;

  String _status = 'Waiting';

  int? _mekanikBongkarId;
  int? _mekanikPasangId;

  DateTime? _tanggalDikerjakan;
  DateTime? _tanggalSelesai;

  bool _savingStatus = false;
  bool _savingMechanics = false;
  bool _savingDate = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();

    _status = _normalizeStatus(widget.service.status);

    _mekanikBongkarId =
        widget.service.mekanikBongkarId;

    _mekanikPasangId =
        widget.service.mekanikPasangId;

    _tanggalDikerjakan = DateTime.tryParse(
      widget.service.tanggalDikerjakan ?? '',
    );

    _tanggalSelesai = DateTime.tryParse(
      widget.service.tanggalSelesai ?? '',
    );

    _loadData();
  }


  void _openVideo(
      ServiceCustomerVideo video,
      ) {
    final videoUrl =
        'https://api.api-nusantaradiesel.tech'
        '${video.videoPath}';

    showDialog<void>(
      context: context,
      barrierColor:
      Colors.black.withOpacity(0.94),
      builder: (_) {
        return _ServiceVideoPlayerDialog(
          videoUrl: videoUrl,
          onDownload: () {
            _downloadVideo(video);
          },
        );
      },
    );
  }

  void _loadData() {
    _futureParts = ServiceCustomerApi.getParts(
      widget.service.id,
    );

    _futureMechanics =
        ServiceCustomerApi.getMechanics();

    _futureImages = ServiceCustomerApi.getImages(
      widget.service.id,
    );

    _futureVideos = ServiceCustomerApi.getVideos(
      widget.service.id,
    );
  }



  String _normalizeStatus(String? value) {
    switch (value) {
      case 'On Progress':
        return 'On Progress';

      case 'Finished':
        return 'Finished';

      case 'Waiting':
      default:
        return 'Waiting';
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

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  String _formatDateFromString(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value.toLowerCase() == 'null') {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value.split('T').first;
    }

    return _dateToDisplay(date);
  }

  String _dateToDisplay(DateTime? value) {
    if (value == null) return '-';

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _dateToApi(DateTime? value) {
    if (value == null) return '';

    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Finished':
        return greenAccent;

      case 'On Progress':
        return blueAccent;

      case 'Waiting':
      default:
        return accent;
    }
  }

  IconData _statusIcon(String status) {
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

  void _showMessage(
      String message, {
        bool error = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? Colors.redAccent
              : const Color(0xff242424),
          content: Text(message),
        ),
      );
  }

  Future<void> _downloadPhoto(
      ServiceCustomerImage image,
      ) async {
    try {
      final imageUrl =
          'https://api.api-nusantaradiesel.tech'
          '${image.imagePath}';

      final extension = image.imagePath
          .split('.')
          .last
          .split('?')
          .first;

      final fileName =
          'service_photo_${image.id}.$extension';

      final saveLocation = await getSaveLocation(
        suggestedName: fileName,
      );

      if (saveLocation == null) {
        return;
      }

      _showBlockingLoading(
        'Mengunduh foto...',
      );

      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(
        const Duration(seconds: 60),
      );

      if (mounted &&
          Navigator.of(
            context,
            rootNavigator: true,
          ).canPop()) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Server mengembalikan status '
              '${response.statusCode}',
        );
      }

      final file = File(saveLocation.path);

      await file.writeAsBytes(
        response.bodyBytes,
        flush: true,
      );

      _showMessage(
        'Foto berhasil disimpan',
      );
    } catch (error) {
      if (mounted &&
          Navigator.of(
            context,
            rootNavigator: true,
          ).canPop()) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();
      }

      _showMessage(
        'Download foto gagal: $error',
        error: true,
      );
    }
  }

  void _showBlockingLoading(
      String message,
      ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor:
            const Color(0xff191919),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(22),
            ),
            child: Padding(
              padding:
              const EdgeInsets.all(22),
              child: Row(
                children: [
                  const SizedBox(
                    width: 23,
                    height: 23,
                    child:
                    CircularProgressIndicator(
                      color: accent,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshData() async {
    setState(_loadData);

    await Future.wait([
      _futureParts,
      _futureMechanics,
      _futureImages,
      _futureVideos,
    ]);
  }

  Future<void> _updateStatus(
      String newStatus,
      ) async {
    if (_savingStatus || newStatus == _status) {
      return;
    }

    final oldStatus = _status;

    setState(() {
      _status = newStatus;
      _savingStatus = true;
    });

    try {
      await ServiceCustomerApi.updateStatus(
        widget.service.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        _savingStatus = false;
        _changed = true;
      });

      _showMessage(
        'Status berhasil diubah menjadi $newStatus',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _status = oldStatus;
        _savingStatus = false;
      });

      _showMessage(
        'Gagal memperbarui status: $error',
        error: true,
      );
    }
  }

  Future<void> _saveMechanics() async {
    if (_savingMechanics) return;

    setState(() {
      _savingMechanics = true;
    });

    try {
      await ServiceCustomerApi.assignMechanics(
        widget.service.id,
        _mekanikBongkarId,
        _mekanikPasangId,
      );

      if (!mounted) return;

      setState(() {
        _savingMechanics = false;
        _changed = true;
      });

      _showMessage(
        'Assignment mekanik berhasil disimpan',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _savingMechanics = false;
      });

      _showMessage(
        'Gagal menyimpan mekanik: $error',
        error: true,
      );
    }
  }

  Future<void> _pickDate({
    required bool isTanggalSelesai,
  }) async {
    final currentValue = isTanggalSelesai
        ? _tanggalSelesai
        : _tanggalDikerjakan;

    final selected = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: isTanggalSelesai
          ? 'Pilih tanggal selesai'
          : 'Pilih tanggal mulai dikerjakan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accent,
              surface: Color(0xff191919),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xff191919),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isTanggalSelesai) {
        _tanggalSelesai = selected;
      } else {
        _tanggalDikerjakan = selected;
      }
    });

    await _saveDates();
  }

  Future<void> _clearDate({
    required bool isTanggalSelesai,
  }) async {
    setState(() {
      if (isTanggalSelesai) {
        _tanggalSelesai = null;
      } else {
        _tanggalDikerjakan = null;
      }
    });

    await _saveDates();
  }

  Future<void> _saveDates() async {
    if (_savingDate) return;

    setState(() {
      _savingDate = true;
    });

    try {
      await ServiceCustomerApi.updateTanggalService(
        widget.service.id,
        _tanggalDikerjakan == null
            ? null
            : _dateToApi(_tanggalDikerjakan),
        _tanggalSelesai == null
            ? null
            : _dateToApi(_tanggalSelesai),
      );

      if (!mounted) return;

      setState(() {
        _savingDate = false;
        _changed = true;
      });

      _showMessage(
        'Tanggal service berhasil diperbarui',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _savingDate = false;
      });

      _showMessage(
        'Gagal memperbarui tanggal: $error',
        error: true,
      );
    }
  }

  Future<void> _showAddPartSheet() async {
    final partNameController =
    TextEditingController();

    final merkController =
    TextEditingController();

    final partNoController =
    TextEditingController();

    final qtyController =
    TextEditingController(text: '1');

    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.78),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(context)
                      .size
                      .height *
                      0.90,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xff111111),
                  borderRadius:
                  BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        18,
                        12,
                        13,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tambah Pergantian Part',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.pop(
                              sheetContext,
                            ),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color:
                      Colors.white.withOpacity(0.07),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                        const EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          20,
                        ),
                        child: Column(
                          children: [
                            _formField(
                              controller:
                              partNameController,
                              label: 'Nama Part',
                              icon: Icons
                                  .settings_outlined,
                            ),
                            _formField(
                              controller:
                              merkController,
                              label: 'Merek',
                              icon:
                              Icons.sell_outlined,
                            ),
                            _formField(
                              controller:
                              partNoController,
                              label: 'Part Number',
                              icon:
                              Icons.numbers_rounded,
                            ),
                            _formField(
                              controller:
                              qtyController,
                              label: 'Jumlah',
                              icon: Icons
                                  .production_quantity_limits_outlined,
                              keyboardType:
                              TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        20,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                            final partName =
                            partNameController
                                .text
                                .trim();

                            final qty =
                                int.tryParse(
                                  qtyController
                                      .text,
                                ) ??
                                    0;

                            if (partName.isEmpty) {
                              _showMessage(
                                'Nama part wajib diisi',
                                error: true,
                              );
                              return;
                            }

                            if (qty <= 0) {
                              _showMessage(
                                'Qty harus lebih dari 0',
                                error: true,
                              );
                              return;
                            }

                            setSheetState(() {
                              saving = true;
                            });

                            try {
                              await ServiceCustomerApi
                                  .addPart(
                                widget.service.id,
                                {
                                  'part_name':
                                  partName,
                                  'merk':
                                  merkController
                                      .text
                                      .trim(),
                                  'part_no':
                                  partNoController
                                      .text
                                      .trim(),
                                  'qty': qty,
                                },
                              );

                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _futureParts =
                                    ServiceCustomerApi
                                        .getParts(
                                      widget.service.id,
                                    );

                                _changed = true;
                              });

                              if (sheetContext
                                  .mounted) {
                                Navigator.pop(
                                  sheetContext,
                                );
                              }

                              _showMessage(
                                'Part berhasil ditambahkan',
                              );
                            } catch (error) {
                              if (sheetContext
                                  .mounted) {
                                setSheetState(() {
                                  saving = false;
                                });
                              }

                              _showMessage(
                                'Gagal menambahkan part: $error',
                                error: true,
                              );
                            }
                          },
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            minimumSize:
                            const Size.fromHeight(52),
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                17,
                              ),
                            ),
                          ),
                          icon: saving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.save_rounded,
                          ),
                          label: Text(
                            saving
                                ? 'Menyimpan...'
                                : 'Simpan Part',
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            icon,
            color: accent,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: accent.withOpacity(0.70),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _handleBack() async {
    Navigator.pop(context, _changed);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
          bool didPop,
          dynamic result,
          ) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            Positioned(
              top: 50,
              right: -120,
              child: _buildGlow(
                color: accent,
                size: 280,
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                color: accent,
                backgroundColor:
                const Color(0xff191919),
                onRefresh: _refreshData,
                child: CustomScrollView(
                  physics:
                  const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        18,
                        14,
                        18,
                        100,
                      ),
                      sliver: SliverList(
                        delegate:
                        SliverChildListDelegate(
                          [
                            _buildHeader(),
                            const SizedBox(height: 18),
                            _buildMainInformation(),
                            const SizedBox(height: 15),
                            _buildStatusSection(),
                            const SizedBox(height: 15),
                            _buildDateSection(),
                            const SizedBox(height: 15),
                            _buildMechanicSection(),
                            const SizedBox(height: 15),
                            _buildPartsSection(),
                            const SizedBox(height: 15),
                            _buildDocumentationSection(),
                            const SizedBox(height: 15),
                            _buildVideoSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            onTap: _handleBack,
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
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _safeText(
                  widget.service.serviceNo,
                  fallback: 'Nomor service belum ada',
                ),
                style: const TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _refreshData,
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

  Widget _buildMainInformation() {
    return _glassCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.11),
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: accent.withOpacity(0.20),
                  ),
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  color: accent,
                  size: 27,
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
                        widget.service.namaCustomer,
                        fallback:
                        'Customer tidak diketahui',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _safeText(
                        widget.service.jenisBarang,
                      ),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.07),
          ),
          const SizedBox(height: 15),
          _informationRow(
            icon: Icons
                .calendar_month_outlined,
            label: 'Tanggal masuk',
            value: _formatDateFromString(
              widget.service.tanggalIn,
            ),
          ),
          _informationRow(
            icon: Icons
                .precision_manufacturing_outlined,
            label: 'Type unit',
            value: _safeText(
              widget.service.typeUnit,
            ),
          ),
          _informationRow(
            icon: Icons.numbers_rounded,
            label: 'Part number',
            value: _safeText(
              widget.service.partNo,
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return _sectionCard(
      title: 'Status Service',
      subtitle: 'Perbarui progres pengerjaan',
      icon: Icons.track_changes_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statusButton(
                  value: 'Waiting',
                  label: 'Waiting',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusButton(
                  value: 'On Progress',
                  label: 'Progress',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusButton(
                  value: 'Finished',
                  label: 'Finished',
                ),
              ),
            ],
          ),
          if (_savingStatus) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(
              color: accent,
              backgroundColor: Colors.white10,
              minHeight: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusButton({
    required String value,
    required String label,
  }) {
    final selected = _status == value;
    final color = _statusColor(value);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _savingStatus
            ? null
            : () => _updateStatus(value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.16)
                : Colors.white.withOpacity(0.035),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? color.withOpacity(0.48)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                _statusIcon(value),
                color: selected
                    ? color
                    : Colors.white30,
                size: 21,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? color
                      : Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return _sectionCard(
      title: 'Tanggal Pengerjaan',
      subtitle: 'Catat awal dan selesai service',
      icon: Icons.calendar_month_rounded,
      child: Column(
        children: [
          _dateTile(
            title: 'Tanggal Dikerjakan',
            value: _tanggalDikerjakan,
            onTap: () => _pickDate(
              isTanggalSelesai: false,
            ),
            onClear: () => _clearDate(
              isTanggalSelesai: false,
            ),
          ),
          const SizedBox(height: 10),
          _dateTile(
            title: 'Tanggal Selesai',
            value: _tanggalSelesai,
            onTap: () => _pickDate(
              isTanggalSelesai: true,
            ),
            onClear: () => _clearDate(
              isTanggalSelesai: true,
            ),
          ),
          if (_savingDate) ...[
            const SizedBox(height: 13),
            const LinearProgressIndicator(
              color: accent,
              backgroundColor: Colors.white10,
              minHeight: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateTile({
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _savingDate ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: accent,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateToDisplay(value),
                      style: TextStyle(
                        color: value == null
                            ? Colors.white30
                            : Colors.white,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null)
                IconButton(
                  onPressed:
                  _savingDate ? null : onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white38,
                    size: 19,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMechanicSection() {
    return _sectionCard(
      title: 'Assignment Mekanik',
      subtitle: 'Pilih mekanik bongkar dan pasang',
      icon: Icons.engineering_outlined,
      child: FutureBuilder<List<Mechanic>>(
        future: _futureMechanics,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(22),
              child: Center(
                child: CircularProgressIndicator(
                  color: accent,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _inlineError(
              'Gagal mengambil data mekanik',
                  () {
                setState(() {
                  _futureMechanics =
                      ServiceCustomerApi
                          .getMechanics();
                });
              },
            );
          }

          final mechanics =
              snapshot.data ?? <Mechanic>[];

          if (mechanics.isEmpty) {
            return const Text(
              'Belum ada data mekanik',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            );
          }

          return Column(
            children: [
              _mechanicDropdown(
                label: 'Mekanik Bongkar',
                value: _mekanikBongkarId,
                mechanics: mechanics,
                onChanged: (value) {
                  setState(() {
                    _mekanikBongkarId = value;
                  });
                },
              ),
              const SizedBox(height: 11),
              _mechanicDropdown(
                label: 'Mekanik Pasang',
                value: _mekanikPasangId,
                mechanics: mechanics,
                onChanged: (value) {
                  setState(() {
                    _mekanikPasangId = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _savingMechanics
                      ? null
                      : _saveMechanics,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    minimumSize:
                    const Size.fromHeight(50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  icon: _savingMechanics
                      ? const SizedBox(
                    width: 19,
                    height: 19,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.save_rounded,
                  ),
                  label: Text(
                    _savingMechanics
                        ? 'Menyimpan...'
                        : 'Simpan Mekanik',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mechanicDropdown({
    required String label,
    required int? value,
    required List<Mechanic> mechanics,
    required ValueChanged<int?> onChanged,
  }) {
    final mechanicIds =
    mechanics.map((item) => item.id).toSet();

    final safeValue =
    mechanicIds.contains(value) ? value : null;

    return DropdownButtonFormField<int>(
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: const Color(0xff202020),
      iconEnabledColor: accent,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
        ),
        prefixIcon: const Icon(
          Icons.engineering_outlined,
          color: accent,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: accent.withOpacity(0.65),
          ),
        ),
      ),
      hint: const Text(
        'Pilih mekanik',
        style: TextStyle(
          color: Colors.white30,
        ),
      ),
      items: mechanics.map((mechanic) {
        return DropdownMenuItem<int>(
          value: mechanic.id,
          child: Text(
            mechanic.namaMekanik,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged:
      _savingMechanics ? null : onChanged,
    );
  }

  Widget _buildPartsSection() {
    return _sectionCard(
      title: 'Pergantian Part',
      subtitle: 'Daftar komponen yang diganti',
      icon: Icons.settings_outlined,
      trailing: TextButton.icon(
        onPressed: _showAddPartSheet,
        style: TextButton.styleFrom(
          foregroundColor: accent,
        ),
        icon: const Icon(
          Icons.add_rounded,
          size: 19,
        ),
        label: const Text(
          'Tambah',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: FutureBuilder<List<dynamic>>(
        future: _futureParts,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(22),
              child: Center(
                child: CircularProgressIndicator(
                  color: accent,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _inlineError(
              'Gagal mengambil data part',
                  () {
                setState(() {
                  _futureParts =
                      ServiceCustomerApi.getParts(
                        widget.service.id,
                      );
                });
              },
            );
          }

          final parts =
              snapshot.data ?? <dynamic>[];

          if (parts.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 28,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.025),
                borderRadius:
                BorderRadius.circular(18),
                border: Border.all(
                  color:
                  Colors.white.withOpacity(0.06),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: Colors.white24,
                    size: 35,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Belum ada pergantian part',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: List.generate(
              parts.length,
                  (index) {
                final rawPart = parts[index];

                final Map<String, dynamic> part =
                rawPart is Map
                    ? Map<String, dynamic>.from(
                  rawPart,
                )
                    : <String, dynamic>{};

                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                    index < parts.length - 1
                        ? 10
                        : 0,
                  ),
                  child: _partCard(part),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _partCard(
      Map<String, dynamic> part,
      ) {
    final partName = _safeText(
      part['part_name']?.toString(),
      fallback: 'Part tanpa nama',
    );

    final merk = _safeText(
      part['merk']?.toString(),
    );

    final partNo = _safeText(
      part['part_no']?.toString(),
    );

    final qty = _toInt(part['qty']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  partName,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$merk • $partNo',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.11),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.withOpacity(0.20),
              ),
            ),
            child: Text(
              'Qty $qty',
              style: const TextStyle(
                color: accent,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return _glassCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.035),
            borderRadius:
            BorderRadius.circular(23),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _informationRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white30,
                size: 18,
              ),
              const SizedBox(width: 11),
              SizedBox(
                width: 105,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildDocumentationSection() {
    return _sectionCard(
      title: 'Dokumentasi Service',
      subtitle: 'Foto kondisi dan proses pengerjaan',
      icon: Icons.photo_library_outlined,
      child: FutureBuilder<List<ServiceCustomerImage>>(
        future: _futureImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: accent,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _inlineError(
              'Gagal mengambil dokumentasi foto',
                  () {
                setState(() {
                  _futureImages =
                      ServiceCustomerApi.getImages(
                        widget.service.id,
                      );
                });
              },
            );
          }

          final images =
              snapshot.data ?? <ServiceCustomerImage>[];

          return Column(
            children: [
              _photoCategoryCard(
                title: 'Barang Masuk',
                kategori: 'MASUK',
                icon: Icons.inventory_2_outlined,
                images: images
                    .where(
                      (image) =>
                  image.kategori == 'MASUK',
                )
                    .toList(),
              ),
              const SizedBox(height: 10),
              _photoCategoryCard(
                title: 'Saat Pengerjaan',
                kategori: 'PENGERJAAN',
                icon: Icons.build_outlined,
                images: images
                    .where(
                      (image) =>
                  image.kategori ==
                      'PENGERJAAN',
                )
                    .toList(),
              ),
              const SizedBox(height: 10),
              _photoCategoryCard(
                title: 'Saat Test',
                kategori: 'TEST',
                icon: Icons.science_outlined,
                images: images
                    .where(
                      (image) =>
                  image.kategori == 'TEST',
                )
                    .toList(),
              ),
              const SizedBox(height: 10),
              _photoCategoryCard(
                title: 'Selesai',
                kategori: 'SELESAI',
                icon:
                Icons.check_circle_outline_rounded,
                images: images
                    .where(
                      (image) =>
                  image.kategori == 'SELESAI',
                )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _photoCategoryCard({
    required String title,
    required String kategori,
    required IconData icon,
    required List<ServiceCustomerImage> images,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  '$title (${images.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _uploadingPhoto
                    ? null
                    : () => _uploadPhoto(kategori),
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                ),
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Tambah',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 13),
            SizedBox(
              height: 137,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics:
                const BouncingScrollPhysics(),
                itemCount: images.length,
                separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _photoItem(images[index]);
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 9),
            const Text(
              'Belum ada foto',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoItem(
      ServiceCustomerImage image,
      ) {
    final imageUrl =
        'https://api.api-nusantaradiesel.tech'
        '${image.imagePath}';

    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openPhoto(image),
              borderRadius: BorderRadius.circular(13),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  imageUrl,
                  width: 125,
                  height: 94,
                  fit: BoxFit.cover,
                  loadingBuilder: (
                      context,
                      child,
                      progress,
                      ) {
                    if (progress == null) return child;

                    return Container(
                      width: 125,
                      height: 94,
                      color: Colors.white.withOpacity(0.04),
                      alignment: Alignment.center,
                      child:
                      const CircularProgressIndicator(
                        color: accent,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      width: 125,
                      height: 94,
                      color: Colors.white.withOpacity(0.04),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            image.caption.trim().isEmpty
                ? 'Tanpa keterangan'
                : image.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  void _openPhoto(
      ServiceCustomerImage image,
      ) {
    final imageUrl =
        'https://api.api-nusantaradiesel.tech'
        '${image.imagePath}';

    showDialog<void>(
      context: context,
      barrierColor:
      Colors.black.withOpacity(0.94),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding:
          const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (
                          context,
                          child,
                          progress,
                          ) {
                        if (progress == null) {
                          return child;
                        }

                        return const Center(
                          child:
                          CircularProgressIndicator(
                            color: accent,
                          ),
                        );
                      },
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Center(
                          child: Column(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .broken_image_outlined,
                                color:
                                Colors.white38,
                                size: 45,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Foto gagal dimuat',
                                style: TextStyle(
                                  color:
                                  Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.65),
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Download',
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );

                          _downloadPhoto(image);
                        },
                        icon: const Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );

                          _confirmDeletePhoto(
                            image,
                          );
                        },
                        icon: const Icon(
                          Icons
                              .delete_outline_rounded,
                          color:
                          Colors.redAccent,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadPhoto(
      String kategori,
      ) async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      final captionController =
      TextEditingController();

      final caption = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xff191919),
            title: const Text(
              'Keterangan Foto',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: captionController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText:
                'Contoh: Kondisi sebelum dibongkar',
                hintStyle: TextStyle(
                  color: Colors.white30,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  captionController.text.trim(),
                ),
                child: const Text('Upload'),
              ),
            ],
          );
        },
      );

      captionController.dispose();

      if (caption == null || !mounted) return;

      setState(() {
        _uploadingPhoto = true;
      });

      await ServiceCustomerApi.uploadImage(
        serviceId: widget.service.id,
        image: image,
        kategori: kategori,
        caption: caption,
      );

      if (!mounted) return;

      setState(() {
        _uploadingPhoto = false;
        _futureImages =
            ServiceCustomerApi.getImages(
              widget.service.id,
            );
        _changed = true;
      });

      _showMessage('Foto berhasil ditambahkan');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _uploadingPhoto = false;
      });

      _showMessage(
        'Upload foto gagal: $error',
        error: true,
      );
    }
  }

  Future<void> _confirmDeletePhoto(
      ServiceCustomerImage image,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff191919),
          title: const Text(
            'Hapus foto?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Foto akan dihapus secara permanen.',
            style: TextStyle(color: Colors.white54),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ServiceCustomerApi.deleteImage(
        widget.service.id,
        image.id,
      );

      if (!mounted) return;

      setState(() {
        _futureImages =
            ServiceCustomerApi.getImages(
              widget.service.id,
            );
        _changed = true;
      });

      _showMessage('Foto berhasil dihapus');
    } catch (error) {
      _showMessage(
        'Gagal menghapus foto: $error',
        error: true,
      );
    }
  }

  Widget _buildVideoSection() {
    return _sectionCard(
      title: 'Hasil Test Video',
      subtitle: 'Dokumentasi hasil pengujian',
      icon: Icons.video_library_outlined,
      trailing: TextButton.icon(
        onPressed:
        _uploadingVideo ? null : _uploadVideo,
        style: TextButton.styleFrom(
          foregroundColor: accent,
        ),
        icon: const Icon(
          Icons.video_call_outlined,
          size: 19,
        ),
        label: const Text(
          'Tambah',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child:
      FutureBuilder<List<ServiceCustomerVideo>>(
        future: _futureVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: accent,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _inlineError(
              'Gagal mengambil video',
                  () {
                setState(() {
                  _futureVideos =
                      ServiceCustomerApi.getVideos(
                        widget.service.id,
                      );
                });
              },
            );
          }

          final videos =
              snapshot.data ?? <ServiceCustomerVideo>[];

          if (videos.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 25,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.025),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    color: Colors.white24,
                    size: 35,
                  ),
                  SizedBox(height: 9),
                  Text(
                    'Belum ada video hasil test',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: List.generate(
              videos.length,
                  (index) {
                final video = videos[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < videos.length - 1
                        ? 10
                        : 0,
                  ),
                  child: _videoCard(video),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _videoCard(
      ServiceCustomerVideo video,
      ) {
    final caption =
    video.caption.trim().isEmpty
        ? 'Video hasil test'
        : video.caption;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openVideo(video),
        borderRadius:
        BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color:
            Colors.white.withOpacity(0.035),
            borderRadius:
            BorderRadius.circular(17),
            border: Border.all(
              color:
              Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color:
                  accent.withOpacity(0.11),
                  borderRadius:
                  BorderRadius.circular(15),
                  border: Border.all(
                    color:
                    accent.withOpacity(0.18),
                  ),
                ),
                child: const Icon(
                  Icons
                      .play_circle_fill_rounded,
                  color: accent,
                  size: 29,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      caption,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Tekan untuk memutar video',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Putar',
                onPressed: () =>
                    _openVideo(video),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: accent,
                  size: 23,
                ),
              ),
              PopupMenuButton<String>(
                color:
                const Color(0xff202020),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white38,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'download':
                      _downloadVideo(video);
                      break;

                    case 'delete':
                      _confirmDeleteVideo(
                        video,
                      );
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem<String>(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .download_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 11),
                        Text(
                          'Download',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .delete_outline_rounded,
                          color:
                          Colors.redAccent,
                          size: 20,
                        ),
                        SizedBox(width: 11),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color:
                            Colors.redAccent,
                          ),
                        ),
                      ],
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

  Future<void> _uploadVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video == null || !mounted) return;

      final captionController =
      TextEditingController();

      final caption = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xff191919),
            title: const Text(
              'Keterangan Video',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: captionController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText:
                'Contoh: Hasil test injector',
                hintStyle: TextStyle(
                  color: Colors.white30,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  captionController.text.trim(),
                ),
                child: const Text('Upload'),
              ),
            ],
          );
        },
      );

      captionController.dispose();

      if (caption == null || !mounted) return;

      setState(() {
        _uploadingVideo = true;
      });

      await ServiceCustomerApi.uploadVideo(
        serviceId: widget.service.id,
        video: video,
        caption: caption,
      );

      if (!mounted) return;

      setState(() {
        _uploadingVideo = false;
        _futureVideos =
            ServiceCustomerApi.getVideos(
              widget.service.id,
            );
        _changed = true;
      });

      _showMessage('Video berhasil ditambahkan');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _uploadingVideo = false;
      });

      _showMessage(
        'Upload video gagal: $error',
        error: true,
      );
    }
  }

  Future<void> _confirmDeleteVideo(
      ServiceCustomerVideo video,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff191919),
          title: const Text(
            'Hapus video?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Video akan dihapus secara permanen.',
            style: TextStyle(color: Colors.white54),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ServiceCustomerApi.deleteVideo(
        widget.service.id,
        video.id,
      );

      if (!mounted) return;

      setState(() {
        _futureVideos =
            ServiceCustomerApi.getVideos(
              widget.service.id,
            );
        _changed = true;
      });

      _showMessage('Video berhasil dihapus');
    } catch (error) {
      _showMessage(
        'Gagal menghapus video: $error',
        error: true,
      );
    }
  }

  Future<void> _downloadVideo(
      ServiceCustomerVideo video,
      ) async {
    try {
      final videoUrl =
          'https://api.api-nusantaradiesel.tech'
          '${video.videoPath}';

      final extension = video.videoPath
          .split('.')
          .last
          .split('?')
          .first;

      final fileName =
          'service_video_${video.id}.$extension';

      final saveLocation =
      await getSaveLocation(
        suggestedName: fileName,
      );

      if (saveLocation == null) {
        return;
      }

      _showBlockingLoading(
        'Mengunduh video...',
      );

      final response = await http
          .get(Uri.parse(videoUrl))
          .timeout(
        const Duration(minutes: 10),
      );

      if (mounted &&
          Navigator.of(
            context,
            rootNavigator: true,
          ).canPop()) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Server mengembalikan status '
              '${response.statusCode}',
        );
      }

      final file = File(saveLocation.path);

      await file.writeAsBytes(
        response.bodyBytes,
        flush: true,
      );

      _showMessage(
        'Video berhasil disimpan',
      );
    } catch (error) {
      if (mounted &&
          Navigator.of(
            context,
            rootNavigator: true,
          ).canPop()) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();
      }

      _showMessage(
        'Download video gagal: $error',
        error: true,
      );
    }
  }

  Widget _inlineError(
      String message,
      VoidCallback onRetry,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.17),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 7),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}