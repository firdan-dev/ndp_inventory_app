import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ndp_inventory_app/services/api_service.dart';

class SuratJalanDetailMobilePage extends StatefulWidget {
  final int suratJalanId;

  const SuratJalanDetailMobilePage({
    super.key,
    required this.suratJalanId,
  });

  @override
  State<SuratJalanDetailMobilePage> createState() =>
      _SuratJalanDetailMobilePageState();
}

class _SuratJalanDetailMobilePageState
    extends State<SuratJalanDetailMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color blueAccent = Color(0xff64b5f6);
  static const Color redAccent = Color(0xffff5252);

  Map<String, dynamic>? _surat;
  List<dynamic> _items = [];

  bool _loading = true;
  bool _processing = false;

  String? _errorMessage;

  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();

    _loadDetail();
  }

  Future<void> _loadDetail({
    bool showLoading = true,
  }) async {
    if (!mounted) return;

    setState(() {
      if (showLoading) {
        _loading = true;
      }

      _errorMessage = null;
    });

    try {
      final result =
      await ApiService.getSuratJalanDetail(
        widget.suratJalanId,
      );

      if (!mounted) return;

      final rawSurat =
      result['surat'];

      final rawItems =
      result['items'];

      setState(() {
        if (rawSurat is Map) {
          _surat =
          Map<String, dynamic>.from(
            rawSurat,
          );
        } else {
          _surat = {};
        }

        if (rawItems is List) {
          _items =
          List<dynamic>.from(
            rawItems,
          );
        } else {
          _items = [];
        }

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            error.toString();
      });
    }
  }

  String _text(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final text =
    value.toString().trim();

    if (text.toLowerCase() ==
        'null') {
      return '';
    }

    return text;
  }

  int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  String get _status {
    return _text(
      _surat?['status'],
    ).isEmpty
        ? 'Pending'
        : _text(
      _surat?['status'],
    );
  }

  bool get _isPending {
    return _status.toLowerCase() ==
        'pending';
  }

  bool get _isApproved {
    return _status.toLowerCase() ==
        'approved';
  }

  bool get _isDikirim {
    return _status.toLowerCase() ==
        'dikirim';
  }

  Color get _statusColor {
    if (_isApproved) {
      return greenAccent;
    }

    if (_isDikirim) {
      return blueAccent;
    }

    return accent;
  }

  IconData get _statusIcon {
    if (_isApproved) {
      return Icons
          .check_circle_outline_rounded;
    }

    if (_isDikirim) {
      return Icons
          .local_shipping_outlined;
    }

    return Icons
        .pending_actions_rounded;
  }

  Future<bool> _handleBack() async {
    Navigator.pop(
      context,
      _hasChanged,
    );

    return false;
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
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          error
              ? redAccent
              : const Color(
            0xff242424,
          ),
          content: Text(
            message,
          ),
        ),
      );
  }

  Future<void> _approve() async {
    final confirm =
    await _showConfirmDialog(
      title:
      'Approve Surat Jalan?',
      message:
      'Setelah di-approve, stok barang inventory akan dikurangi dan item tidak bisa diedit lagi.',
      buttonText:
      'Approve',
      color:
      greenAccent,
    );

    if (confirm != true) return;

    setState(() {
      _processing = true;
    });

    try {
      await ApiService
          .approveSuratJalan(
        widget.suratJalanId,
      );

      if (!mounted) return;

      _hasChanged = true;

      _showMessage(
        'Surat Jalan berhasil di-approve',
      );

      await _loadDetail(
        showLoading: false,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal approve Surat Jalan: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<void> _markAsDikirim() async {
    final confirm =
    await _showConfirmDialog(
      title:
      'Tandai Sebagai Dikirim?',
      message:
      'Status Surat Jalan akan diubah dari Approved menjadi Dikirim.',
      buttonText:
      'Tandai Dikirim',
      color:
      blueAccent,
    );

    if (confirm != true) return;

    setState(() {
      _processing = true;
    });

    try {
      await ApiService
          .updateSuratJalanStatus(
        id:
        widget.suratJalanId,
        status:
        'Dikirim',
      );

      if (!mounted) return;

      _hasChanged = true;

      _showMessage(
        'Status berhasil diubah menjadi Dikirim',
      );

      await _loadDetail(
        showLoading: false,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal update status: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String buttonText,
    required Color color,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor:
          const Color(
            0xff151515,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),
          title:
          Text(
            title,
            style:
            const TextStyle(
              color:
              Colors.white,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          content:
          Text(
            message,
            style:
            const TextStyle(
              color:
              Colors.white54,
              height:
              1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                color,
                foregroundColor:
                color ==
                    greenAccent
                    ? Colors.black
                    : Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              Text(
                buttonText,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editQty(
      dynamic item,
      ) async {
    if (!_isPending) return;

    final itemId =
    _toInt(
      item['id'],
    );

    if (itemId <= 0) return;

    final qtyController =
    TextEditingController(
      text:
      _toInt(
        item['qty'],
      ).toString(),
    );

    final result =
    await showModalBottomSheet<
        int>(
      context: context,
      isScrollControlled:
      true,
      backgroundColor:
      Colors.transparent,
      barrierColor:
      Colors.black.withOpacity(
        0.65,
      ),
      builder: (
          context,
          ) {
        return Padding(
          padding:
          EdgeInsets.only(
            bottom:
            MediaQuery.of(
              context,
            )
                .viewInsets
                .bottom,
          ),
          child:
          _glassBottomSheet(
            child:
            Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _sheetHandle(),

                const SizedBox(
                  height:
                  20,
                ),

                const Text(
                  'Edit Qty Item',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontSize:
                    19,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height:
                  6,
                ),

                Text(
                  _text(
                    item[
                    'nama_barang'],
                  ),
                  style:
                  const TextStyle(
                    color:
                    Colors.white38,
                    fontSize:
                    11,
                  ),
                ),

                const SizedBox(
                  height:
                  18,
                ),

                TextField(
                  controller:
                  qtyController,
                  keyboardType:
                  TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                  ),
                  decoration:
                  _inputDecoration(
                    'Qty',
                  ),
                ),

                const SizedBox(
                  height:
                  20,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                        () {
                      final qty =
                          int.tryParse(
                            qtyController
                                .text,
                          ) ??
                              0;

                      if (qty <=
                          0) {
                        return;
                      }

                      Navigator.pop(
                        context,
                        qty,
                      );
                    },
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      accent,
                      foregroundColor:
                      Colors.white,
                      minimumSize:
                      const Size.fromHeight(
                        52,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          17,
                        ),
                      ),
                    ),
                    icon:
                    const Icon(
                      Icons.save_rounded,
                    ),
                    label:
                    const Text(
                      'Simpan Qty',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    qtyController.dispose();

    if (result == null ||
        result <= 0) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await ApiService
          .updateSuratJalanItemQty(
        itemId:
        itemId,
        qty:
        result,
      );

      if (!mounted) return;

      _hasChanged = true;

      _showMessage(
        'Qty item berhasil diperbarui',
      );

      await _loadDetail(
        showLoading: false,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal update qty: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<void> _deleteItem(
      dynamic item,
      ) async {
    if (!_isPending) return;

    final itemId =
    _toInt(
      item['id'],
    );

    if (itemId <= 0) return;

    final confirm =
    await _showConfirmDialog(
      title:
      'Hapus Item?',
      message:
      '${_text(item['nama_barang'])} akan dihapus dari Surat Jalan.',
      buttonText:
      'Hapus',
      color:
      redAccent,
    );

    if (confirm != true) return;

    setState(() {
      _processing = true;
    });

    try {
      await ApiService
          .deleteSuratJalanItem(
        itemId,
      );

      if (!mounted) return;

      _hasChanged = true;

      _showMessage(
        'Item berhasil dihapus',
      );

      await _loadDetail(
        showLoading: false,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal menghapus item: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<void> _openAddItem() async {
    if (!_isPending) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
      Colors.transparent,
      barrierColor:
      Colors.black.withOpacity(
        0.65,
      ),
      builder: (
          bottomSheetContext,
          ) {
        return _glassBottomSheet(
          child:
          Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              _sheetHandle(),

              const SizedBox(
                height:
                20,
              ),

              const Text(
                'Tambah Item',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  19,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                18,
              ),

              _actionTile(
                icon:
                Icons.qr_code_scanner_rounded,
                title:
                'Scan / Input Barcode',
                subtitle:
                'Tambah barang dari inventory',
                color:
                accent,
                onTap:
                    () {
                  Navigator.pop(
                    bottomSheetContext,
                  );

                  _showBarcodeAddDialog();
                },
              ),

              const SizedBox(
                height:
                10,
              ),

              _actionTile(
                icon:
                Icons.edit_note_rounded,
                title:
                'Item Manual',
                subtitle:
                'Tambah barang tanpa stok inventory',
                color:
                blueAccent,
                onTap:
                    () {
                  Navigator.pop(
                    bottomSheetContext,
                  );

                  _showManualAddDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showBarcodeAddDialog() async {
    final barcodeController =
    TextEditingController();

    final qtyController =
    TextEditingController(
      text:
      '1',
    );

    Map<String, dynamic>?
    product;

    bool searching =
    false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled:
      true,
      backgroundColor:
      Colors.transparent,
      builder: (
          bottomSheetContext,
          ) {
        return StatefulBuilder(
          builder: (
              context,
              setModalState,
              ) {
            Future<void>
            searchProduct() async {
              final barcode =
              barcodeController
                  .text
                  .trim();

              if (barcode.isEmpty) {
                return;
              }

              setModalState(() {
                searching =
                true;
              });

              try {
                final result =
                await ApiService
                    .scanBarangSuratJalan(
                  barcode,
                );

                setModalState(() {
                  product =
                      result;

                  searching =
                  false;
                });
              } catch (_) {
                setModalState(() {
                  searching =
                  false;

                  product =
                  null;
                });
              }
            }

            return Padding(
              padding:
              EdgeInsets.only(
                bottom:
                MediaQuery.of(
                  context,
                )
                    .viewInsets
                    .bottom,
              ),
              child:
              _glassBottomSheet(
                child:
                Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _sheetHandle(),

                    const SizedBox(
                      height:
                      20,
                    ),

                    const Text(
                      'Tambah Barang Inventory',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        18,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                      17,
                    ),

                    TextField(
                      controller:
                      barcodeController,
                      onSubmitted:
                          (_) =>
                          searchProduct(),
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                      ),
                      decoration:
                      _inputDecoration(
                        'Barcode',
                      ).copyWith(
                        prefixIcon:
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color:
                          accent,
                        ),
                        suffixIcon:
                        IconButton(
                          onPressed:
                          searching
                              ? null
                              : searchProduct,
                          icon:
                          searching
                              ? const SizedBox(
                            width:
                            18,
                            height:
                            18,
                            child:
                            CircularProgressIndicator(
                              color:
                              accent,
                              strokeWidth:
                              2,
                            ),
                          )
                              : const Icon(
                            Icons.search_rounded,
                            color:
                            accent,
                          ),
                        ),
                      ),
                    ),

                    if (product !=
                        null) ...[
                      const SizedBox(
                        height:
                        14,
                      ),

                      Container(
                        padding:
                        const EdgeInsets.all(
                          14,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          Colors.white
                              .withOpacity(
                            0.035,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                          border:
                          Border.all(
                            color:
                            Colors.white
                                .withOpacity(
                              0.08,
                            ),
                          ),
                        ),
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _text(
                                product?[
                                'nama_barang'],
                              ),
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height:
                              7,
                            ),

                            Text(
                              '${_text(product?['kode_internal'])} • '
                                  '${_text(product?['part_no'])}',
                              style:
                              const TextStyle(
                                color:
                                Colors.white38,
                                fontSize:
                                10,
                              ),
                            ),

                            const SizedBox(
                              height:
                              5,
                            ),

                            Text(
                              'Stok: ${_toInt(product?['qty'])} pcs',
                              style:
                              const TextStyle(
                                color:
                                greenAccent,
                                fontSize:
                                10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height:
                        13,
                      ),

                      TextField(
                        controller:
                        qtyController,
                        keyboardType:
                        TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly,
                        ],
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),
                        decoration:
                        _inputDecoration(
                          'Qty',
                        ),
                      ),

                      const SizedBox(
                        height:
                        18,
                      ),

                      SizedBox(
                        width:
                        double.infinity,
                        child:
                        ElevatedButton.icon(
                          onPressed:
                              () async {
                            final qty =
                                int.tryParse(
                                  qtyController
                                      .text,
                                ) ??
                                    0;

                            final stock =
                            _toInt(
                              product?[
                              'qty'],
                            );

                            if (qty <=
                                0 ||
                                qty >
                                    stock) {
                              return;
                            }

                            try {
                              await ApiService
                                  .addSuratJalanItem(
                                suratJalanId:
                                widget
                                    .suratJalanId,
                                item: {
                                  'item_type':
                                  'barcode',
                                  'product_id':
                                  product?[
                                  'id'],
                                  'nama_barang':
                                  product?[
                                  'nama_barang'] ??
                                      '',
                                  'kode_internal':
                                  product?[
                                  'kode_internal'] ??
                                      '',
                                  'part_no':
                                  product?[
                                  'part_no'] ??
                                      '',
                                  'merk':
                                  product?[
                                  'merk'] ??
                                      '',
                                  'qty':
                                  qty,
                                  'pic':
                                  _text(
                                    _surat?[
                                    'pic'],
                                  ),
                                  'satuan':
                                  'Ea',
                                  'keterangan':
                                  '',
                                  'deskripsi':
                                  '',
                                },
                              );

                              if (!mounted) {
                                return;
                              }

                              Navigator.pop(
                                bottomSheetContext,
                              );

                              _hasChanged =
                              true;

                              await _loadDetail(
                                showLoading:
                                false,
                              );
                            } catch (error) {
                              _showMessage(
                                'Gagal tambah item: $error',
                                error:
                                true,
                              );
                            }
                          },
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            accent,
                            foregroundColor:
                            Colors.white,
                            minimumSize:
                            const Size.fromHeight(
                              52,
                            ),
                          ),
                          icon:
                          const Icon(
                            Icons.add_rounded,
                          ),
                          label:
                          const Text(
                            'Tambah Barang',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    barcodeController.dispose();
    qtyController.dispose();
  }

  Future<void> _showManualAddDialog() async {
    final namaController =
    TextEditingController();

    final qtyController =
    TextEditingController(
      text:
      '1',
    );

    final deskripsiController =
    TextEditingController();

    String satuan =
        'Ea';

    const satuanList = [
      'Ea',
      'Unit',
      'Set',
      'Roll',
      'Gulung',
      'Pcs',
      'Box',
      'Kg',
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled:
      true,
      backgroundColor:
      Colors.transparent,
      builder: (
          bottomSheetContext,
          ) {
        return StatefulBuilder(
          builder: (
              context,
              setModalState,
              ) {
            return Padding(
              padding:
              EdgeInsets.only(
                bottom:
                MediaQuery.of(
                  context,
                )
                    .viewInsets
                    .bottom,
              ),
              child:
              _glassBottomSheet(
                child:
                Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _sheetHandle(),

                    const SizedBox(
                      height:
                      20,
                    ),

                    const Text(
                      'Tambah Item Manual',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        18,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                      17,
                    ),

                    TextField(
                      controller:
                      namaController,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                      ),
                      decoration:
                      _inputDecoration(
                        'Nama Barang',
                      ),
                    ),

                    const SizedBox(
                      height:
                      12,
                    ),

                    TextField(
                      controller:
                      qtyController,
                      keyboardType:
                      TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                      ],
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                      ),
                      decoration:
                      _inputDecoration(
                        'Qty',
                      ),
                    ),

                    const SizedBox(
                      height:
                      12,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value:
                      satuan,
                      dropdownColor:
                      const Color(
                        0xff151515,
                      ),
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                      ),
                      decoration:
                      _inputDecoration(
                        'Satuan',
                      ),
                      items:
                      satuanList
                          .map(
                            (value) {
                          return DropdownMenuItem<
                              String>(
                            value:
                            value,
                            child:
                            Text(
                              value,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged:
                          (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        setModalState(
                              () {
                            satuan =
                                value;
                          },
                        );
                      },
                    ),

                    const SizedBox(
                      height:
                      12,
                    ),

                    TextField(
                      controller:
                      deskripsiController,
                      maxLines:
                      3,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                      ),
                      decoration:
                      _inputDecoration(
                        'Deskripsi',
                      ),
                    ),

                    const SizedBox(
                      height:
                      18,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      child:
                      ElevatedButton.icon(
                        onPressed:
                            () async {
                          final nama =
                          namaController
                              .text
                              .trim();

                          final qty =
                              int.tryParse(
                                qtyController
                                    .text,
                              ) ??
                                  0;

                          if (nama
                              .isEmpty ||
                              qty <=
                                  0) {
                            return;
                          }

                          try {
                            await ApiService
                                .addSuratJalanItem(
                              suratJalanId:
                              widget
                                  .suratJalanId,
                              item: {
                                'item_type':
                                'manual',
                                'product_id':
                                null,
                                'nama_barang':
                                nama,
                                'kode_internal':
                                '',
                                'part_no':
                                '',
                                'merk':
                                '',
                                'qty':
                                qty,
                                'pic':
                                _text(
                                  _surat?[
                                  'pic'],
                                ),
                                'satuan':
                                satuan,
                                'keterangan':
                                deskripsiController
                                    .text
                                    .trim(),
                                'deskripsi':
                                deskripsiController
                                    .text
                                    .trim(),
                              },
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(
                              bottomSheetContext,
                            );

                            _hasChanged =
                            true;

                            await _loadDetail(
                              showLoading:
                              false,
                            );
                          } catch (error) {
                            _showMessage(
                              'Gagal tambah item: $error',
                              error:
                              true,
                            );
                          }
                        },
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          accent,
                          foregroundColor:
                          Colors.white,
                          minimumSize:
                          const Size.fromHeight(
                            52,
                          ),
                        ),
                        icon:
                        const Icon(
                          Icons.add_rounded,
                        ),
                        label:
                        const Text(
                          'Tambah Item',
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

    namaController.dispose();
    qtyController.dispose();
    deskripsiController.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return WillPopScope(
      onWillPop:
      _handleBack,
      child:
      Scaffold(
        backgroundColor:
        background,
        body:
        Stack(
          children: [
            Positioned(
              top:
              40,
              right:
              -140,
              child:
              _buildGlow(
                color:
                _statusColor,
                size:
                320,
              ),
            ),

            Positioned(
              bottom:
              60,
              left:
              -160,
              child:
              _buildGlow(
                color:
                blueAccent,
                size:
                320,
              ),
            ),

            SafeArea(
              child:
              _buildBody(),
            ),

            if (_processing)
              Positioned.fill(
                child:
                Container(
                  color:
                  Colors.black
                      .withOpacity(
                    0.35,
                  ),
                  child:
                  const Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
        CircularProgressIndicator(
          color:
          accent,
        ),
      );
    }

    if (_errorMessage !=
        null ||
        _surat ==
            null) {
      return Center(
        child:
        Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color:
              redAccent,
              size:
              44,
            ),

            const SizedBox(
              height:
              12,
            ),

            Text(
              _errorMessage ??
                  'Data tidak ditemukan',
              style:
              const TextStyle(
                color:
                Colors.white54,
              ),
            ),

            const SizedBox(
              height:
              12,
            ),

            TextButton.icon(
              onPressed:
              _loadDetail,
              icon:
              const Icon(
                Icons.refresh_rounded,
              ),
              label:
              const Text(
                'Coba Lagi',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          _loadDetail(
            showLoading:
            false,
          ),
      color:
      accent,
      backgroundColor:
      const Color(
        0xff1b1b1b,
      ),
      child:
      CustomScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(
          parent:
          BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding:
            const EdgeInsets.fromLTRB(
              22,
              16,
              22,
              110,
            ),
            sliver:
            SliverList(
              delegate:
              SliverChildListDelegate(
                [
                  _buildHeader(),

                  const SizedBox(
                    height:
                    18,
                  ),

                  _buildStatusCard(),

                  const SizedBox(
                    height:
                    16,
                  ),

                  _buildSuratInfo(),

                  const SizedBox(
                    height:
                    16,
                  ),

                  _buildRecipientInfo(),

                  const SizedBox(
                    height:
                    16,
                  ),

                  _buildItemsSection(),

                  const SizedBox(
                    height:
                    22,
                  ),

                  _buildActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color:
          Colors.transparent,
          child:
          InkWell(
            onTap: () {
              Navigator.pop(
                context,
                _hasChanged,
              );
            },
            borderRadius:
            BorderRadius.circular(
              17,
            ),
            child:
            Container(
              width:
              54,
              height:
              54,
              decoration:
              BoxDecoration(
                color:
                Colors.white
                    .withOpacity(
                  0.04,
                ),
                borderRadius:
                BorderRadius.circular(
                  17,
                ),
                border:
                Border.all(
                  color:
                  Colors.white
                      .withOpacity(
                    0.09,
                  ),
                ),
              ),
              child:
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color:
                Colors.white70,
                size:
                20,
              ),
            ),
          ),
        ),

        const SizedBox(
          width:
          16,
        ),

        Expanded(
          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Surat Jalan',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  24,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                4,
              ),

              Text(
                _text(
                  _surat?[
                  'nomor_surat'],
                ),
                style:
                TextStyle(
                  color:
                  _statusColor,
                  fontSize:
                  10,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return _glassCard(
      borderColor:
      _statusColor,
      child:
      Row(
        children: [
          Container(
            width:
            60,
            height:
            60,
            decoration:
            BoxDecoration(
              color:
              _statusColor
                  .withOpacity(
                0.13,
              ),
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              border:
              Border.all(
                color:
                _statusColor
                    .withOpacity(
                  0.25,
                ),
              ),
            ),
            child:
            Icon(
              _statusIcon,
              color:
              _statusColor,
              size:
              29,
            ),
          ),

          const SizedBox(
            width:
            14,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Surat Jalan',
                  style:
                  TextStyle(
                    color:
                    Colors.white38,
                    fontSize:
                    9,
                  ),
                ),

                const SizedBox(
                  height:
                  5,
                ),

                Text(
                  _status,
                  style:
                  TextStyle(
                    color:
                    _statusColor,
                    fontSize:
                    18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal:
              12,
              vertical:
              8,
            ),
            decoration:
            BoxDecoration(
              color:
              _statusColor
                  .withOpacity(
                0.10,
              ),
              borderRadius:
              BorderRadius.circular(
                25,
              ),
            ),
            child:
            Text(
              '${_items.length} item',
              style:
              TextStyle(
                color:
                _statusColor,
                fontSize:
                9,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuratInfo() {
    return _section(
      title:
      'Informasi Surat Jalan',
      icon:
      Icons.description_outlined,
      children: [
        _detailRow(
          'Nomor Surat',
          _text(
            _surat?[
            'nomor_surat'],
          ),
        ),
        _detailRow(
          'Tujuan',
          _text(
            _surat?[
            'tujuan_cabang'],
          ),
        ),
        _detailRow(
          'Jenis Transaksi',
          _text(
            _surat?[
            'transaction_type'],
          ),
        ),
        _detailRow(
          'PIC',
          _text(
            _surat?[
            'pic'],
          ),
        ),
        _detailRow(
          'OS No',
          _text(
            _surat?[
            'os_no'],
          ),
        ),
        _detailRow(
          'Kode',
          _text(
            _surat?[
            'kode'],
          ),
        ),
        _detailRow(
          'Resi',
          _text(
            _surat?[
            'resi'],
          ),
        ),
        _detailRow(
          'Berat',
          _text(
            _surat?[
            'berat'],
          ),
          showDivider:
          false,
        ),
      ],
    );
  }

  Widget _buildRecipientInfo() {
    return _section(
      title:
      'Informasi Penerima',
      icon:
      Icons.location_on_outlined,
      children: [
        _detailRow(
          'Kepada',
          _text(
            _surat?[
            'kepada'],
          ),
        ),
        _detailRow(
          'Alamat',
          _text(
            _surat?[
            'alamat'],
          ),
        ),
        _detailRow(
          'UP',
          _text(
            _surat?[
            'up'],
          ),
        ),
        _detailRow(
          'Nomor HP',
          _text(
            _surat?[
            'hp'],
          ),
        ),
        _detailRow(
          'Keterangan',
          _text(
            _surat?[
            'keterangan'],
          ),
          showDivider:
          false,
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return _glassCard(
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:
                44,
                height:
                44,
                decoration:
                BoxDecoration(
                  color:
                  accent.withOpacity(
                    0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                const Icon(
                  Icons.inventory_2_outlined,
                  color:
                  accent,
                ),
              ),

              const SizedBox(
                width:
                12,
              ),

              const Expanded(
                child:
                Text(
                  'Daftar Item',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontSize:
                    14,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              if (_isPending)
                IconButton(
                  onPressed:
                  _openAddItem,
                  icon:
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color:
                    accent,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height:
            16,
          ),

          if (_items.isEmpty)
            const Padding(
              padding:
              EdgeInsets.symmetric(
                vertical:
                30,
              ),
              child:
              Center(
                child:
                Text(
                  'Tidak ada item',
                  style:
                  TextStyle(
                    color:
                    Colors.white38,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              _items.length,
                  (index) =>
                  _buildItemCard(
                    _items[
                    index],
                    index,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
      dynamic item,
      int index,
      ) {
    final manual =
        _text(
          item[
          'item_type'],
        ) ==
            'manual';

    return Container(
      margin:
      EdgeInsets.only(
        bottom:
        index <
            _items.length -
                1
            ? 10
            : 0,
      ),
      padding:
      const EdgeInsets.all(
        13,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white.withOpacity(
          0.035,
        ),
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        border:
        Border.all(
          color:
          Colors.white.withOpacity(
            0.07,
          ),
        ),
      ),
      child:
      Row(
        children: [
          Container(
            width:
            45,
            height:
            45,
            decoration:
            BoxDecoration(
              color:
              accent.withOpacity(
                0.10,
              ),
              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),
            child:
            Icon(
              manual
                  ? Icons.edit_note_rounded
                  : Icons.inventory_2_outlined,
              color:
              accent,
            ),
          ),

          const SizedBox(
            width:
            11,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    item[
                    'nama_barang'],
                  ),
                  maxLines:
                  1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize:
                    12,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height:
                  4,
                ),

                Text(
                  manual
                      ? '${_text(item['deskripsi'])} • ${_toInt(item['qty'])} ${_text(item['satuan'])}'
                      : '${_text(item['kode_internal'])} • ${_text(item['part_no'])}',
                  maxLines:
                  1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white30,
                    fontSize:
                    9,
                  ),
                ),

                const SizedBox(
                  height:
                  4,
                ),

                Text(
                  '${_toInt(item['qty'])} ${_text(item['satuan']).isEmpty ? 'Ea' : _text(item['satuan'])}',
                  style:
                  TextStyle(
                    color:
                    _statusColor,
                    fontSize:
                    10,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (_isPending) ...[
            IconButton(
              onPressed:
                  () {
                _editQty(
                  item,
                );
              },
              icon:
              const Icon(
                Icons.edit_outlined,
                color:
                Colors.white54,
                size:
                20,
              ),
            ),

            IconButton(
              onPressed:
                  () {
                _deleteItem(
                  item,
                );
              },
              icon:
              const Icon(
                Icons.delete_outline_rounded,
                color:
                redAccent,
                size:
                20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (_isPending) {
      return Column(
        children: [
          SizedBox(
            width:
            double.infinity,
            child:
            OutlinedButton.icon(
              onPressed:
              _processing
                  ? null
                  : _openAddItem,
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                accent,
                minimumSize:
                const Size.fromHeight(
                  54,
                ),
                side:
                BorderSide(
                  color:
                  accent.withOpacity(
                    0.35,
                  ),
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
              ),
              icon:
              const Icon(
                Icons.add_rounded,
              ),
              label:
              const Text(
                'Tambah Item',
              ),
            ),
          ),

          const SizedBox(
            height:
            10,
          ),

          SizedBox(
            width:
            double.infinity,
            child:
            ElevatedButton.icon(
              onPressed:
              _processing
                  ? null
                  : _approve,
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                greenAccent,
                foregroundColor:
                Colors.black,
                minimumSize:
                const Size.fromHeight(
                  56,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
              ),
              icon:
              const Icon(
                Icons.check_circle_rounded,
              ),
              label:
              const Text(
                'Approve Surat Jalan',
                style:
                TextStyle(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_isApproved) {
      return SizedBox(
        width:
        double.infinity,
        child:
        ElevatedButton.icon(
          onPressed:
          _processing
              ? null
              : _markAsDikirim,
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            blueAccent,
            foregroundColor:
            Colors.white,
            minimumSize:
            const Size.fromHeight(
              56,
            ),
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),
          ),
          icon:
          const Icon(
            Icons.local_shipping_rounded,
          ),
          label:
          const Text(
            'Tandai Sebagai Dikirim',
            style:
            TextStyle(
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return _glassCard(
      borderColor:
      blueAccent,
      child:
      const Row(
        children: [
          Icon(
            Icons.local_shipping_rounded,
            color:
            blueAccent,
          ),
          SizedBox(
            width:
            12,
          ),
          Expanded(
            child:
            Text(
              'Surat Jalan sudah berstatus Dikirim.',
              style:
              TextStyle(
                color:
                Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return _glassCard(
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:
                44,
                height:
                44,
                decoration:
                BoxDecoration(
                  color:
                  accent.withOpacity(
                    0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                Icon(
                  icon,
                  color:
                  accent,
                  size:
                  21,
                ),
              ),

              const SizedBox(
                width:
                12,
              ),

              Text(
                title,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  14,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
            16,
          ),

          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value, {
        bool showDivider = true,
      }) {
    return Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(
            vertical:
            9,
          ),
          child:
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              SizedBox(
                width:
                115,
                child:
                Text(
                  label,
                  style:
                  const TextStyle(
                    color:
                    Colors.white30,
                    fontSize:
                    10,
                  ),
                ),
              ),

              Expanded(
                child:
                Text(
                  value.isEmpty
                      ? '-'
                      : value,
                  style:
                  const TextStyle(
                    color:
                    Colors.white70,
                    fontSize:
                    11,
                    fontWeight:
                    FontWeight.w600,
                    height:
                    1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showDivider)
          Divider(
            height:
            1,
            color:
            Colors.white
                .withOpacity(
              0.06,
            ),
          ),
      ],
    );
  }

  Widget _glassCard({
    required Widget child,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        23,
      ),
      child:
      BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX:
          16,
          sigmaY:
          16,
        ),
        child:
        Container(
          width:
          double.infinity,
          padding:
          const EdgeInsets.all(
            17,
          ),
          decoration:
          BoxDecoration(
            gradient:
            LinearGradient(
              colors: [
                (borderColor ??
                    Colors.white)
                    .withOpacity(
                  borderColor ==
                      null
                      ? 0.045
                      : 0.07,
                ),
                Colors.white
                    .withOpacity(
                  0.022,
                ),
              ],
              begin:
              Alignment.topLeft,
              end:
              Alignment.bottomRight,
            ),
            borderRadius:
            BorderRadius.circular(
              23,
            ),
            border:
            Border.all(
              color:
              (borderColor ??
                  Colors.white)
                  .withOpacity(
                borderColor ==
                    null
                    ? 0.08
                    : 0.20,
              ),
            ),
          ),
          child:
          child,
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
        width:
        size,
        height:
        size,
        decoration:
        BoxDecoration(
          shape:
          BoxShape.circle,
          color:
          color.withOpacity(
            0.015,
          ),
          boxShadow: [
            BoxShadow(
              color:
              color.withOpacity(
                0.08,
              ),
              blurRadius:
              130,
              spreadRadius:
              45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBottomSheet({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius:
      const BorderRadius.vertical(
        top:
        Radius.circular(
          30,
        ),
      ),
      child:
      BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX:
          22,
          sigmaY:
          22,
        ),
        child:
        Container(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            26,
          ),
          decoration:
          BoxDecoration(
            gradient:
            LinearGradient(
              colors: [
                const Color(
                  0xff181818,
                ).withOpacity(
                  0.98,
                ),
                const Color(
                  0xff0b0b0b,
                ).withOpacity(
                  0.98,
                ),
              ],
            ),
            borderRadius:
            const BorderRadius.vertical(
              top:
              Radius.circular(
                30,
              ),
            ),
            border:
            Border(
              top:
              BorderSide(
                color:
                Colors.white
                    .withOpacity(
                  0.10,
                ),
              ),
            ),
          ),
          child:
          SafeArea(
            top:
            false,
            child:
            SingleChildScrollView(
              child:
              child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Center(
      child:
      Container(
        width:
        44,
        height:
        4,
        decoration:
        BoxDecoration(
          color:
          Colors.white24,
          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
      Colors.transparent,
      child:
      InkWell(
        onTap:
        onTap,
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        child:
        Container(
          padding:
          const EdgeInsets.all(
            14,
          ),
          decoration:
          BoxDecoration(
            color:
            color.withOpacity(
              0.06,
            ),
            borderRadius:
            BorderRadius.circular(
              17,
            ),
            border:
            Border.all(
              color:
              color.withOpacity(
                0.17,
              ),
            ),
          ),
          child:
          Row(
            children: [
              Container(
                width:
                46,
                height:
                46,
                decoration:
                BoxDecoration(
                  color:
                  color.withOpacity(
                    0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                Icon(
                  icon,
                  color:
                  color,
                ),
              ),

              const SizedBox(
                width:
                12,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height:
                      4,
                    ),
                    Text(
                      subtitle,
                      style:
                      const TextStyle(
                        color:
                        Colors.white38,
                        fontSize:
                        9,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color:
                color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label,
      ) {
    return InputDecoration(
      labelText:
      label,
      labelStyle:
      const TextStyle(
        color:
        Colors.white38,
      ),
      floatingLabelStyle:
      const TextStyle(
        color:
        accent,
      ),
      filled:
      true,
      fillColor:
      Colors.black
          .withOpacity(
        0.16,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide(
          color:
          Colors.white
              .withOpacity(
            0.08,
          ),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        const BorderSide(
          color:
          accent,
        ),
      ),
    );
  }
}