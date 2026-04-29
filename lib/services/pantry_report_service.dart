import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/pantry_item.dart';
import 'package:intl/intl.dart';

class PantryReportService {
  static Future<void> generateAndPrintReport(List<PantryItem> items) async {
    // Load Korean font to support Unicode characters
    final font = await PdfGoogleFonts.nanumGothicRegular();
    final boldFont = await PdfGoogleFonts.nanumGothicBold();
    
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy. MM. dd').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(dateStr),
          pw.SizedBox(height: 24),
          _buildSummary(items),
          pw.SizedBox(height: 24),
          _buildItemsTable(items),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Master_Pantry_Ledger_${DateFormat('yyyyMMdd').format(now)}.pdf',
    );
  }

  static pw.Widget _buildHeader(String dateStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '식재료 관리 대장',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        pw.Container(
          height: 2,
          color: PdfColors.black,
          margin: const pw.EdgeInsets.symmetric(vertical: 4),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('공방 공식 재고 증명서', style: const pw.TextStyle(fontSize: 10)),
            pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(List<PantryItem> items) {
    final totalValue = items.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice));
    final lowStockCount = items.where((i) => (i.currentStock / (i.targetQuantity > 0 ? i.targetQuantity : 1)) < 0.2).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('전체 품목수', items.length.toString()),
          _buildSummaryStat('보충 필요', lowStockCount.toString()),
          _buildSummaryStat('총 자산 가치', '₩ ${NumberFormat('#,###').format(totalValue)}'),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<PantryItem> items) {
    return pw.TableHelper.fromTextArray(
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headers: ['재료명', '카테고리', '현재 재고', '목표 재고', '상태'],
      data: items.map((item) {
        final stockPercent = (item.currentStock / (item.targetQuantity > 0 ? item.targetQuantity : 1)).clamp(0.0, 1.0);
        final status = stockPercent < 0.2 ? '보충필요' : (stockPercent < 0.5 ? '낮음' : '안정');
        
        return [
          item.name,
          item.category,
          '${item.currentStock.toInt()}${item.unit}',
          '${item.targetQuantity.toInt()}${item.unit}',
          status,
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Container(height: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('MY ATELIER - ARTISANAL MANAGEMENT SYSTEM', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
            pw.Text('PAGE 1 OF 1', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
          ],
        ),
      ],
    );
  }
}
