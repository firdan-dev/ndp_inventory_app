import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> printMultiple(List<String> barcodes) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => pw.Wrap(
        spacing: 10,
        runSpacing: 10,
        children: barcodes.map((code) {
          return pw.Container(
            width: 160,
            height: 90,
            child: pw.Column(
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: code,
                  width: 150,
                  height: 55,
                ),
                pw.Text(code, style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) async => pdf.save());
}

Future<void> printThermal(String barcode) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (_) => pw.Center(
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: barcode,
          width: 220,
          height: 80,
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) async => pdf.save());
}

Future<void> printBarcode(String barcode) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (_) => pw.Center(
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: barcode,
          width: 300,
          height: 100,
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) async => pdf.save());
}