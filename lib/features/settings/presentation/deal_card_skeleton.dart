import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DealCardSkeleton extends StatelessWidget {
  const DealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Placeholder ---
            Container(height: 180, color: Colors.white),
            // --- Details Placeholder ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title Placeholder ---
                  Container(
                    width: double.infinity,
                    height: 20.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 20.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),

                  // --- Price and Source Placeholder ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // --- Price Placeholder ---
                      Container(width: 100, height: 28.0, color: Colors.white),
                      const Spacer(),
                      // --- Source Placeholder ---
                      Container(width: 60, height: 16.0, color: Colors.white),
                    ],
                  ),

                  // --- Go to Deal Button Placeholder ---
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
