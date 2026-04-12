import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../utils/constants.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteVM = Provider.of<QuoteViewModel>(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                const Text(
                  'Daily Inspiration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => quoteVM.loadRandomQuote(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (quoteVM.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (quoteVM.errorMessage != null)
              Text(
                'Tap to refresh for inspiration',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              )
            else
              Column(
                children: [
                  Text(
                    '"${quoteVM.currentQuote?.content ?? "Stay safe!"}"',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- ${quoteVM.currentQuote?.author ?? "Unknown"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}