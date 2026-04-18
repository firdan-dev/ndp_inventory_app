import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> printBarcode(String data) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(58 * PdfPageFormat.mm, 40 * PdfPageFormat.mm),
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: data,
              width: 250,
              height: 100,
            ),
            pw.SizedBox(height: 5),
            pw.Text(data, style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
}