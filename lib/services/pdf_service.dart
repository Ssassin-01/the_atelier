import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class PdfService {
  static Future<void> generateFinancialReport(List<BusinessTransaction> transactions, String title) async {
    // Load Korean font to support Unicode characters
    final font = await PdfGoogleFonts.nanumGothicRegular();
    final boldFont = await PdfGoogleFonts.nanumGothicBold();
    
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );
    
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // Filter to last 30 days
    final now = DateTime.now();
    final recentTxs = transactions.where((tx) => tx.date.isAfter(now.subtract(const Duration(days: 30)))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalSales = recentTxs.where((tx) => tx.type == 'sale').fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpenses = recentTxs.where((tx) => tx.type == 'expense').fold(0.0, (sum, tx) => sum + tx.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(dateFormat.format(now), style: const pw.TextStyle(color: PdfColors.grey)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryBox('총 매출액', currencyFormat.format(totalSales), PdfColors.green),
              _buildSummaryBox('총 지출액', currencyFormat.format(totalExpenses), PdfColors.red),
              _buildSummaryBox('정산 순수익', currencyFormat.format(totalSales - totalExpenses), PdfColors.blue),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['날짜', '구분', '내용', '금액'],
            data: recentTxs.map((tx) => [
              DateFormat('MM-dd').format(tx.date),
              tx.type == 'sale' ? '매출' : '지출',
              tx.description,
              currencyFormat.format(tx.amount),
            ]).toList(),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 40),
            child: pw.Center(
              child: pw.Text('My Atelier - Artisanal Management System', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Atelier_Financial_Report_${DateFormat('yyyyMMdd').format(now)}.pdf',
    );
  }

  static pw.Widget _buildSummaryBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
